function subTree = PBFSA_AllCha(Bay,errorGap)

[T,S] = size(Bay);
%% Then we find the target containers
minTimeWindow = min(Bay(Bay>0));
[Tiers,Stacks] = find(Bay == minTimeWindow);
nContToUnviel = length(Tiers);

%% We compute the number of samples from our algorithm error
if errorGap > 0
    nSamples = ceil(pi/2*(boundsDifference(Bay)/errorGap)^2);
else
    nSamples = Inf;
end
if nSamples <= factorial(nContToUnviel)
    numOffsprings = nSamples;
    permutLoc = zeros(numOffsprings,nContToUnviel);
    for i=1:numOffsprings
        permutLoc(i,:) = randperm(nContToUnviel);
    end
    permutLoc = sortrows(permutLoc);
else
    numOffsprings = factorial(nContToUnviel);
    permutLoc = perms(1:nContToUnviel);
end

subTree = struct('Config', {}, 'Prob', {});
j = 0;

for i = 1:numOffsprings
    if i > 1 && sum(permutLoc(i,:) == permutLoc(i-1,:)) == nContToUnviel
            subTree(j).Prob = subTree(j).Prob + 1/numOffsprings;
    else
        locBay = Bay;
        for target=1:nContToUnviel
            locBay(Tiers(target),Stacks(target)) = minTimeWindow + permutLoc(i,target) - 1;
        end
        locBay = sortrows(locBay')';
        foundSameBay = 0;
        k = 1;
        while k <= j && foundSameBay == 0
            if sum(sum(subTree(k).Config==locBay)) == T*S
                foundSameBay = k;
            end
            k = k + 1;
        end
        if foundSameBay == 0
            j = j + 1;
            subTree(j).Config = locBay;
            subTree(j).Prob = 1/numOffsprings;
        else
            subTree(foundSameBay).Prob = subTree(foundSameBay).Prob + 1/numOffsprings;
        end
    end
end