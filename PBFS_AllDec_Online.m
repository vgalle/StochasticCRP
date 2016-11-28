function subTreeAll = PBFS_AllDec_Online(Bay)

% This function outputs the subTree of all possible decision nodes from a
% chance node with configuration Bay. The subTree has the attributes Config
% and Level (the number of blocking containers)

%% We fix the size of the problem
[T,S] = size(Bay);

%% We initialize the configuration at the Bay configuration and the level at
% the number of containers to retrieve
subTree = struct('Config',Bay,'Level',min(sum(sum(Bay<0)),sum(sum(Bay~=0))-S), 'LowerBound',0 , 'Reloc', 0);
nsub=1;
subTreeAll = struct('Config',{}, 'LowerBound',{}, 'Reloc',{});
numOffsprings = 0;
while nsub <= length(subTree)
    subBay = subTree(nsub).Config;
    if subTree(nsub).Level > 0
        [tie,sta] = find(subBay==min(min(subBay))); % First we find the target container
        height = sum(subBay~=0);
        if tie == T - height(sta) + 1
            m = length(subTree) + 1;
            subTree(m).Config = subBay;
            subTree(m).Config(tie,sta) = 0;
            subTree(m).Level = subTree(nsub).Level - 1;
            subTree(m).Reloc = subTree(nsub).Reloc;
        else
            for s=1:S % For each blocking container, we consider each non-full stack as a potential destination stack.
                if s~=sta && height(s) < T
                    m = length(subTree) + 1;
                    subTree(m).Config = subBay;
                    subTree(m).Config(T-height(s),s) = subBay(T-height(sta)+1,sta);
                    subTree(m).Config(T-height(sta)+1,sta) = 0;
                    subTree(m).Reloc = subTree(nsub).Reloc + 1;
                    if(tie == T - height(sta) + 2)
                        subTree(m).Config(tie,sta) = 0;
                        subTree(m).Level = subTree(nsub).Level - 1;
                    else
                        subTree(m).Level = subTree(nsub).Level;
                    end
                end
            end
        end
    else
        numOffsprings = numOffsprings + 1;
        minOfBay = min(min(subBay));
        if minOfBay < 0
            for t=1:T
                for s=1:S
                    if subBay(t,s) ~= 0
                        subBay(t,s) = subBay(t,s) - minOfBay + 1;
                    end
                end
            end
        end
        subTreeAll(numOffsprings).Config = sortrows(subBay')';
        subTreeAll(numOffsprings).Reloc = subTree(nsub).Reloc;
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
            if subTreeAll(ns).Reloc < subTreeAll(BaysToCheck(m)).Reloc;
                BaysToCheck(m) = ns;
            end
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

        



