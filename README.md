# This is an 18 Hour hackathon (homework) for SFI GWCSS

## Prompt: Contradictory accounts of an event flow across a group of people.

## The plan:

### Parts

- Agents
- Groups made up of n agents
- There can be m groups

### Init

- Each agent will have an opinion value of ranging from -1 to 1 (uniformly distributed). an opinion of -1 and 1 would be completely contradictory. 0 is assumed to be the "ground truth", and our model concedes that in reality, ground truth may lie somewhere else in the spectrum from -1 to 1.


G is the vector of all commulative global opinion polls.  

H (history size) is the number of timesteps (most recent values of G) that agents are allowed to incorporated intot heir own expression of their opinion.

G is initialized with H opinions drawn from a uniform distribution from -1 to 1. This is so that there is a baseline of Global opinions and we can immediately start adding to Global consensus without some other bootstrapping mechanic. 

W is the proportion of weight given to an agents own position.
W-1 is the weight given to the global position (Global position is avg of the last H elements of G)

PV is the popular vote

GV is the group vote



### Dynamics

#### Each round
- Each agent has a 1/n probability of dying, if they do another will replace it from the same uniform distribution. This assumes an infinite population drawn from a uniform distribution. 
- Each agent has a 1/sqrt(n) of voting
- Voting agents use W and W-1 to calculate their expressed position. 
- Each group position is the average of its group members expressed positions.
- The new/next global position to be appended to G is calculated by average of group positions.
- If a group doesn't vote (has no voting members) Either vote as last round or abstain.


### Parameters to vary for batch runs

- W
- H

### Outcomes of Interest

- Distance of average of last H positions in G from 0
- Distance between mean of all voters estimates (popular vote estimate)
 and global estimate (on that round)
- Other...






### Orig (old)

Opinions (real value between -1 and 1, uniformly distributed)
Groups


initialization

Agents are born (and take on opinions)
Pull however many fake g’s we need from uniform [-1,1]


dynamics

Each agent has a probability 1/n group members of dying
Each agent has a probability 1/sqrt(n group members) of voting
On each timestep, voters take a weighted average of global estimate and own opinions and cast judgment
Group judgment: Mean of voters judgments
World judgment: Historical mean of group judgments over t time steps
If a group doesn’t vote, either
Vote what they did on the last round
Abstain
Parameters to vary: weight on own opinion vs. global estimate; t time steps including in running average


outcomes

Measures of distortion:
Distance of global estimate (on that round) and 0
Distance between average w/in groups w/o incorporating global estimate (uninformed judgments) and incorporating global estimate (informed judgments)
Distance between mean of all voters estimates (popular vote estimate)
and global estimate (on that round)
