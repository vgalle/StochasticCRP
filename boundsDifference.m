function [diffBounds] = boundsDifference(B)
    [T,S] = size(B);
    minLowerBound = 0;
    maxLowerBound = 0;
    for s=1:S
        for t=2:T
            block = B(T-t+1,s);
            if block ~= 0
                isBlockingmin = false;
                isBlockingmax = false;
                tloc = 1;
                while tloc <= t-1 && ~isBlockingmin
                    if block > B(T-tloc+1,s)
                        isBlockingmin = true;
                    end
                    if block >= B(T-tloc+1,s)
                        isBlockingmax = true;
                    end
                    tloc = tloc + 1;
                end
                if isBlockingmin
                    minLowerBound = minLowerBound + 1;
                    maxLowerBound = maxLowerBound + 1;
                elseif isBlockingmax
                    maxLowerBound = maxLowerBound + 1;
                end
            end
        end
    end
    C = sum(sum(B>0));
    maxLowerBound = (2*ceil(C/S)-1)*maxLowerBound;
    maxLowerBound = min(maxLowerBound,(C-S)*(T-1)+S);
    diffBounds = maxLowerBound - minLowerBound;
end