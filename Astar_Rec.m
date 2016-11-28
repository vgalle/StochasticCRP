function [bestIncumbent] = Astar_Rec(B,LowerBoundType,UpperBoundType,bestIncumbent,reloc,T,S)

[B,targetStacks] = Pre_Processing(B);

C = sum(sum(B~=0));

%% Base case, we reached a leaf node
if C == size(B,2)
    if bestIncumbent > reloc + BlockingLowerBound(B);
        bestIncumbent = reloc + BlockingLowerBound(B);
    end
else
    height = sum(B~=0);
    UBlist = Inf(1,S);
    for s=1:S % For each blocking container, we consider each non-full stack as a potential destination stack.
        if s~=targetStacks && height(s) < T
            newB = B;
            newB(T-height(s),s) = B(T-height(targetStacks)+1,targetStacks);
            newB(T-height(targetStacks)+1,targetStacks) = 0;
            UBlist(s) = reloc + 1 + heuristic(newB,UpperBoundType,1);
        end
    end
    [sortedUB,sortedstacks] = sort(UBlist);
    for s=1:S 
        if sortedUB(s) ~= Inf
            newB = B;
            newB(T-height(sortedstacks(s)),sortedstacks(s)) = B(T-height(targetStacks)+1,targetStacks);
            newB(T-height(targetStacks)+1,targetStacks) = 0;
            UB = UBlist(s);
            LB = reloc + 1 + BlockingLowerBound(newB) + RollingLowerBound(newB,LowerBoundType);
            if UB > LB && LB < bestIncumbent
                if bestIncumbent > UB
                    bestIncumbent = UB;
                end
                [bestIncumbent] = Astar_Rec(newB,LowerBoundType,UpperBoundType,bestIncumbent,reloc+1,T,S);
            end
        end
    end
end

