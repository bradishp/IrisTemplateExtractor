function visualcorrelation(directoryName)

templateFolderName = strcat(directoryName, '\Templates\');
templates = readInJsonFolder(templateFolderName);

maskFolderName = strcat(directoryName, '\Masks\');
masks = readInJsonFolder(maskFolderName);

templateIDs = fieldnames(templates);
allHDs = zeros(length(templateIDs), length(templateIDs));

for i = 1:numel(templateIDs)
    template = templates.(templateIDs{i});
    mask = masks.(templateIDs{i});
    for j = 1:numel(templateIDs)
        otherTemplate = templates.(templateIDs{j});
        otherMask = masks.(templateIDs{j});
        allHDs(i, j) = hammingDistsVectors(template, mask, otherTemplate, otherMask, 1);
    end
end

imshow(allHDs,[])
end
