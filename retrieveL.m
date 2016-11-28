function [B,nReloc] = retrieveL(B,tRetrieve,sRetrieve)

% This function gives the bay updated after the retrieval of a container
% using the leveling policy at (tRetrieve,sRetrieve).

%% We initialize the maximum height
T = size(B,1);

%% We compute the stack and tier (1 being the lowest) of the target container
stack = sRetrieve;
tier=T-tRetrieve+1;

%% The height vector
height = sum(B~=0);

%% The number of blocking container
nReloc = height(stack) - tier;

%% Until the target container is not on the top of its stack
while tier < height(stack)
% we create height_loc a vector of height in order to not consider the
% stack of the target container
    height_loc = height;
    height_loc(stack) = T+1;
% Select the stacks with lowest height
    [~,target_sta] = find(height_loc==min(height_loc));
% Break ties by choosing the leftmost column
    target_sta = target_sta(1);
% compute the target tier
    target_tier = height(target_sta)+1;
% Update the configuration and the vector of height
    B(T-target_tier+1,target_sta) = B(T-height(stack)+1,stack);
    height(target_sta) = height(target_sta) + 1;
    B(T-height(stack)+1,stack) = 0;
    height(stack) = height(stack) - 1;
end

%% Empty the target container
B(T-tier+1,stack) = 0;