function organizeExcel(inputFile)
%ORGANIZEEXCEL Organize input data and save to Excel
%   Format for Mariana
load(inputFile);
saveFile = regexprep(inputFile,'\.mat','\.xlsx');

flatOut = cat(1,output{:});
% Determine variable names
varNames = fieldnames(flatOut{1})';

% Flatten nested data and convert to dataset
tempCell = cellfun(@struct2cell,flatOut,'UniformOutput',false);
dataCell = cat(2,tempCell{:})';

%% Create header labels
% Remove line and week from varNames
lineIdx = strcmpi(varNames,'line');
weekIdx = strcmpi(varNames,'week');
varNames(lineIdx | weekIdx) = [];
% Count the number of variables
varCount = length(varNames);
% Make variable names pretty
prettyNames = lower(regexprep(varNames,'([^A-Z])([A-Z0-9])','$1 $2'));

% Prepare first header row
week0Txt = 'baseline (0)';
week1Txt = 'intervention (1)';
week2Txt = 'post intervention (2)';
spacer = cell(1,varCount-1);
header1 = [{[]},{[]},week0Txt,spacer,{[]},week1Txt,spacer,{[]},week2Txt,spacer]; % Combine parts of header1

% Prepare second header row
header2 = [{'line'},{[]},prettyNames,{[]},prettyNames,{[]},prettyNames];

% Combine headers
header = [header1;header2];

%% Organize data
% Seperate line number and week from rest of inputData
lineNum = cell2mat(dataCell(:,lineIdx));
week = cell2mat(dataCell(:,weekIdx));
% Remove line number from input data
dataCell(:,lineIdx | weekIdx) = [];

% Identify unique line numbers numbers
unqLine = unique(lineNum);

% Organize data by week
nRows = numel(unqLine);
nColumns = numel(header2);
organizedData = cell(nRows,nColumns);

week0start = 3;
week0end = week0start + varCount - 1;

week1start = week0end + 2;
week1end = week1start + varCount - 1;

week2start = week1end + 2;
week2end = week2start + varCount - 1;

for i1 = 1:nRows
    % Line number
    organizedData{i1,1} = unqLine(i1);
    % week 0
    idx0 = lineNum == unqLine(i1) & week == 0;
    if sum(idx0) == 1
        organizedData(i1,week0start:week0end) = dataCell(idx0,:);
    end
    % week 1
    idx1 = lineNum == unqLine(i1) & week == 1;
    if sum(idx1) == 1
        organizedData(i1,week1start:week1end) = dataCell(idx1,:);
    end
    % week 2
    idx2 = lineNum == unqLine(i1) & week == 2;
    if sum(idx2) == 1
        organizedData(i1,week2start:week2end) = dataCell(idx2,:);
    end
end


%% Combine headers and data
newOutput = [header;organizedData];

%% Write to file
xlswrite(saveFile,newOutput); % Create sheet1

end

