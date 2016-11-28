function [Tree,levelTable] = PBFS_Decision_Online(Tree,LowerBoundType,timeLimit,levelTable,n)

% This function creates the chance offspring of a decision node n

%% We intialize the configuration and the size of it
Bay = Tree(n).Config;
[T,S] = size(Bay);

%% First we generate all possible offsprings
subTreeAll = PBFS_AllDec_Online(Bay);

for ns=1:length(subTreeAll)
    if LowerBoundType > 0
        subTreeAll(ns).LowerBound = subTreeAll(ns).Reloc + BlockingLowerBound(subTreeAll(ns).Config) + RollingLowerBound(subTreeAll(ns).Config,LowerBoundType);
    else
        subTreeAll(ns).LowerBound = subTreeAll(ns).Reloc + BlockingLowerBound(subTreeAll(ns).Config);
    end
end

[~,newOrder] = sort([subTreeAll(:).LowerBound],'Ascend');
subTree = struct('Config',{}, 'LowerBound',{}, 'Reloc',{});
for ns=1:length(subTreeAll)
    subTree(ns).Config = subTreeAll(newOrder(ns)).Config;
    subTree(ns).LowerBound = subTreeAll(newOrder(ns)).LowerBound;
    subTree(ns).Reloc = subTreeAll(newOrder(ns)).Reloc;
end

%% IDOffsprings helps to link a parent with its offsprings, specially if the offsprings
% already exists at this level
IDOffsprings = zeros(1,length(subTree));
nextLevel = sum(sum(subTreeAll(1).Config~=0)) + 1;
BaysToCompare = levelTable(nextLevel).ID;
minCost = Inf;
for p=1:length(subTree)
    if subTree(p).LowerBound < minCost
        foundSameBay = 0;
        q = 1;
        while q <= length(BaysToCompare) && foundSameBay == 0
            if sum(sum(subTree(p).Config==Tree(BaysToCompare(q)).Config)) == T*S
                foundSameBay = BaysToCompare(q);
            end
            q = q + 1;
        end
%% If the node was not already created we do so
        if foundSameBay == 0
            m = length(Tree) + 1;
            Tree(m).Type = 'C';
            Tree(m).Config = subTree(p).Config;
            Tree(m).ValueFunction = 0;
            Tree(m).Level = nextLevel - 1;
            IDOffsprings(p) = m;
            BaysToCompare = [BaysToCompare m];
            levelTable(nextLevel).ID = [levelTable(nextLevel).ID m];
            [Tree,levelTable] = PBFS_Rec_Online(Tree,LowerBoundType,timeLimit,levelTable,m);
            if subTree(p).Reloc + Tree(m).ValueFunction < minCost
                minCost = subTree(p).Reloc + Tree(m).ValueFunction;
                Tree(n).Reloc = subTree(p).Reloc;
            end
        else
            IDOffsprings(p) = foundSameBay;
        end
        if subTree(p).Reloc + Tree(IDOffsprings(p)).ValueFunction < minCost
            minCost = subTree(p).Reloc + Tree(IDOffsprings(p)).ValueFunction;
            Tree(n).Reloc = subTree(p).Reloc;
        end
    end
end
%% We set the offsprings to IDOffsprings
IDOffsprings = IDOffsprings(IDOffsprings~=0);
Tree(n).Offsprings = IDOffsprings;
Tree(n).ValueFunction = minCost;


