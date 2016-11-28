function [Tree,levelTable] = PBFS_Chance_Online(Tree,LowerBoundType,timeLimit,levelTable,n)

% This function generates all the chance offsprings of the node Tree(n). It
% returns the updated version of Tree with the new decision nodes.

Bay = Tree(n).Config;

subTree = PBFS_AllCha_Online(Bay);

Tree(n).Offsprings = zeros(1,length(subTree));

for p=1:length(subTree)
    m = length(Tree) + 1;
    Tree(m).Type = 'D';
    Tree(m).Config = subTree(p).Config;
    Tree(m).ValueFunction = 0;
    Tree(m).Level = Tree(n).Level;
    Tree(m).Prob = subTree(p).Prob;
    Tree(n).Offsprings(p) = m;
    [Tree,levelTable] = PBFS_Rec_Online(Tree,LowerBoundType,timeLimit,levelTable,m);
end

%% Since the search is BFS we look at each node alternatively
for m = Tree(n).Offsprings
    Tree(n).ValueFunction = Tree(n).ValueFunction + Tree(m).Prob * Tree(m).ValueFunction;
end






