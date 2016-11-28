  function [lowerBound] = RollingLowerBound(B,nRolling)
  
% This function gives the potential number of blocking containers that
% need at least one extra relocation after removing the first target
% container.

if nRolling == 0
    lowerBound = 0;
else
%% First we set the size of the problem
    [T,S] = size(B);
    lowerBound = 0;

%% We compute a vector maxminVector(s) for each stack s. It gives the greatest minimum among
% other stacks than s. It is T*S if one of the column is empty.
    height = sum(B~=0);
    maxminVector =zeros(1,S);
    for s=1:S
        for st=1:S
            if st~=s
                if height(st) == 0
                    maxminVector(s) = T*S;
                else
                    sta = B(:,st);
                    maxminVector(s) = max(maxminVector(s),min(sta(sta>0)));
                end
            end
        end
    end
    if max(maxminVector) == T*S
        lowerBound = 0;
%% We find the potential containers to be the next target container
    else
        [Tiers,Stacks] = find(B==min(B(B~=0)));
%% We loop on every potential target container. If it is not on the top,
% We count the number of blocking containers which are blocking the target
% container and for which the maxminVector is smaller (i.e. they will have 
% to be relocated at least one more time). In this case, we had 1 time the
% probability that the next target container is the one considered (in our
% case it is uniform so 1/length(Tiers)).
        for c=1:length(Tiers)
            if height(Stacks(c)) > T - Tiers(c) + 1
                for t=T - height(Stacks(c)) + 1:Tiers(c)-1
                    if B(t,Stacks(c)) > maxminVector(Stacks(c))
                        lowerBound = lowerBound + 1/length(Tiers);
                    end
                end
            end
            NewB = B;
            NewB(1:Tiers(c),Stacks(c)) = 0;
            lowerBound = lowerBound + 1/length(Tiers)*RollingLowerBound(NewB,nRolling-1);
        end
    end
end