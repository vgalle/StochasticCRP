  function [lowerBound] = BlockingLowerBound(B)
% This function gives an expected lower bound on the number of relocations
% given a incomplete bay B by counting the expected number of blocking
% containers.

%% We initialize the size of the problem and the height vector
[T,S] = size(B);
lowerBound=0;
height = sum(B~=0);

%% We loop on every stack
for s=1:S
    if height(s)>1
% For every container higher than the second tier, this container can
% either block for sure or it can be blocking with some non-zero, non-one
% probability
        for t=2:height(s)
            sureBlocking = 0;
            potentialBlocking = 0;
            for u=1:t-1
% either be blocking with probability one (if a container with a strictly smaller
% time window is below)
                if B(T-t+1,s)>B(T-u+1,s)
                    sureBlocking = 1;
% or with probability 1/(c+1) where c is the number
% of containers below with the exact same time window.
                elseif B(T-t+1,s)==B(T-u+1,s)
                    potentialBlocking = potentialBlocking + 1;
                end
            end
            if sureBlocking == 1
                lowerBound = lowerBound + 1;
            elseif sureBlocking == 0 && potentialBlocking>0
                lowerBound = lowerBound + potentialBlocking/(potentialBlocking+1);
            end
        end
    end
end
    