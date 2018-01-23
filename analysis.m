function analysis
%ANALYSIS Add bed logs to data that is already cropped
%   Detailed explanation goes here

% Enable dependecies
initializedependencies;

% Construct project paths
Paths = initializepaths;
[cdfFileArray,cdfPathArray] = searchdir(Paths.editedData,'cdf');
[bedLogFileNameArray,bedLogPathArray] = searchdir(Paths.logs,'xlsx');

% Import the index
[indexSubjectArray,indexWeekArray,indexFileArray] = importindex(Paths.index);

% Extract subject from bed logs
bedSubject = str2double(regexprep(bedLogFileNameArray,'.*(\d\d\d).*','$1'));
idxNaN = isnan(bedSubject);
bedSubject(idxNaN) = [];
bedLogFileNameArray(idxNaN) = [];
bedLogPathArray(idxNaN) = [];

% Preallocate and intialize resources
[hFigure,~,~,units] = initializefigure1(1,'on');
nFiles = numel(cdfPathArray);
templateCell = cell(nFiles,1);

Output = dataset;
Output.subject = templateCell;
Output.week = templateCell;
%   sleep
Output.nightsAveraged        = templateCell;
Output.actualSleepTimeMins   = templateCell;
Output.actualSleepPercent    = templateCell;
Output.actualWakeTimeMins    = templateCell;
Output.actualWakePercent     = templateCell;
Output.sleepEfficiency       = templateCell;
Output.sleepOnsetLatencyMins = templateCell;
Output.sleepBouts            = templateCell;
Output.wakeBouts             = templateCell;
Output.meanSleepBoutTimeMins = templateCell;
Output.meanWakeBoutTimeMins  = templateCell;
%   phasor, IS, IV
Output.phasorMagnitude       = templateCell;
Output.phasorAngleHrs        = templateCell;
Output.interdailyStability   = templateCell;
Output.intradailyVariability = templateCell;
%   averages
Output.meanNonzeroCs            = templateCell;
Output.logmeanNonzeroLux        = templateCell;
Output.meanNonzeroActivity      = templateCell;


for i1 = 1:nFiles
    % Import data
    Data = ProcessCDF(cdfPathArray{i1});
    subject = Data.GlobalAttributes.subjectID{1};
    logicalArray = logical(Data.Variables.logicalArray);
    complianceArray = logical(Data.Variables.complianceArray(logicalArray));
    bedArray = logical(Data.Variables.bedArray(logicalArray));
    timeArray = Data.Variables.time(logicalArray);
    activityArray = Data.Variables.activity(logicalArray);
    csArray = Data.Variables.CS(logicalArray);
    illuminanceArray = Data.Variables.illuminance(logicalArray);
    
    % Match index entry
    idxIndex = strcmpi(cdfFileArray{i1},indexFileArray);
    week = num2str(indexWeekArray(idxIndex));
    
    % Set subject and week
    Output.subject{i1,1} = subject;
    Output.week{i1,1}    = week;
    
    % Check useable data
    if numel(timeArray(complianceArray)) < 24
        continue
    end
    
    % Match and import bed log
    bedIdx = bedSubject == str2double(subject);
    [bedTimeArray,riseTimeArray] = importbedlog(bedLogPathArray{bedIdx});
    
    % Daysigram
    sheetTitle = ['NIH Alzheimer''s Light Table - Subject ',subject,' Week ',week];
    daysigramFileID = ['subject',subject,'_week',week];
    generatedaysigram(sheetTitle,timeArray(complianceArray),...
        activityArray(complianceArray),csArray(complianceArray),...
        'cs',[0,1],12,Paths.plots,daysigramFileID)
    
    % Light and Health Report/ Phasor Analysis
    figTitle = 'NIH Alzheimer''s Light Table';
    Phasor = phasorprep(subject,week,figTitle,hFigure,units,Paths,...
        complianceArray,bedArray,timeArray,csArray,activityArray,...
        illuminanceArray);
    
    % Averages
    Average = prepaverages(timeArray,csArray,activityArray,...
        illuminanceArray,complianceArray,bedArray);
    
    % Sleep Analysis
    [Sleep,nIntervalsAveraged] = sleepprep(timeArray,activityArray,...
        bedTimeArray,riseTimeArray,complianceArray);
    
    % Assign output
    %   sleep
    Output.nightsAveraged{i1,1}         = nIntervalsAveraged;
    Output.actualSleepTimeMins{i1,1}    = Sleep.actualSleepTime;
    Output.actualSleepPercent{i1,1}     = Sleep.actualSleepPercent;
    Output.actualWakeTimeMins{i1,1}     = Sleep.actualWakeTime;
    Output.actualWakePercent{i1,1}      = Sleep.actualWakePercent;
    Output.sleepEfficiency{i1,1}        = Sleep.sleepEfficiency;
    Output.sleepOnsetLatencyMins{i1,1}  = Sleep.sleepLatency;
    Output.sleepBouts{i1,1}             = Sleep.sleepBouts;
    Output.wakeBouts{i1,1}              = Sleep.wakeBouts;
    Output.meanSleepBoutTimeMins{i1,1}  = Sleep.meanSleepBoutTime;
    Output.meanWakeBoutTimeMins{i1,1}   = Sleep.meanWakeBoutTime;

    %   phasor, IS, IV
    Output.phasorMagnitude{i1,1}        = Phasor.phasorMagnitude;
    Output.phasorAngleHrs{i1,1}         = Phasor.phasorAngleHrs;
    Output.interdailyStability{i1,1}    = Phasor.interdailyStability;
    Output.intradailyVariability{i1,1}  = Phasor.intradailyVariability;

    %   averages
    Output.meanNonzeroCs{i1,1}          = Average.cs;
    Output.logmeanNonzeroLux{i1,1}      = Average.illuminance;
    Output.meanNonzeroActivity{i1,1}    = Average.activity;
