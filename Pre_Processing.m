function [Bay,targetStacks] = Pre_Processing(Bay)

%% This function retrieves all containers until either The bay has S containers
% or the target container is not unique
[T,S] = size(Bay);
canRetrieve = true;
height = sum(Bay~=0);
C = sum(height);
while canRetrieve
    currentMin = min(Bay(Bay~=0));
    [targetTiers,targetStacks] = find(Bay==currentMin);
    if C >=S && length(targetTiers) == 1 && height(targetStacks) == T - targetTiers + 1
        Bay(targetTiers,targetStacks) = 0;
        height(targetStacks) = height(targetStacks) - 1;
        C = C - 1;
    else
        canRetrieve = false;
    end
end