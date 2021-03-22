function visualCorrelationWithoutMasks(directoryName)

templateFolderName = strcat(directoryName, '\MaskedTemplates\');
templates = readInJsonFolder(templateFolderName);

templateIDs = fieldnames(templates);
allHDs = zeros(length(templateIDs), length(templateIDs));

mask = zeros(1, 9600);

for i = 1:numel(templateIDs)
    templateName = templateIDs{i};
    template = templates.(templateName);
    nameComponents = split(templateName, "_");
    userID = strcat(nameComponents(1), "_", nameComponents(2), "_", nameComponents(4));
    for j = 1:numel(templateIDs)
        otherTemplateName = templateIDs{j};
        otherTemplate = templates.(otherTemplateName);
        otherNameComponents = split(otherTemplateName, "_");
        otherUserID = strcat(otherNameComponents(1), "_", otherNameComponents(2), "_", otherNameComponents(3));
        allHDs(i, j) = hammingDistsVectors(template, mask, otherTemplate, mask, 1);
        if userID == otherUserID
            fprintf("Same %2f\n",allHDs(i, j));
        else
            fprintf("Different %2f\n", allHDs(i,j));
        end
    end
end

imshow(allHDs,[])
end
