using Flux
using Flux: onehot, argmax, onehotbatch
using Flux.Tracker
using Gadfly
using StatsBase
using Iterators: product
using DataFrames
using CSV
using Distributions: Uniform

# In a RL problem we have an agent A, a State space S and an Action space A

# We need a policy function Π: S x A -> [0,1]
# This means for every state and action we need to be able to make a desicion.


# aux function to calculate reward. If it chooses the winning result it wins
# 3 points if it guesses the winning team then 1 point eoc 0 points
function reward(chosen_a, real_a)
    if chosen_a == real_a
        return 3
    end
    chosen_result = map(x-> parse(Int32, x), split(action_space[chosen_a], " - "))
    real_result = map(x-> parse(Int32, x), split(action_space[real_a], " - "))
    if chosen_result[1] == chosen_result[2] && real_result[1] == real_result[2]
        return 1
    end
    if argmax(chosen_result) == argmax(real_result) &&
            !(chosen_result[1] == chosen_result[2] || real_result[1] == real_result[2])
        return 1
    end
    return 0
end

# Data from past world cups
df = CSV.read("data/worldcup_data.csv", weakrefstrings=false, nullable=false)


# this are all possible results (actions) for the problem.
action_space = ["$i - $j" for (i,j) in sort(collect(product(0:4 , 0:4)), by=sum)]
df[:action] = string.(min.(df[:home_res], 4)) .* " - " .* string.(min.(df[:away_res], 4))
df = sort(df, cols=[:cup, :match])
# with this we build a space from the data of the match. This is the
# space of the model. In this basic experiment we will choose only
# basic data like goals before the match, victories, etc
function build_space(row)
    vcat(row[:home_victories], row[:away_victories],
         row[:home_losses], row[:away_losses],
         row[:home_goals], row[:away_goals],
         row[:home_goals_against], row[:away_goals_against])
end

# build all states. Order by matchnum
states = hcat(map(build_space, eachrow(df))...)'

# normalize the data to improve neural net performance
# https://papers.nips.cc/paper/6114-weight-normalization-a-simple-reparameterization-to-accelerate-training-of-deep-neural-networks.pdf
train = zeros(states, Float32)
for col in 1:size(states)[2]
    train[:, col] = normalize(states[:, col])
end

# this functions update the parameters of the model
function update()
  λ = 0.005 # Learning Rate
  for p in params(model)
    p.data .-= λ .* p.grad # Apply the update
    p.grad .= 0            # Clear the gradient
  end
end


# build the model.
# This will be our Π: S x A -> [0,1]. It will give us the actions
# based on the current state
model = Chain(
  Dense(8, 15, σ),
  Dense(15, 20, relu),
  Dense(20, 25),
  softmax
  )

# one hot representation of the result of all the matches
real_actions = onehotbatch(df[:action], action_space)'

# auxiliary list to know when to train the model
cups = cumsum(Array(by(df, :cup, df -> DataFrame(N = size(df, 1)))[:N]))
push!(cups, 837)
# vanilla crossentropy loss
# our real loss will be crossentropy * reward
# this will help encourage good rewards and penalize bad ones
loss(x,y) = Flux.crossentropy(model(x), y )

# hyperparameters
ϵ = 0.1 # probability of taking random action
γ = 0.999 # discount of reward

# train the model for 100 episodes
for ep in 1:1000
    total_reward = 0
    c = 1
    for i in 1:836
        # get the result of the match
        real_action = argmax(real_actions[i, :])

        # choose a result from given the current state with ϵ of being random
        # ToDo: Fix to make this part of the loss function
        chosen_action = rand() < ϵ ? rand(1:25) : argmax(model(train[i, :]))

        # get reward of the action
        r = reward(chosen_action, real_action)

        # total reward of the episode
        total_reward += r

        # Calclulate loss multiplied by reward
        # given that we know how many actions we we'll take we can calculate
        # the discounted reward
        back!(loss(train[i,:], real_actions[i,:])*r*γ^(cups[c+1]-i))

        # if the cup is done update values of the model
        # from the gradients
        if i in cups
            c += 1
            update()
        end
    end
    println("Total reward for ep $ep: $total_reward")
    println("Loss for ep $ep: $(loss(train[end,:], real_actions[end,:]))")
end
