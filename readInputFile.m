function initialBay = readInputFile(S,T,instance,fillRate)

% This function outputs the configuration in the usual format from the data
% set of Ku et Arthanari (2016) for a given stack, tier size, the number of
% the instance and the fillrate (0.5 or 0.67)

%% First we find the folder and the file that we want to import
if S < 10
    foldername = strcat('crptw_instance/0',num2str(S), '0', num2str(T),'/');
    if fillRate == 0.5
        if instance < 10
            filename = strcat(foldername,'T271014_0', num2str(S), '0', num2str(T), '_00', num2str(instance), '.txt');
        else
            filename = strcat(foldername,'T271014_0', num2str(S), '0', num2str(T), '_0', num2str(instance), '.txt');
        end
    elseif fillRate == 0.67
        if instance < 10
            filename = strcat(foldername,'T281014_0', num2str(S), '0', num2str(T), '_00', num2str(instance), '.txt');
        else
            filename = strcat(foldername,'T281014_0', num2str(S), '0', num2str(T), '_0', num2str(instance), '.txt');
        end
    end  
else
    foldername = strcat('crptw_instance/',num2str(S), '0', num2str(T),'/');
    if fillRate == 0.5
        if instance < 10
            filename = strcat(foldername,'T271014_', num2str(S), '0', num2str(T), '_00', num2str(instance), '.txt');
        else
            filename = strcat(foldername,'T271014_', num2str(S), '0', num2str(T), '_0', num2str(instance), '.txt');
        end
    elseif fillRate == 0.67
        if instance < 10
            filename = strcat(foldername,'T281014_', num2str(S), '0', num2str(T), '_00', num2str(instance), '.txt');
        else
            filename = strcat(foldername,'T281014_', num2str(S), '0', num2str(T), '_0', num2str(instance), '.txt');
        end
    end  
end

%% We import all the information from the file, including the height of
% columns
RawConfiguration = dlmread(filename,'',1,0);
height = RawConfiguration(:,3);

%% We construct the actual configuration from the raw text file.
initialBay = zeros(T,S);
for s=1:S
    for t=1:height(s)
        initialBay(T-t+1,s) = RawConfiguration(s,2*(t+1));
    end
end