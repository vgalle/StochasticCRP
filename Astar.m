function [bestIncumbent] = Astar(B,LowerBoundType,UpperBoundType)

%% We initialize the Tree structure. The root node is a chance node if the target
% container is provided, otherwise it is a decision node

reloc = 0;
[T,S] = size(B);

bestIncumbent = reloc + heuristic(B,UpperBoundType,1);

[bestIncumbent] = Astar_Rec(B,LowerBoundType,UpperBoundType,bestIncumbent,reloc,T,S);
