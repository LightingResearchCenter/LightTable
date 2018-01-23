function Paths = initializepaths
%INITIALIZEPATHS Prepare project folder and file paths
%   Detailed explanation goes here

% Preallocate output structure
Paths = struct(...
    'project'       ,'',...
    'bySubject'     ,'',...
    'originalData'  ,'',...
    'editedData'    ,'',...
    'results'       ,'',...
    'plots'         ,'',...
    'logs'          ,'',...
    'index'         ,'');

% Set project directory
Paths.project = fullfile([filesep,filesep],'root','projects','NIH Alzheimers','LightTable');
% Check that it exists
if exist(Paths.project,'dir') ~= 7 % 7 = folder
    error(['Cannot locate the folder: ',Paths.project]);
end

Paths.bySubject    = fullfile(Paths.project,'DaysimeterData');
Paths.originalData = fullfile(Paths.project,'originalData');
Paths.editedData   = fullfile(Paths.project,'editedData');
Paths.results      = fullfile(Paths.project,'results');
Paths.plots        = fullfile(Paths.project,'plots');
Paths.logs         = fullfile(Paths.project,'logs');
Paths.index        = fullfile(Paths.logs,'index.xlsx');

end

