# StochasticCRP

This repository contains the instances, code and results published in "Stochastic Container Relocation Problem" (2017).

Instances are stored in crptw_instance where there are subfolder per size (for e.g. 0503 is for S=5, T=3)
Inside each subfolder, there are 60 instances. 30 for 50% fill rate and 30 for 67% fill rate.
Each instance is named such as T271014_0503_001: 50% fill rate, S=5, T=3, first instance
or T281014_0503_030: 67% fill rate, S=5, T=3, last instance (30th)
The function readInputFile.m reads these files and translates these into arrays. Please see each subfolder for the structure of each file.

In order to run the exact same experiments, use scripts Experiments_x to run experiment x.
The input parameters are
LowerBoundType = 1; %% Lower bounds used in PBFS and PBFSA
fillRate = 0.5; %% fill Rate to test on
timeLimit = 3600; %% time limit for PBFS and PBFSA
nSamples = 5000; %% number of samples for evaluating the heuristics
Only in experiment 2
mergeTimeWindows = 2; %% Merge time windows mergeTimeWindows together
errorRelative = 0.5; %% Error multiplicative with the average number of containers used in PBFSA

Before running any experiments, create the "Results" folder as well as one subfolder per experiment you want to run
Results/Experiments_1/, Results/Experiments_2/, Results/Experiments_3/, Results/Experiments_4/ and Results/Experiments_5/

Each sample code has comments. For any question, contact vgalle@mit.edu
