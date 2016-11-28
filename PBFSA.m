function [obj,Tree,solvingTime] = PBFSA(B,LowerBoundType,errorGap,timeLimit)


%% B is the configuration for which we are looking the expected number of relocations.
% errorGap is an upper bound on the absolute error on expectation of the algorithm
% LowerBoundType can be an integer for the rolling lowerBound.
% timeLimit is the time Limit after which we stop computing the solution
% and return Inf if no solution has been found

[T,S] = size(B);
C = sum(sum(B~=0));

%% We split the error equally through each level we will have to explore.
% The number of levels to explore is computed with nTimeWindowsExp
Bloc = B.*(B>=0);
contPerZone = histc(reshape(Bloc,1,T*S),unique(Bloc));
nTimeWindowsExp = 0;
nLoc = C;
while nTimeWindowsExp < length(contPerZone) && nLoc >= S
    nTimeWindowsExp = nTimeWindowsExp + 1;
    nLoc = nLoc - contPerZone(nTimeWindowsExp);
end
errorGapLoc = errorGap/nTimeWindowsExp;



%% We initialize the Tree structure. The root node is a chance node if the target
% container is provided, otherwise it is a decision node
for s=1:S
    for t=1:T
        if B(t,s)>1
            B(t,s) = sum(contPerZone(2:B(t,s))) + 1;
        end
    end
end
B = sortrows(B')';

Tree = struct('Type','C','Config',B,'ValueFunction',0,'Offsprings',[],'Level',C,'Prob',[],'Reloc',0);


%% Level tables taht gives all the ids of nodes at a given level
levelTable = struct('ID',{});
for lev = S:C-1
    levelTable(lev+1).ID = [];
end

%% Start the timer
tic
Tree = PBFSA_Rec(Tree,errorGapLoc,LowerBoundType,timeLimit,levelTable,1);

%% Compute the solving time after the algorithm is done
solvingTime = toc;

%% If the time limit is not reached we compute the value of the nodes from the tree created beforehand
if solvingTime > timeLimit
    obj = Inf;
else
    obj = Tree(1).ValueFunction;
end


