
%% This file helps to perform the experiments for PBFS using the dataset
% of Ku and Arthanari (2016) in the online model

folderResults = 'Results/Experiments_3/';

%% We set the fillRate
fillRate = 0.67;

%% Time Limit 1 hour
timeLimit = 3600;

%% The number of samples for evaluating the heuristics
nSamples = 5000;

Total_OBJ = zeros(24,13);
setOfInstances = 0;

disp(strcat('Experiment 3 with fillRate=',num2str(fillRate)));

%% We loop of each Bay size (5 to 10 stacks and 3 to 6 tiers)
for T=3:6
    for S=5:10
        OBJ = zeros(31,10);
        instance = 1;
%% Each bay-size/fillRate has 30 instances. For each of them we use our new
% optimal Algorithm and a similar algorithm than Ku et Arthanaris with the
% projection method
% We solve until both methods do not work
        while instance <= 30
            initialBay = readInputFile(S,T,instance,fillRate);
            disp(strcat('Solving Problem  ', num2str(instance), ', of size T=',num2str(T),', S=',num2str(S),', and fillRate=',num2str(fillRate)));
            disp(strcat('b'));
            OBJ(instance+1,1) = BlockingLowerBound(initialBay);
            disp(strcat('b_1'));
            OBJ(instance+1,2) = OBJ(instance+1,1) + RollingLowerBound(initialBay,1);
            disp(strcat('b_2'));
            OBJ(instance+1,3) = OBJ(instance+1,1) + RollingLowerBound(initialBay,2);
            disp(strcat('EG'));
            OBJ(instance+1,6) = heuristic_Online(initialBay,1,nSamples);
            disp(strcat('EM'));
            OBJ(instance+1,7) = heuristic_Online(initialBay,2,nSamples);
            disp(strcat('ERI'));
            OBJ(instance+1,8) = heuristic_Online(initialBay,3,nSamples);
            disp(strcat('L'));
            OBJ(instance+1,9) = heuristic_Online(initialBay,4,nSamples);
            disp(strcat('Rand.'));
            OBJ(instance+1,10) = heuristic_Online(initialBay,5,nSamples);
            disp(strcat('Optimal Algorithm'));
            [OBJ(instance+1,4),~,solvingTime] = PBFS_Online(initialBay,1,timeLimit);
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
        for c=1:10;
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
        fprintf(fid,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n','Rows','b','b_1','b_2','opt','time','EG','EM','ERI','L','Rand.');
        fprintf(fid,'%s,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n','Average',OBJ(1,1),OBJ(1,2),OBJ(1,3),OBJ(1,4),OBJ(1,5),OBJ(1,6),OBJ(1,7),OBJ(1,8),OBJ(1,9),OBJ(1,10));
        for r=1:30
            fprintf(fid,'%s,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n',num2str(r),OBJ(r+1,1),OBJ(r+1,2),OBJ(r+1,3),OBJ(r+1,4),OBJ(r+1,5),OBJ(r+1,6),OBJ(r+1,7),OBJ(r+1,8),OBJ(r+1,9),OBJ(r+1,10));
        end
        fclose(fid);
    end
end

outputFileName = strcat(folderResults, num2str(100*fillRate), 'Utilization_FinalResults.csv');
fid = fopen(outputFileName,'W');
fprintf(fid,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n','S','T','C','b','b_1','b_2','opt','time','EG','EM','ERI','L','Rand.');
for r=1:24
    fprintf(fid,'%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n',Total_OBJ(r,1),Total_OBJ(r,2),Total_OBJ(r,3),Total_OBJ(r,4),Total_OBJ(r,5),Total_OBJ(r,6),Total_OBJ(r,7),Total_OBJ(r,8),Total_OBJ(r,9),Total_OBJ(r,10),Total_OBJ(r,11),Total_OBJ(r,12),Total_OBJ(r,13));
end
fclose(fid);