function output = analyzefile(subject,week,timeArray,activityArray,bedTimeArray,getupTimeArray)

% Set analysis start and end times
analysisStartTime = bedTimeArray - 20/60/24;
analysisEndTime = getupTimeArray + 20/60/24;

% Plot the data and save to file
plotDir = '\\ROOT\projects\NIH Alzheimers\LightTable\Plots';
plotName = ['sub',num2str(subject,'%02.0f'),'_wk',num2str(week),'_',datestr(timeArray(1),'yyyy-mm-dd'),'.png'];
plotPath = fullfile(plotDir,plotName);
plotactivity(plotPath,timeArray,activityArray,bedTimeArray,getupTimeArray,subject,week);

% Preallocate sleep parameters
nNights = numel(bedTimeArray);

output = cell(nNights,1);

dateFormat = 'mm/dd/yyyy';

% Call function to calculate sleep parameters for each day
for i1 = 1:nNights
    try
        output{i1} = sleepAnalysis(timeArray,activityArray,...
                analysisStartTime(i1),analysisEndTime(i1),...
                bedTimeArray(i1),getupTimeArray(i1),'auto');
        tempFields = fieldnames(output{i1})';
    catch err
        display(err.message);
        display(err.stack);
        tempFields = {};
    end
    
    
    output{i1}.line = subject + i1/100;
    output{i1}.subject = subject;
    output{i1}.week = week;
    output{i1}.date = datestr(floor(analysisStartTime(i1)),dateFormat,'local');
    
    output{i1} = orderfields(output{i1},[{'line','subject','week','date'},tempFields]);
end

end