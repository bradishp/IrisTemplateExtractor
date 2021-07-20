function exportdata(directoryName, outputPath, databaseName)

directory =  dir(directoryName);

for i = 1 : length(directory)
    subDirName = directory(i).name;
    
    if(isequal(subDirName, '.') ||  isequal(subDirName, '..') ||  ~directory(i).isdir)
        continue;  
    end
    
    allTemplates = struct;
    allMasks = struct;
    allMaskedTemplates = struct;
    
    % Build full path to folders. Assumes each sub folder has a L and R sub directory
    subDirPathL = fullfile(directoryName, subDirName, 'L');
    subDirPathR = fullfile(directoryName, subDirName, 'R');
    %subDirPath = fullfile(directoryName, subDirName);

    [allTemplates, allMasks, allMaskedTemplates] = getTemplatesFromFolder(...
        databaseName, subDirName, "L", subDirPathL, allTemplates, allMasks, allMaskedTemplates);
    [allTemplates, allMasks, allMaskedTemplates] = getTemplatesFromFolder(...
        databaseName, subDirName, "R", subDirPathR, allTemplates, allMasks, allMaskedTemplates);
    %[allTemplates, allMasks, allMaskedTemplates] = getTemplatesFromFolder(...
    %   databaseName, subDirName, "R", subDirPath, allTemplates, allMasks, allMaskedTemplates);

    templatesJson = jsonencode(allTemplates);
    outputFileName = strcat(outputPath, '\', databaseName, '\Templates\', ...
        subDirName, '.json');
    fileID = fopen(outputFileName, 'w');
    fprintf(fileID, templatesJson);
    fclose(fileID);

    masksJson = jsonencode(allMasks);
    outputFileName = strcat(outputPath, '\', databaseName, '\Masks\', ...
        subDirName, '.json');
    fileID = fopen(outputFileName, 'w');
    fprintf(fileID, masksJson);
    fclose(fileID);

    maskedTemplatesJson = jsonencode(allMaskedTemplates);
    outputFileName = strcat(outputPath, '\', databaseName, '\MaskedTemplates\', ...
        subDirName, '.json');
    fileID = fopen(outputFileName, 'w');
    fprintf(fileID, maskedTemplatesJson);
    fclose(fileID);
end

return
