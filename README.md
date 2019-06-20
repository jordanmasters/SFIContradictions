# This is an 18 Hour hackathon (homework) for SFI GWCSS

## Prompt: Contradictory accounts of an event flow across a group of people.

## Methods:

Netlogo was utilized to build and run grid search (Behavior Space) over the model. Python was used for data analysis. An outline of the model is presented below.

### Parts

- World: a discrete square grid, boundaries (periodic or not) and world size are unimportant. 

- Groups: Groups are invisible stationary agents and are placed relative to world size.

- Agent: Agents are also stationary, and are assigned membership to a group. 

### Init

- World is created with size (L x L)

- M group agents are created (rows * columns) and placed in square grid relative to size of the world. Their main function is to position groups in space for easy viewing.

- N agents are added in a circle around each invisible group agent. Agents are assigned a random float value (my-position) from [-1,1], from a uniform distribution.  

- C (Consensus) is initially initialized as an empty list - it will become a vector of global positions observed at each time step.

- PC (Percieved Concensus) is the window size of most recent global position observations in C that agents are allowed to see. This value is used to re-initialize (bootstrap) C with PC random float value observations drawn from [-1,1], from a uniform distribution.

- SW (Self Weight) is a value from [0,1] that represents the weight agents give to their own position when broadcasting their vote. (1 - SW) is the weight given to the global position.

- PL (Probability to live) is the probability that each agent will continue to live on each tick.

- PV (Probability to vote) is the probability that each agent will broadcast their vote on the current round. This is set to 1/sqrt(N)

- mandatory-voting: If on, all agents vote each round. If off, agents vote with PV
 
### Dynamics

Each round (tick):

- Draw voters: Decide which agents will vote this round using PV

- Calculate votes:
	- All agents calculate their broadcast position by combining their position with the last PC values of C as follows.
		- (my-position * SW) + (C[-PC:] * (1-SW)) -------- [-PC:] is python notation...
	- All groups calculate their position by taking the average of all voting agent position from their given group.
	- Global position is calculated by taking the average of all group positions. This value is appended to C
	- Popular vote is calculated by taking the average of all voting agents in the system.

### Outcomes of Interest

- Distance between popular vote and the global consensus.

### Parameters to vary for batch runs

- SW
- PC
- M
- N
- mandatory-voting