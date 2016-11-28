function [obj] = heuristic(B,heuristicNumber,nSamples)

% This function starts with an incomplete configuration (with or without a 
% given target container) and simulates nSamples and solves these instances
% using one of the 5 heursitics :
% 1: 'EG' Expected Group Assignment
% 2: 'EM' Expected Minmax
% 3: 'ERI' Expected Reshuffling Index
% 4: 'L' Leveling
% 5: 'Rand' Random


%% We intialize the objective function at 0, the number of containers C and the minLevel to compute the
% number of relocations more efficiently
obj=0;
C = sum(sum((B~=0)));

%% We loop on every instance, starts with the initial bay and totalReloc to
% count the relocations for this instance
for i=1:nSamples
    tempB = B;
    totalReloc = 0;
    nContainerLeft = C;
% While the configuration is not empty for random heuristic, or has at most the
% number of stacks containers
    while nContainerLeft > size(B,2) || (heuristicNumber == 5 && nContainerLeft > 0)
% First find (if it is given) or give a target container
        currentMin = min(tempB(tempB~=0));
        [targetTiers,targetStacks] = find(tempB==currentMin);
        if length(targetTiers) > 1;
            tempB = UnvielContainers(tempB,targetTiers,targetStacks,currentMin);
            [tRetrieve,sRetrieve] = find(tempB==min(tempB(tempB~=0)));
        else
            tRetrieve = targetTiers;
            sRetrieve = targetStacks;
        end
% Depending on the heuristic make the appropriate relocations
        switch heuristicNumber
            case 1 % 'EG'
                [tempB,nReloc] = retrieveEG(tempB,tRetrieve,sRetrieve);
            case 2 % 'EM'
                [tempB,nReloc] = retrieveEM(tempB,tRetrieve,sRetrieve);
            case 3 % 'ERI'
                [tempB,nReloc] = retrieveERI(tempB,tRetrieve,sRetrieve);
            case 4 % 'L'
                [tempB,nReloc] = retrieveL(tempB,tRetrieve,sRetrieve);
            case 5 % 'Rand'
                [tempB,nReloc] = retrieveRand(tempB,tRetrieve,sRetrieve);
        end
% Count the number of relocaitons
        totalReloc = totalReloc + nReloc;
% update the number of containers
        nContainerLeft = nContainerLeft - 1;
    end
% If we have the number of stacks containers left, we can compute the
% number of relocations using BlockingLowerBound (if heurstic is not random)
    if heuristicNumber ~= 5
        totalReloc = totalReloc + BlockingLowerBound(tempB);
    end
% Update the expected value function after solving the 
    obj = obj + totalReloc/nSamples;
end