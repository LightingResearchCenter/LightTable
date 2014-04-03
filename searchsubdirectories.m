function FileArray = searchsubdirectories(parentDir,fileExtension)
%SEARCHSUBDIRECTORIES Summary of this function goes here
%   Detailed explanation goes here

SubjectDirArray = dir(fullfile(parentDir,'Subject*'));
nSubjectDir = numel(SubjectDirArray);

FileArray = struct;

ii = 1; % independent counter
for i1 = 1:nSubjectDir
    
    currentSubject = regexprep(SubjectDirArray(i1).name,'Subject(.*)','$1');
    currentSubjectDir = fullfile(parentDir,SubjectDirArray(i1).name);
    
    WeekDirArray = dir(fullfile(currentSubjectDir,'Week*'));
    nWeekDir = numel(WeekDirArray);
    if isempty(WeekDirArray)
        continue;
    end
    
    for i2 = 1:nWeekDir
        
        currentWeek = regexprep(WeekDirArray(i2).name,'Week(.*)','$1');
        currentWeekDir = fullfile(currentSubjectDir,WeekDirArray(i2).name);
        
        TempFileArray = dir(fullfile(currentWeekDir,['*',fileExtension]));
        nFile = numel(TempFileArray);
        if isempty(TempFileArray)
            continue;
        end
        
        for i3 = 1:nFile
            
            FileArray(ii,1).path = fullfile(currentWeekDir,TempFileArray(i3).name);
            FileArray(ii,1).name = TempFileArray(i3).name;
            FileArray(ii,1).subject = currentSubject;
            FileArray(ii,1).week = currentWeek;
            
            ii = ii + 1;
        end
        
    end
    
end



end

