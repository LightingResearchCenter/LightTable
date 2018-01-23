function organizeanalysis(inputDataset,resultsPath)
%ORGANIZEANALYSIS Organize input data and save to Excel
%   Format for Mariana

dataCell = dataset2cell(inputDataset);
varNameArray = dataCell(1,:);
dataCell(1,:) = [];

%% Create header labels
% Remove week from varNames
weekIdx = strcmpi(varNameArray,'week');
varNameArray(weekIdx) = [];
% Count the number of variables
varCount = length(varNameArray);
% Make variable names pretty
prettyVarNameArray = lower(regexprep(varNameArray,'([^A-Z])([A-Z0-9])','$1 $2'));

% Prepare first header row
wk0Txt = 'Week 0 - Baseline';
wk1Txt = 'Week 1 - Intervention';
wk2Txt = 'Week 2 - Post Intervention';
spacer = cell(1,varCount-1);
header1 = [wk0Txt,spacer,{[]},wk1Txt,spacer,{[]},wk2Txt,spacer]; % Combine parts of header1

% Prepare second header row
header2 = [prettyVarNameArray,{[]},prettyVarNameArray,{[]},prettyVarNameArray];

% Combine headers
header = [header1;header2];

%% Organize data
% Seperate line number and AIM from rest of inputData
subjectIdx = strcmpi(varNameArray,'subject');
subjectArray = dataCell(:,subjectIdx);
weekArray = dataCell(:,weekIdx);
% Remove line number from input data
dataCell(:,weekIdx) = [];

% Identify unique line numbers numbers
unqSub = unique(subjectArray);

% Organize data by AIM
nRows = numel(unqSub);
nColumns = numel(header2);
organizedData = cell(nRows,nColumns);

aim0start = 1;
aim0end = aim0start + varCount - 1;

aim1start = aim0end + 2;
aim1end = aim1start + varCount - 1;

aim2start = aim1end + 2;
aim2end = aim2start + varCount - 1;

for i1 = 1:nRows
    % AIM 0
    idx0 = strcmpi(unqSub(i1),subjectArray) & strcmpi('0',weekArray);
    if sum(idx0) == 1
        organizedData(i1,aim0start:aim0end) = dataCell(idx0,:);
    end
    % AIM 1
    idx1 = strcmpi(unqSub(i1),subjectArray) & strcmpi('1',weekArray);
    if sum(idx1) == 1
        organizedData(i1,aim1start:aim1end) = dataCell(idx1,:);
    end
    % AIM 2
    idx2 = strcmpi(unqSub(i1),subjectArray) & strcmpi('2',weekArray);
    if sum(idx2) == 1
        organizedData(i1,aim2start:aim2end) = dataCell(idx2,:);
    end
end


%% Combine headers and data
newOutput = [header;organizedData];

%% Write to file
xlswrite(resultsPath,newOutput); % Create sheet1

end

