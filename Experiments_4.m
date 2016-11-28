
%% This file helps to perform the experiments for the no-information case in order to conjecture
% the optimality of leveling heuristic

folderResults = 'Results/Experiments_4/';

%% We set the fillRate
fillRate = 0.67;

%% Time Limit 1 hour
timeLimit = 3600;

%% The number of samples for evaluating the heuristics
nSamples = 10000;

Total_OBJ = zeros(24,5);
setOfInstances = 0;

disp(strcat('Experiment 4 with fillRate=',num2str(fillRate)));

%% We loop of each Bay size (5 to 10 stacks and 3 to 6 tiers)
for T=3:6
    for S=5:10
        OBJ = zeros(31,2);
        cannotSolve = false;
        instance = 1;
%% Each bay-size/fillRate has 30 instances. For each of them we use our new
% optimal Algorithm and a similar algorithm than Ku et Arthanaris with the
% projection method
% We solve until both methods do not work
        while instance <= 30
            initialBay = readInputFile(S,T,instance,fillRate);
            for j=1:S
                for i=1:T
                    if initialBay(i,j) > 0
                        initialBay(i,j) = 1;
                    end
                end
            end
            disp(strcat('Solving Problem  ', num2str(instance), ', of size T=',num2str(T),', S=',num2str(S),', and fillRate=',num2str(fillRate)));
            disp(strcat('L'));
            OBJ(instance+1,2) = heuristic_Online(initialBay,4,nSamples);
            disp(strcat('Optimal Algorithm'));
            if ~cannotSolve
                [OBJ(instance+1,1),~,solvingTime] = PBFS_Online(initialBay,1,timeLimit);
                if OBJ(instance+1,1) == Inf
                    cannotSolve = true;
                end
            else
                OBJ(instance+1,1) == Inf
            end
            instance = instance + 1;
        end
%% We average over all 30 instances to report the results
        setOfInstances = setOfInstances + 1;
        Total_OBJ(setOfInstances,1) = S;
        Total_OBJ(setOfInstances,2) = T;
        Total_OBJ(setOfInstances,3) = round(S*T*fillRate);
        for c=1:2;
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
        fprintf(fid,'%s,%s,%s\n','Rows','opt','L');
        fprintf(fid,'%s,%g,%g\n','Average',OBJ(1,1),OBJ(1,2));
        for r=1:30
            fprintf(fid,'%s,%g,%g\n',num2str(r),OBJ(r+1,1),OBJ(r+1,2));
        end
        fclose(fid);
    end
end

outputFileName = strcat(folderResults, num2str(100*fillRate), 'Utilization_FinalResults.csv');
fid = fopen(outputFileName,'W');
fprintf(fid,'%s,%s,%s,%s,%s\n','S','T','C','opt','L');
for r=1:24
    fprintf(fid,'%g,%g,%g,%g,%g\n',Total_OBJ(r,1),Total_OBJ(r,2),Total_OBJ(r,3),Total_OBJ(r,4),Total_OBJ(r,5));
end
fclose(fid);