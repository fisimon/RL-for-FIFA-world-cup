using Flux.Tracker
using Flux

bandits = [0.2,0,-0.2,-5]

num_bandits = length(bandits)


function pullBandit(bandit)
    result = rand()
    if result > bandit
        return 1
    else
        return -1
    end
end

W = param(ones(num_bandits))

function reward(a)
    pullBandit(bandits[a])
end



λ = 0.001
ϵ = 0.1
loss() = -(log(W[chosen_action])*reward(chosen_action))
chosen_action = rand(1:4)


for i in 1:100000
    chosen_action = rand() < ϵ ? rand(1:num_bandits) : findmax(W.data)[2]
    back!(loss())
    W.data[chosen_action] -= λ*(W.grad[chosen_action])
    W.grad .= 0.0
end

W
