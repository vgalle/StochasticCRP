
%% This file helps to perform the experiments for PBFSA using a modified version of the dataset
% of Ku and Arthanari (2016) in the batch model

folderResults = 'Results/Experiments_2/';

%% Additional lower bound to the blocking lower bound
LowerBoundType = 1;

%% We set the fillRate
fillRate = 0.67;

%% Time Limit 1 hour
timeLimit = 3600;

%% The number of samples for evaluating the heuristics
nSamples = 5000;

%% Merge time windows mergeTimeWindows together
mergeTimeWindows = 2;

%% Error multiplicative with the average number of containers
errorRelative = 0.5;

disp(strcat('Experiment 2 with fillRate=',num2str(fillRate)));

Total_OBJ = zeros(24,14);
setOfInstances = 0;

%% We loop of each Bay size (5 to 10 stacks and 3 to 6 tiers)
for T=3:6
    for S=5:10
        OBJ = zeros(31,11);
        instance = 1;
%% Each bay-size/fillRate has 30 instances. For each of them we use our new
% optimal Algorithm and a similar algorithm than Ku et Arthanaris with the
% projection method
% We solve until both methods do not work
        while instance <= 1
%% Transform the initialBay using nContPerTimeWindow by allowing at most nContPerTimeWindow
% per time window.
            initialBay = readInputFile(S,T,instance,fillRate);
            for j=1:S
                for i=1:T
                    initialBay(i,j) = ceil(initialBay(i,j)/mergeTimeWindows);
                end
            end
            disp(strcat('Solving Problem  ', num2str(instance), ', of size T=',num2str(T),', S=',num2str(S),', and fillRate=',num2str(fillRate)));
            disp(strcat('b'));
            OBJ(instance+1,1) = BlockingLowerBound(initialBay);
            disp(strcat('b_1'));
            OBJ(instance+1,2) = OBJ(instance+1,1) + RollingLowerBound(initialBay,1);
            disp(strcat('b_2'));
            OBJ(instance+1,3) = OBJ(instance+1,1) + RollingLowerBound(initialBay,2);
            disp(strcat('EG'));
            OBJ(instance+1,7) = heuristic(initialBay,1,nSamples);
            disp(strcat('EM'));
            OBJ(instance+1,8) = heuristic(initialBay,2,nSamples);
            disp(strcat('ERI'));
            OBJ(instance+1,9) = heuristic(initialBay,3,nSamples);
            disp(strcat('L'));
            OBJ(instance+1,10) = heuristic(initialBay,4,nSamples);
            disp(strcat('Rand.'));
            OBJ(instance+1,11) = heuristic(initialBay,5,nSamples);
            OBJ(instance+1,6) = errorRelative * OBJ(instance+1,1);
            disp(strcat('Optimal Algorithm with an error of : ', num2str(OBJ(instance+1,6))));
            [OBJ(instance+1,4),~,solvingTime] = PBFSA(initialBay,LowerBoundType,OBJ(instance+1,6),timeLimit);
            if OBJ(instance+1,4) ~= Inf
                OBJ(instance+1,5) = solvingTime;
            else
                OBJ(instance+1,5) = Inf;
            end
            instance = instance + 1;
        end
%% We average over all 30 instances to report the results
        setOfInstances = setOfInstances + 1;
        Total_OBJ(setOfInstances,1) = S;
        Total_OBJ(setOfInstances,2) = T;
        Total_OBJ(setOfInstances,3) = round(S*T*fillRate);
        for c=1:11;
            OBJ(1,c) = mean(OBJ(2:31,c));
            Total_OBJ(setOfInstances,c+3) = OBJ(1,c);
        end

%% We create a outputFileName (for optimal)
        if S < 10
            outputFileName = strcat(folderResults,'0',num2str(S), 'S_0', num2str(T),'T_',num2str(100*fillRate), 'Utilization.csv');
        else
            outputFileName = strcat(folderResults,num2str(S), 'S_0', num2str(T),'T_',num2str(100*fillRate), 'Utilization.csv');
        end

%% We save the file in a csv file with columns for methods and lines for instances
        fid = fopen(outputFileName,'W');
        fprintf(fid,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n','Rows','b','b_1','b_2','opt','time','error','EG','EM','ERI','L','Rand.');
        fprintf(fid,'%s,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n','Average',OBJ(1,1),OBJ(1,2),OBJ(1,3),OBJ(1,4),OBJ(1,5),OBJ(1,6),OBJ(1,7),OBJ(1,8),OBJ(1,9),OBJ(1,10),OBJ(1,11));
        for r=1:30
            fprintf(fid,'%s,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n',num2str(r),OBJ(r+1,1),OBJ(r+1,2),OBJ(r+1,3),OBJ(r+1,4),OBJ(r+1,5),OBJ(r+1,6),OBJ(r+1,7),OBJ(r+1,8),OBJ(r+1,9),OBJ(r+1,10),OBJ(r+1,11));
        end
        fclose(fid);
    end
end

outputFileName = strcat(folderResults, num2str(100*fillRate), 'Utilization_FinalResults.csv');
fid = fopen(outputFileName,'W');
fprintf(fid,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n','S','T','C','b','b_1','b_2','opt','time','error','EG','EM','ERI','L','Rand.');
for r=1:24
    fprintf(fid,'%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n',Total_OBJ(r,1),Total_OBJ(r,2),Total_OBJ(r,3),Total_OBJ(r,4),Total_OBJ(r,5),Total_OBJ(r,6),Total_OBJ(r,7),Total_OBJ(r,8),Total_OBJ(r,9),Total_OBJ(r,10),Total_OBJ(r,11),Total_OBJ(r,12),Total_OBJ(r,13),Total_OBJ(r,14));
end
fclose(fid);