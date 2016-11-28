function [B,nReloc] = retrieveERI(B,tRetrieve,sRetrieve)

% This function gives the bay updated after the retrieval of a container
% using the ERI policy at (tRetrieve,sRetrieve).

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
% the topmost blocking container
    blockingContainer = B(T-height(stack)+1,stack);
    bestERI = T;
    target_sta = 0;
% We start with a large ERI and loop on every stack except the one of the
% target container and full stacks
    for s=1:S
        if height(s) < T && s~=stack
% We compute the ERI of this column
            ERI=0;
            for t=1:height(s)
                if B(T-t+1,s) < blockingContainer
                    ERI = ERI + 1;
                elseif B(T-t+1,s) == blockingContainer
                    ERI = ERI + 1/2;
                end
            end
% If the ERI is strictly better than the one selected or equal but the
% stack has more containers then we update the destination stack. Note that
% ties are borken arbitrarely by taking the leftmost stack
            if ERI < bestERI || (ERI == bestERI && height(target_sta) < height(s))
                target_sta = s;
                bestERI = ERI;
            end
        end
    end
% compute the target tier
    target_tier = height(target_sta)+1;
% Update the configuration and the vector of height
    B(T-target_tier+1,target_sta) = blockingContainer;
    height(target_sta) = height(target_sta) + 1;
    B(T-height(stack)+1,stack) = 0;
    height(stack) = height(stack) - 1;
end

%% Empty the target container
B(T-tier+1,stack) = 0;