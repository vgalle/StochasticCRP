function [B,nReloc] = retrieveRand(B,tRetrieve,sRetrieve)

% This function gives the bay updated after the retrieval of a container
% using the random policy at (tRetrieve,sRetrieve).

%% We initialize the size of the configuration
[T,S] = size(B);

%% We compute the stack and tier (1 being the lowest) of the target container
stack = sRetrieve;
tier = T - tRetrieve + 1;

%% The height vector
height = sum(B~=0);

%% The number of blocking container
nReloc = height(stack) - tier;

%% Until the target container is not on the top of its stack
while tier < height(stack)
% Only consider stacks that are not full neither the stack of the target
% container
    height_loc = height;
    height_loc(stack) = T+1;
    stacksToConsider = zeros(1,S);
    for s=1:S
        if height_loc(s) < T
            stacksToConsider(s)=s;
        end
    end
    stacksToConsider = stacksToConsider(stacksToConsider~=0);
% Sample uniformely one of them
    target_sta = stacksToConsider(randi(size(stacksToConsider,2)));
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