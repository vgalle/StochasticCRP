function [Tree,levelTable] = PBFS_Rec_Online(Tree,LowerBoundType,timeLimit,levelTable,n)
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
                [Tree,levelTable] = PBFS_Decision_Online(Tree,LowerBoundType,timeLimit,levelTable,n);
            case 'C'
                [Tree,levelTable] = PBFS_Chance_Online(Tree,LowerBoundType,timeLimit,levelTable,n);
        end
    end
end