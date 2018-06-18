# Winning a betting pool of the FIFA World Cup using Reinforcement Learning

(![world cup](https://api.fifa.com/api/v1/picture/tournaments-sq-4/254645_w))
It's world cup season and you can feel it everywhere.
I have a bittersweet feeling about it. I'm still crushed about my team not getting to the best competition in professional sports but I love watching intense football nonetheless.

For us with no team in the cup, the best thing we can do (besides cheering against our enemies) is to organize a betting pool with friends and battle our football wits against each other. The betting pool consists of throwing in some money and betting on the results of the matches. There are many rules that can apply to this betting pools. A common example is:

- 3 points for guessing the exact result
- 1 point for guessing the winner of the match
- 0 points any other scenario

In this repository I attempt to build an AI agent that can help me win this betting pool.

There are 3 stages of this project:
1. Getting data to train the model
2. Clean the data
3. Train the model


For the first part you can run a the sypder on the [scrape.py](scrape.py) file using the [scrapy](https://github.com/scrapy/scrapy) framework. This will download the results of all the matches on previous World Cups

For the second part the file [clean.py](clean.py) creates a set of attributes from the data previously extracted.

Finally for the more interesting part there is a Reinforcement Learning model based on a (not to) Deep Policy Network. The idea of this policy is to maximize the points obtained throughout the cup by guessing the results. In my head I imagine this policy taking risky but promising guesses based on pas experience.

This model was built using the Julia Programming Language and the [Flux.jl](https://github.com/FluxML/Flux.jl) framework.

In the [rl.jl](rl.jl) file you can find a more detailed explanation of the model and the training procedures.


Enjoy the World Cup!
