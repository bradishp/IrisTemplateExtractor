function exportdata(directoryName, outputPath, databaseName)

directory =  dir(directoryName);
irisCount = 0;

%allMaskedTemplates = zeros(5,480);
masterMask = zeros(20,480);
%allFilenames = string.empty;
for i = 1 : length(directory)
    subDirName = directory(i).name;
    
    if(isequal(subDirName, '.') ||  isequal(subDirName, '..') ||  ~directory(i).isdir)
        continue;  
    end
    
    allTemplates = struct;
    
    % Build full path to folders. Assumes each sub folder has a L and R sub
    % directories
    subDirPathL = fullfile(directoryName, subDirName, 'L');
    subDirPathR = fullfile(directoryName, subDirName, 'R');
    
    imagesL = dir(subDirPathL);
    imagesR = dir(subDirPathR);
    
    for j = 1 : length(imagesL)
        imageName = imagesL(j).name;
        
        if(isequal(imageName, '.') ||  isequal(imageName, '..' ))
            continue;  
        end
        
        imagepath = fullfile(subDirPathL, imageName);
        
        try
            [template, mask] = createiristemplate(imagepath);
        catch
            disp('Error getting iris template of ' + imagepath);
            continue;
        end
        
        irisCount = irisCount + 1;
        masterMask = masterMask | mask;
        
        maskedTemplate = double(template & ~mask);
        maskedTemplate = reshape(maskedTemplate, [], 1);
        
        filename = split(imageName, '.');
        filename = filename{1};
        templateName = strcat(databaseName, "_", subDirName, "_", filename, "_L");
        allTemplates.(templateName) = maskedTemplate';
        %allFilenames(irisCount) = filename;
        
        %template = logical(template);
        %mask = logical(mask);
        %masked = template & (~mask);
        %allMaskedTemplates = cat(1, allMaskedTemplates, masked);
        %allMaskedTemplates = cat(1, allMaskedTemplates, zeros(5,480));
    end
    
    for j = 1 : length(imagesR)
        imageName = imagesR(j).name;
        
        if(isequal(imageName, '.') ||  isequal(imageName, '..' ))
            continue;  
        end
        
        imagepath = fullfile(subDirPathR, imageName);
        
        try
            [template, mask] = createiristemplate(imagepath);
        catch
            disp('Error getting iris template of ' + imagepath);
            continue;
        end
        
        irisCount = irisCount + 1;
        masterMask = masterMask | mask;
        
        maskedTemplate = double(template & ~mask);
        maskedTemplate = reshape(maskedTemplate, [], 1);
        
        filename = split(imageName, '.');
        filename = filename{1};
        templateName = strcat(databaseName, "_", subDirName, "_", filename, "_R");
        allTemplates.(templateName) = maskedTemplate';
        %allFilenames(irisCount) = filename;
        
        %template = logical(template);
        %mask = logical(mask);
        %masked = template & (~mask);
        %allMaskedTemplates = cat(1, allMaskedTemplates, masked);
        %allMaskedTemplates = cat(1, allMaskedTemplates, zeros(5,480));
    end
    allJsonDump = json.dump(allTemplates);
    outputFileName = strcat(outputPath, databaseName, '\', subDirName, '.json');
    json.write(allJsonDump, outputFileName);
end

disp(irisCount);
masterMask = double(masterMask);
allJsonDump = json.dump(masterMask);
outputMaskFileName = strcat(outputPath, 'MasterMasks\', databaseName, '.json');
json.write(allJsonDump, outputMaskFileName);

%newtemplates = zeros(5,480);

% for j = 1:irisCount
%     templateForCalc = templates(:,:,j);
%     templateForCalc = logical(templateForCalc) & ~(logical(masterMask));
%     %newtemplates = cat(1, newtemplates, templateForCalc);
%     %newtemplates = cat(1, newtemplates, zeros(5,480));
%     templateForCalc = reshape(templateForCalc, [], 1);
%     templateForCalc = double(templateForCalc);
%     allJson.(allFilenames(j)) = templateForCalc';
% end

%imshow(newtemplates)
%imshow(allmaskedtemplates)

% allJsonDump = json.dump(allJson);
% json.write(allJsonDump, './myDataMasterMask.json');
end
