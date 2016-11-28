function [Tree,levelTable] = PBFSA_Decision(Tree,errorGap,LowerBoundType,timeLimit,levelTable,n)

% This function creates the chance offspring of a decision node n

%% We intialize the configuration and the zise of it
Bay = Tree(n).Config;
[T,S] = size(Bay);
C = sum(sum(Bay~=0));

if C == length(unique(Bay))-1
    Tree(n).ValueFunction = Astar(Bay,LowerBoundType,2); %% Using MinMax heuristic in Astar
else
%% First we generate all possible offsprings
    [subTreeAll,nReloc] = PBFSA_AllDec(Bay);

    for ns=1:length(subTreeAll)
        subTreeAll(ns).LowerBound = nReloc + BlockingLowerBound(subTreeAll(ns).Config) + RollingLowerBound(subTreeAll(ns).Config,LowerBoundType);
    end

    [~,newOrder] = sort([subTreeAll(:).LowerBound],'Ascend');
    subTree = struct('Config',{}, 'LowerBound',{});
    for ns=1:length(subTreeAll)
        subTree(ns).Config = subTreeAll(newOrder(ns)).Config;
        subTree(ns).LowerBound = subTreeAll(newOrder(ns)).LowerBound;
    end

%% IDOffsprings helps to link a parent with its offsprings, specially if the offsprings
% already exists at this level
    IDOffsprings = zeros(1,length(subTree));
    BaysToCompare = levelTable(C).ID;
    if length(find(subTree(1).Config==min(subTree(1).Config(subTree(1).Config>0)))) == 1
        nextType = 'D';
    else
        nextType = 'C';
    end
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
                Tree(m).Type = nextType;
                Tree(m).Config = subTree(p).Config;
                Tree(m).ValueFunction = 0;
                Tree(m).Level = C - 1;
                IDOffsprings(p) = m;
                BaysToCompare = [BaysToCompare m];
                levelTable(C).ID = [levelTable(C).ID m];
                [Tree,levelTable] = PBFSA_Rec(Tree,errorGap,LowerBoundType,timeLimit,levelTable,m);
                if nReloc + Tree(m).ValueFunction < minCost
                    minCost = nReloc + Tree(m).ValueFunction;
                    Tree(n).Reloc = nReloc;
                end
            else
                IDOffsprings(p) = foundSameBay;
                if nReloc + Tree(IDOffsprings(p)).ValueFunction < minCost
                    minCost = nReloc + Tree(IDOffsprings(p)).ValueFunction;
                    Tree(n).Reloc = nReloc;
                end
            end
        end
    end
%% We set the offsprings to IDOffsprings
    IDOffsprings = IDOffsprings(IDOffsprings~=0);
    Tree(n).Offsprings = IDOffsprings;
    Tree(n).ValueFunction = minCost;
end


