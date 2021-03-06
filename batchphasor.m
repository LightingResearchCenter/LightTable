function batchphasor
%BATCHANALYSIS Summary of this function goes here
%   Detailed explanation goes here
[parentDir,~,~] = fileparts(pwd);
CDFtoolkit = fullfile(parentDir,'LRC-CDFtoolkit');
daysigramToolkit = fullfile(parentDir,'DaysigramReport');
phasorToolkit = fullfile(parentDir,'PhasorAnalysis');
addpath(CDFtoolkit,daysigramToolkit,phasorToolkit);


% File handling
Paths = initializepaths;

indexPath = fullfile(Paths.project,'index.xlsx');
outputPath = fullfile(Paths.results,['phasor_',datestr(now,'yyyy-mm-dd_HH-MM')]);

% Search for cdf files
[fileNameArray,filePathArray] = searchdir(Paths.editedData,'cdf');

% Import the index
Index = importindex(indexPath);

% Preallocate output
nFile = numel(filePathArray);
output = cell(nFile,1);

% Begin main loop
for i1 = 1:nFile
    % Load file
    Daysimeter = ProcessCDF(filePathArray(i1));
    timeArray = Daysimeter.Variables.time;
    csArray = Daysimeter.Variables.CS;
    luxArray = Daysimeter.Variables.illuminance;
    claArray = Daysimeter.Variables.CLA;
    activityArray = Daysimeter.Variables.activity;
    
    subject = str2double(filePathArray(i1).subject);
    week = str2double(filePathArray(i1).week);
    
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
        warning(['No data in bounds for subject ',filePathArray(i1).subject,...
            ', week ',filePathArray(i1).week]);
        continue;
    end
    
    % Plot the data
    sheetTitle = ['Light Table Subject: ',filePathArray(i1).subject,...
        '   Week: ',filePathArray(i1).week];
    fileID = ['sub',filePathArray(i1).subject,'_wk',filePathArray(i1).week];
    generatedaysigram(sheetTitle,timeArray,activityArray,csArray,'cs',[0,1],12,Paths.plots,fileID)
    
    % Generate bed and get up time arrays
    [bedTimeArray,getupTimeArray] = generatebedlog(timeArray,bedTime,getupTime);
    
    % Replace bed time data with 0
    [csArray,activityArray] = replacebed(timeArray,csArray,activityArray,bedTimeArray,getupTimeArray);
    
    % Perform analysis
    output{i1} = phasoranalysis(timeArray,csArray,activityArray);
    output{i1}.subject = subject;
    output{i1}.week = week;
end

close('all');

% Save output
save([outputPath,'.mat'],'output');
organizephasorexcel([outputPath,'.mat'])
end

