
function jsonStruct = readInJsonFolder(directoryPath)

directory =  dir(directoryPath);
jsonStruct = struct;

for i = 1 : length(directory)
    fileName = directory(i).name;
    
    if(isequal(fileName, '.') ||  isequal(fileName, '..'))
        continue;  
    end

    filePath = fullfile(directoryPath, fileName);
    fileData = json.read(filePath);
    
    ids = fieldnames(fileData);
    for j = 1:numel(ids)
        jsonStruct.(ids{j}) = fileData.(ids{j});
    end
end
end
