function subTree = PBFS_AllCha_Online(Bay)

[T,S] = size(Bay);
%% Then we find the target container
minTimeWindow = min(Bay(Bay>0));
[Tiers,Stacks] = find(Bay == minTimeWindow);
numOffsprings = length(Tiers);

subTree = struct('Config', {}, 'Prob', {});
j = 0;

for target = 1:numOffsprings
    locBay = Bay;
    locBay(Tiers(target),Stacks(target)) = - 1;
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