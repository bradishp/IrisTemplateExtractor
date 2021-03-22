function [allTemplates, allMasks, allMaskedTemplates] = ...
    getTemplatesFromFolder(databaseName, subDirName, rlIndicator, subDirPath, allTemplates, allMasks, allMaskedTemplates)

images = dir(subDirPath);
for j = 1 : length(images)
    imageName = images(j).name;

    if(isequal(imageName, '.') ||  isequal(imageName, '..' ))
        continue;  
    end

    imagepath = fullfile(subDirPath, imageName);

    try
        [template, mask] = createiristemplate(imagepath, imageName);
    catch e
        disp('Error getting iris template of ' + imagepath);
        disp(e);
        continue;
    end

    maskedTemplate = double(template & ~mask);
    maskedTemplate = reshape(maskedTemplate, [], 1);
    template = reshape(template, [], 1);
    mask = reshape(mask, [], 1);

    fileNameComponents = split(imageName, '.');
    fileName = fileNameComponents{1};
    templateName = strcat(databaseName, "_", subDirName, "_", rlIndicator, "_", fileName);

    allTemplates.(templateName) = template';
    allMasks.(templateName) = mask';
    allMaskedTemplates.(templateName) = maskedTemplate';
end
end
