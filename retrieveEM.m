function [B,nReloc] = retrieveEM(B,tRetrieve,sRetrieve)

% This function gives the bay updated after the retrieval of a container
% using the MinMax policy at (tRetrieve,sRetrieve).

%% We initialize the size of the configuration and maximum time window
[T,S] = size(B);
Z = max(B(B~=0));

%% We compute the stack and tier (1 being the lowest) of the target container
stack = sRetrieve;
tier = T - tRetrieve + 1;

%% The height vector
height = sum(B~=0);

%% The number of blocking container
nReloc = height(stack) - tier;

%% The vector of minimums (0 for full columns and the target column; Z+1 for
% empty columns, where Z is the maximum time window)
minVector = zeros(1,S);
for s=1:S
    if s~=stack
        stackConsidered = B(:,s);
        if isempty(stackConsidered(stackConsidered~=0))
            minVector(s) = Z+1;
        else
            if height(s)==T
                minVector(s) = 0;
            else
                minVector(s) = min(stackConsidered(stackConsidered~=0));
            end
        end
    end
end

%% Until the target container is not on the top of its stack
while tier < height(stack)
    blockingContainer = B(T-height(stack)+1,stack);
    target_sta = 0;
    
%% If a 'good' move is possible
    if max(minVector) > blockingContainer
% Find the column with the smallest minimum greater than blockingContainer.
% In case of a tie, we take the heighest column and leftmost column
        targetMin=min(minVector(minVector>blockingContainer));
        targetHeight=-1;
        for s=1:S
            if s~=stack && height(s) < T
                if minVector(s)==targetMin && height(s) > targetHeight
                    targetHeight = height(s);
                    target_sta = s;
                end
            end
        end
    else
%% If no good move is possible
% We take a column with the heighest minimum to delay the next relocation
% the most
        targetMin=max(minVector);
        targetHeight=-1;
        nMaxMin = T;
        for s=1:S
            if s~=stack && height(s) < T
                stackConsidered = B(:,s);
                nMin = sum(stackConsidered(stackConsidered==targetMin))/max(minVector);
% In case of a tie, we take the one with the minimum number of containers
% with the time window of targetMin (in order to delay the next relocation the most
% on expectation) and in case of a tie we take the heighest stack and then
% the leftmost one
                if minVector(s)==targetMin && (nMin<nMaxMin || (nMin==nMaxMin && height(s) > targetHeight))
                    nMaxMin = nMin;
                    target_sta = s;
                    targetHeight = height(s);
                end
            end
        end
    end
% compute the target tier
    target_tier = targetHeight+1;
% Update the configuration, the minVector and the vector of height
    B(T-target_tier+1,target_sta) = B(T-height(stack)+1,stack);
    if minVector(target_sta)~=0
        if target_tier~=T
            minVector(target_sta) = min(minVector(target_sta),blockingContainer);
        else
% If column is full, its minimum is 0 so it will never be selected
            minVector(target_sta) = 0;
        end
    else
% If the column was empty, the new minimum is the blcoking container
        minVector(target_sta) = blockingContainer;
    end
    height(target_sta) = height(target_sta) + 1;
    B(T-height(stack)+1,stack) = 0;
    height(stack) = height(stack) - 1;
end

%% Empty the target container
B(T-tier+1,stack) = 0;