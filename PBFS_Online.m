function [obj,Tree,solvingTime] = PBFS_Online(B,LowerBoundType,timeLimit)


%% B is the configuration for which we are looking the expected number of relocations.
% errorGap is an upper bound on the absolute error on expectation of the algorithm
% LowerBoundType can be an integer for the rolling lowerBound.
% timeLimit is the time Limit after which we stop computing the solution
% and return Inf if no solution has been found

%% We initialize the Tree structure. The root node is a chance node if the target
% container is provided, otherwise it is a decision node
B = sortrows(B')';
[~,S] = size(B);
C = sum(sum(B~=0));
[tier,~] = find(B<0);

if ~isempty(tier)
    Tree = struct('Type','D','Config',B,'ValueFunction',0,'Offsprings',[],'Level',C,'Prob',1,'Reloc',[]);
else
    Tree = struct('Type','C','Config',B,'ValueFunction',0,'Offsprings',[],'Level',C,'Prob',[],'Reloc',0);
end

%% Level tables taht gives all the ids of nodes at a given level
levelTable = struct('ID',{});
for lev = S:C-1
    levelTable(lev+1).ID = [];
end

%% Start the timer
tic
Tree = PBFS_Rec_Online(Tree,LowerBoundType,timeLimit,levelTable,1);

%% Compute the solving time after the algorithm is done
solvingTime = toc;

%% If the time limit is not reached we compute the value of the nodes from the tree created beforehand
if solvingTime > timeLimit
    obj = Inf;
else
    obj = Tree(1).ValueFunction;
end


