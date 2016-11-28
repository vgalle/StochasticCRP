function [subTreeAll,nReloc] = PBFSA_AllDec(Bay)

% This function outputs the subTree of all possible decision nodes from a
% chance node with configuration Bay. The subTree has the attributes Config
% and Level (the number of blocking containers)

%% We fix the size of the problem
[T,S] = size(Bay);
[tie,sta] = find(Bay==min(Bay(Bay>0)));
nReloc = sum(Bay(:,sta)~=0) - (T-tie+1);

%% We initialize the configuration at the Bay configuration and the level at
% the number of containers to retrieve
subTree = struct('Config',Bay,'Level',nReloc);
nsub=1;
subTreeAll = struct('Config',{}, 'LowerBound',{});
numOffsprings = 0;
while nsub <= length(subTree)
    subBay = subTree(nsub).Config;
    if subTree(nsub).Level > 0
        for s=1:S 
            subHeight = sum(subBay(:,s)~=0); 
            if s~=sta && subHeight < T % For each blocking container, we consider each non-full stack as a potential destination stack.
                m = length(subTree) + 1;
                subTree(m).Config = subBay;
                subTree(m).Config(T-subHeight,s) = subBay(tie-subTree(nsub).Level,sta);
                subTree(m).Config(tie-subTree(nsub).Level,sta) = 0;
                subTree(m).Level = subTree(nsub).Level - 1;
            end
        end
    else
        subBay(tie,sta) = 0;
        numOffsprings = numOffsprings + 1;
        subTreeAll(numOffsprings).Config = sortrows(subBay')';
    end
    nsub = nsub + 1;
end
            

%% We 'project' the configuration using the sortrows function and check that
% we do not create two offsprings for two identical bays
BaysToCheck = [];
for ns=1:numOffsprings
    identicalBays = false;
    m = 1;
    while m <= length(BaysToCheck) && ~identicalBays
        if sum(sum(subTreeAll(ns).Config==subTreeAll(BaysToCheck(m)).Config)) == T*S
            identicalBays = true;
        end
        m = m + 1;
    end
    if ~identicalBays
        BaysToCheck = [BaysToCheck ns];
    end
end

%% We only keep the nodes that are not duplicated
subTreeAll = subTreeAll(BaysToCheck);

        



