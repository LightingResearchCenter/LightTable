function copyoriginalfiles
%COPYORIGINALFILES Summary of this function goes here
%   Detailed explanation goes here

initializedependencies;

Paths = initializepaths;

% Search for cdf files
cdfPathArray = searchsubdirectories(Paths.bySubject,'.cdf');

for i1 = 1:numel(cdfPathArray)
    newPath = fullfile(Paths.originalData,cdfPathArray(i1).name);
    
    if exist(newPath,'file') == 2 % 2 = file
        delete(newPath);
    end
    
    copyfile(cdfPathArray(i1).path,newPath);
end

end

