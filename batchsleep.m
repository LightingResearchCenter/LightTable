function batchsleep
%BATCHANALYSIS Summary of this function goes here
%   Detailed explanation goes here
[parentDir,~,~] = fileparts(pwd);
CDFtoolkit = fullfile(parentDir,'LRC-CDFtoolkit');
DaysimeterSleepAlgorithm = fullfile(parentDir,'DaysimeterSleepAlgorithm');
addpath(CDFtoolkit,DaysimeterSleepAlgorithm);


% File handling
projectDir = '\\ROOT\projects\NIH Alzheimers\LightTable';
indexPath = fullfile(projectDir,'index.xlsx');
cdfDir = fullfile(projectDir,'DaysimeterData');
resultsDir = fullfile(projectDir,'Results');
outputPath = fullfile(resultsDir,['sleep_',datestr(now,'yyyy-mm-dd_HH-MM')]);

% Search for cdf files
FileArray = searchsubdirectories(cdfDir,'.cdf');

% Import the index
Index = importindex(indexPath);

% Preallocate output
nFile = numel(FileArray);
output = cell(nFile,1);

% Begin main loop
for i1 = 1:nFile
    % Load file
    Daysimeter = ProcessCDF(FileArray(i1).path);
    timeArray = Daysimeter.Variables.time;
    csArray = Daysimeter.Variables.CS;
    luxArray = Daysimeter.Variables.illuminance;
    claArray = Daysimeter.Variables.CLA;
    activityArray = Daysimeter.Variables.activity;
    
    subject = str2double(FileArray(i1).subject);
    week = str2double(FileArray(i1).week);
    
    % Find matching log
    idxSubject = Index.subject == subject;
    idxWeek = Index.week == week;
    idxLog = idxSubject & idxWeek;
    startTime = Index.startTime(idxLog);
    stopTime = Index.stopTime(idxLog);
    bedTime = Index.bedTime(idxLog);
    getupTime = Index.getupTime(idxLog);
    crop1Start = Index.crop1Start(idxLog);
    crop1Stop = Index.crop1Stop(idxLog);
    crop2Start = Index.crop2Start(idxLog);
    crop2Stop = Index.crop2Stop(idxLog);
    crop3Start = Index.crop3Start(idxLog);
    crop3Stop = Index.crop3Stop(idxLog);
    
    % Crop data
    [timeArray,luxArray,claArray,csArray,activityArray] = ...
        cropdata(startTime,stopTime,timeArray,luxArray,...
        claArray,csArray,activityArray);
    if ~isnan(crop1Start)
    [timeArray,luxArray,claArray,csArray,activityArray] = ...
        removedata(crop1Start,crop1Stop,timeArray,luxArray,...
        claArray,csArray,activityArray);
    end
    if ~isnan(crop2Start)
    [timeArray,luxArray,claArray,csArray,activityArray] = ...
        removedata(crop2Start,crop2Stop,timeArray,luxArray,...
        claArray,csArray,activityArray);
    end
    if ~isnan(crop3Start)
    [timeArray,luxArray,claArray,csArray,activityArray] = ...
        removedata(crop3Start,crop3Stop,timeArray,luxArray,...
        claArray,csArray,activityArray);
    end
    
    % Check for over cropping
    if isempty(timeArray)
        warning(['No data in bounds for subject ',FileArray(i1).subject,...
            ', week ',FileArray(i1).week]);
        continue;
    end
    
    % Generate bed and get up time arrays
    [bedTimeArray,getupTimeArray] = generatebedlog(timeArray,bedTime,getupTime);
    
    % Perform analysis
    output{i1} = ...
        analyzefile(subject,week,timeArray,activityArray,bedTimeArray,getupTimeArray);
    
end

close('all');

% Save output
save([outputPath,'.mat'],'output');
organizeExcel([outputPath,'.mat'])
end

