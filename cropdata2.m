function cropdata2
%CROPDATA Summary of this function goes here
%   Detailed explanation goes here

% Enable dependecies
initializedependencies;

% Construct project paths
Paths = initializepaths;

cropping(Paths.originalData,Paths.editedData,Paths.logs);

end

