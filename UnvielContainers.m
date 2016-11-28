function [newB] = UnvielContainers(tempB,targetTiers,targetStacks,currentMin)

% This function unveils one random order of the next time window
[T,S] = size(tempB);
newB = zeros(T,S);
samplePerm = randperm(length(targetTiers));

for s=1:S
    for t=1:T
        if tempB(t,s) ~=0 && tempB(t,s) ~= currentMin
            newB(t,s) = tempB(t,s) + length(samplePerm);
        end
    end
end
for i=1:length(samplePerm)
    newB(targetTiers(samplePerm(i)),targetStacks(samplePerm(i))) = i;
end