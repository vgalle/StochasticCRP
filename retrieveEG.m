function [B,nReloc] = retrieveEG(B,tRetrieve,sRetrieve)

% This function gives the bay updated after the retrieval of a container
% using the GAH policy at (tRetrieve,sRetrieve).


T = size(B,1);
S = size(B,2);
stack = sRetrieve;
tier=T-tRetrieve+1;
height = sum(B~=0);
virtualMinVector = zeros(1,S);
nReloc = height(stack) - tier;
for s=1:S
    if s~=stack
        stackConsidered = B(:,s);
        if isempty(stackConsidered(stackConsidered~=0))
            virtualMinVector(s) = max(B(B~=0))+1;
        else
            if height(s)==T
                virtualMinVector(s) = 0;
            else
                virtualMinVector(s) = min(stackConsidered(stackConsidered~=0));
            end
        end
    end
end
if nReloc > 0
    blockingContainers = B(T-height(stack)+1:tRetrieve-1,stack);
    Positions = struct();
    for i=1:nReloc
        Positions(blockingContainers(i)).Pos = find(blockingContainers==blockingContainers(i));
    end
    IndexRelocated = zeros(T,S);
    addHeight = zeros(1,S);

    firstPhaseBlocking = sort(blockingContainers,'descend');
    firstPhaseRelocated = zeros(1,length(firstPhaseBlocking));
    for c = 1:length(firstPhaseBlocking)
        if firstPhaseBlocking(c) < max(virtualMinVector)
            targetStack = 0;
            targetMin = Inf;
            for s=1:S
                if virtualMinVector(s)>firstPhaseBlocking(c) && virtualMinVector(s) < targetMin && max(IndexRelocated(:,s)) < Positions(firstPhaseBlocking(c)).Pos(1)
                    targetMin = virtualMinVector(s);
                    targetStack = s;
                end
            end
            if targetStack ~=0
                firstPhaseRelocated(c) = 1;
                addHeight(targetStack) = addHeight(targetStack) + 1;
                IndexRelocated(addHeight(targetStack),targetStack) = Positions(firstPhaseBlocking(c)).Pos(1);
                Positions(firstPhaseBlocking(c)).Pos = Positions(firstPhaseBlocking(c)).Pos(2:length(Positions(firstPhaseBlocking(c)).Pos));
                if height(targetStack) + addHeight(targetStack) == T
                    virtualMinVector(targetStack) = 0;
                else
                    virtualMinVector(targetStack) = firstPhaseBlocking(c);
                end
            end
        end
    end
    for s=1:S
        if s~=stack
            if addHeight(s) > 1
                virtualMinVector(s) = 0;
            elseif height(s) + addHeight(s) == T
                virtualMinVector(s) = 0;
            end
        end
    end
    if sum(addHeight) < length(firstPhaseBlocking)
        secondPhaseBlocking = firstPhaseBlocking(firstPhaseRelocated==0);
        secondPhaseBlocking = sort(secondPhaseBlocking,'ascend');
        for c=1:length(secondPhaseBlocking)
            blockingCont = secondPhaseBlocking(c);
            diffMin = virtualMinVector;
            target_sta = 0;
            for s=1:S
                if s==stack || height(s)+addHeight(s) == T
                    diffMin(s) = - T*S;
                elseif addHeight(s) == 1
                    diffMin(s) = blockingCont - virtualMinVector(s);
                else 
                    diffMin(s) = virtualMinVector(s) - blockingCont;
                end
            end
            if max(diffMin) > 0
                targetMin=min(diffMin(diffMin>0));
                targetHeight=-1;
                for s=1:S
                    if s~=stack && height(s)+addHeight(s) < T
                        if diffMin(s)==targetMin && height(s)+addHeight(s) > targetHeight
                            targetHeight = height(s)+addHeight(s);
                            target_sta = s;
                        end
                    end
                end
            else
                targetMin=max(diffMin);
                targetHeight=-1;
                nMaxMin = T;
                for s=1:S
                    if s~=stack && height(s)+addHeight(s) < T
                        stackConsidered = B(:,s);
                        nMin = 0;
                        if ~isempty(stackConsidered(stackConsidered>0))
                            nMin = sum(stackConsidered == min(stackConsidered(stackConsidered>0)));
                        end
                        if ~isempty(blockingContainers(IndexRelocated(:,s)>0)) && (nMin == 0 || min(blockingContainers(IndexRelocated(:,s)>0)) < min(stackConsidered(stackConsidered>0)))
                            nMin = sum(blockingContainers(IndexRelocated(:,s)>0) == min(blockingContainers(IndexRelocated(:,s)>0)));
                        end
                        if diffMin(s)==targetMin && (nMin<nMaxMin || (nMin==nMaxMin && height(s)+addHeight(s) > targetHeight))
                            nMaxMin = nMin;
                            target_sta = s;
                            targetHeight = height(s)+addHeight(s);
                        end
                    end
                end
            end
            if target_sta == 0
                keyboard
            end
            addHeight(target_sta) = addHeight(target_sta) + 1;
            IndexRelocated(addHeight(target_sta),target_sta) = Positions(secondPhaseBlocking(c)).Pos(1);
            Positions(secondPhaseBlocking(c)).Pos = Positions(secondPhaseBlocking(c)).Pos(2:length(Positions(secondPhaseBlocking(c)).Pos));
            if height(target_sta) + addHeight(target_sta) == T
                virtualMinVector(target_sta) = 0;
            end
        end
    end
    for s=1:S
        newContainers = sort(IndexRelocated(:,s),'descend');
        newContainers = newContainers(newContainers~=0);
        if ~isempty(newContainers)
            for c=length(newContainers):-1:1
                height(s) = height(s) + 1;
                B(T-height(s)+1,s) = blockingContainers(newContainers(c));
            end
        end
    end
end

B(T-height(stack)+1:tRetrieve,stack) = zeros(nReloc+1,1);
