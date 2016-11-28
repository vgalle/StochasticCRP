function [Tree,levelTable] = PBFSA_Rec(Tree,errorGap,LowerBoundType,timeLimit,levelTable,n)
%% This is the user function

if toc > timeLimit
    Tree(n).ValueFunction = Inf;
else
%% Base case, we reached a leaf node
    if Tree(n).Level <= size(Tree(n).Config,2)
        Tree(n).ValueFunction = BlockingLowerBound(Tree(n).Config);
    else
%% Otherwise: Case of a decision node and then chance node
        switch Tree(n).Type
            case 'D'
                [Tree,levelTable] = PBFSA_Decision(Tree,errorGap,LowerBoundType,timeLimit,levelTable,n);
            case 'C'
                [Tree,levelTable] = PBFSA_Chance(Tree,errorGap,LowerBoundType,timeLimit,levelTable,n);
        end
    end
end