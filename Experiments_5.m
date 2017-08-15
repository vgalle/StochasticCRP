

%% This file helps to perform the experiment 5

folderResults = 'Results/Experiments_5/';

% We consider 100 configurations a bay of S=4 stacks and T=4 tiers with W=3
% batches, each with CW=4 containers. We consider that the number of
% containers is C = W*CW, where the containers are distributed randomly in 
% the bay.

%% We set the number of stacks
S = 4;

%% the number of tiers
T = 4;

%% the number of batches
W = 2;

%% the number of containers per batch
CW = 6;

%% the number of instances to consider
nInstances = 100;

%% Additional lower bound to the blocking lower bound
LowerBoundType = 1;

%% Time Limit 1 hour
timeLimit = 3600;

%% Precision of results
roundingPrec = 3;

%% We set the seed to 0 in order to reproduce the experiments with the same instances.
rng(0);

OBJ = zeros(nInstances+1,4);

for instance = 1:nInstances
    B = GenerateIncompleteConfig(S,T,W,CW);
    disp(strcat('Solving Problem  ', num2str(instance)));
    disp(strcat('for the batch model'));
    OBJ(instance+1,1) = round(PBFSA(B,LowerBoundType,0,timeLimit),roundingPrec);
    disp(strcat('for the online model'));
    OBJ(instance+1,2) = round(PBFS_Online(B,LowerBoundType,timeLimit),roundingPrec);
    OBJ(instance+1,3) = OBJ(instance+1,2) - OBJ(instance+1,1);
    if OBJ(instance+1,1) > 0
        OBJ(instance+1,4) = OBJ(instance+1,3)/OBJ(instance+1,1)*100;
    else
        OBJ(instance+1,4) = 0;
    end
    
end
%% We average over all nInstances instances to report the results
OBJ(1,1) = round(mean(OBJ(2:nInstances+1,1)),roundingPrec);
OBJ(1,2) = round(mean(OBJ(2:nInstances+1,2)),roundingPrec);
OBJ(1,3) = round(mean(OBJ(2:nInstances+1,3)),roundingPrec);
OBJ(1,4) = round(OBJ(1,3)/OBJ(1,1)*100,roundingPrec);

%% We create a outputFileName and write the output
outputFileName = strcat(folderResults,'0',num2str(S), 'S_0', num2str(T),'T_0',num2str(W), 'W_0',num2str(CW),'CW.csv');
fid = fopen(outputFileName,'W');
fprintf(fid,'%s,%s,%s,%s,%s\n','Instance','Batch','Online','Difference','%');
fprintf(fid,'%s,%g,%g,%g,%g\n','Average',OBJ(1,1),OBJ(1,2),OBJ(1,3),OBJ(1,4));
for r=1:nInstances
    fprintf(fid,'%s,%g,%g,%g,%g\n',num2str(r),OBJ(r+1,1),OBJ(r+1,2),OBJ(r+1,3),OBJ(r+1,4));
end
fclose(fid);