end

close all

runtime = datestr(now,'yyyy-mm-dd_HHMM');
resultsPath = fullfile(Paths.results,['results_',runtime,'_NIHAlzheimers-LightTable.xlsx']);
organizeanalysis(Output,resultsPath);

end


function Output = phasorprep(subject,week,figTitle,hFigure,units,Paths,complianceArray,bedArray,timeArray,csArray,activityArray,illuminanceArray)
clf;

% replace in bed time
csArray(bedArray) = 0;
activityArray(bedArray) = 0;
illuminanceArray(bedArray) = 0;

% remove only large noncompliance while awake
complianceArray = adjustcrop(timeArray,complianceArray,bedArray);
timeArray(~complianceArray) = [];
csArray(~complianceArray) = [];
activityArray(~complianceArray) = [];
illuminanceArray(~complianceArray) = [];

subject = [subject,' Week ',week];

Output = generatereport(Paths.plots,timeArray,csArray,activityArray,...
    illuminanceArray,subject,hFigure,units,figTitle);
end


function [workIdx,postWorkIdx] = createworkday(timeArray,bedTimeArray)

workStart = 8/24;
workEnd   = 17/24;

dayArray       = unique(floor(timeArray));
dayOfWeekArray = weekday(dayArray); % Sunday = 1, Monday = 2, etc.
workDaysIdx    = dayOfWeekArray >= 2 & dayOfWeekArray <= 6;
workDayArray   = dayArray(workDaysIdx);

workStartArray = workDayArray + workStart;
workEndArray   = workDayArray + workEnd;

workIdx = false(size(timeArray));
postWorkIdx = false(size(timeArray));
for j1 = 1:numel(workStartArray)
    tempWorkIdx = timeArray > workStartArray(j1) & timeArray <= workEndArray(j1);
    workIdx = workIdx | tempWorkIdx;

    diffBedTime = bedTimeArray - workEndArray(j1);
    currentBedTime = bedTimeArray(diffBedTime<1 & diffBedTime>0);
    if numel(currentBedTime) == 1
        tempPostWorkIdx = timeArray > workEndArray(j1) & timeArray <=currentBedTime;
        postWorkIdx = postWorkIdx | tempPostWorkIdx;
    end
end

end


function Average = prepaverages(timeArray,csArray,activityArray,illuminanceArray,complianceArray,bedArray)

validIdx = complianceArray & ~bedArray;

timeArray(~validIdx) = [];
csArray(~validIdx) = [];
activityArray(~validIdx) = [];
illuminanceArray(~validIdx) = [];

Average = daysimeteraverages(csArray,illuminanceArray,activityArray);

end


function [Sleep,nIntervalsAveraged] = sleepprep(timeArray,activityArray,bedTimeArray,riseTimeArray,complianceArray)

timeArray(~complianceArray) = [];
activityArray(~complianceArray) = [];

nIntervals = numel(bedTimeArray);
dailySleep = cell(nIntervals,1);
analysisStartTimeArray = bedTimeArray  - 20/(60*24);
analysisEndTimeArray   = riseTimeArray + 20/(60*24);
    
for i1 = 1:nIntervals
    % Perform analysis
    try
        dailySleep{i1} = sleepAnalysis(timeArray,activityArray,...
        analysisStartTimeArray(i1),analysisEndTimeArray(i1),...
        bedTimeArray(i1),riseTimeArray(i1),'auto');
    catch err
        continue
    end
end

% Average results
[Sleep,nIntervalsAveraged] = averageanalysis(dailySleep);

end