function [tempB] = UnvielContainers_Online(tempB,targetTiers,targetStacks)

% This function unveils one random container of the next time window

sampleTarget = randi(length(targetTiers));
tempB(targetTiers(sampleTarget),targetStacks(sampleTarget)) = -1;