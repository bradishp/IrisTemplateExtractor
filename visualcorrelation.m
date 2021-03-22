function visualcorrelation(directoryName)

templateFolderName = strcat(directoryName, '\Templates\');
templates = readInJsonFolder(templateFolderName);

maskFolderName = strcat(directoryName, '\Masks\');
masks = readInJsonFolder(maskFolderName);

templateIDs = fieldnames(templates);
allHDs = zeros(length(templateIDs), length(templateIDs));

for i = 1:numel(templateIDs)
    templateName = templateIDs{i};
    template = templates.(templateIDs{i});
    mask = masks.(templateIDs{i});
    nameComponents = split(templateName, "_");
    userID = strcat(nameComponents(1), "_", nameComponents(2), "_", nameComponents(4));
    for j = 1:numel(templateIDs)
        otherTemplateName = templateIDs{j};
        otherTemplate = templates.(templateIDs{j});
        otherMask = masks.(templateIDs{j});
        allHDs(i, j) = hammingDistsVectors(template, mask, otherTemplate, otherMask, 1);

        otherNameComponents = split(otherTemplateName, "_");
        otherUserID = strcat(otherNameComponents(1), "_", otherNameComponents(2), "_", otherNameComponents(3));
        if userID == otherUserID
            fprintf("Same %2f\n",allHDs(i, j));
        else
            fprintf("Different %2f\n", allHDs(i,j));
        end
    end
end

imshow(allHDs,[])
end
