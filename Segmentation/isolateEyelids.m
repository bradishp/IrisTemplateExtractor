
function imagewithnoise = isolateEyelids(eyeImage, circleIris, circlePupil, ...
    irisColumnLower, irisColumnUpper, irisRowLower, irisRowUpper)

    irisRow = double(circleIris(1));
    irisCol = double(circleIris(2));
    irisRadius = double(circleIris(3));
    pupilRow = double(circlePupil(1));
    pupilCol = double(circlePupil(2));
    pupilRadius = double(circlePupil(3));

    % Get boundary points of the top and bottom eyelids
    topBoundaryPoints = isolateEyelid(eyeImage, irisColumnLower, irisCol, ...
        irisColumnUpper, irisRadius, irisRowLower, pupilRow-pupilRadius, 0);

    heightOfExaminedArea = irisRowUpper - (pupilRow+pupilRadius) + 1;
    bottomBoundaryPoints = isolateEyelid(eyeImage, irisColumnLower, irisCol, ...
        irisColumnUpper, irisRadius, pupilRow+pupilRadius, irisRowUpper, ...
        heightOfExaminedArea);

    validIris = logical(eyeImage);
    xs = irisColumnLower:irisColumnUpper;
    for ind = 1:size(xs, 2)
        x = xs(ind);
        topBoundaryPoint = topBoundaryPoints(ind);
        bottomBoundaryPoint = bottomBoundaryPoints(ind);

        validIris(1:ceil(topBoundaryPoint), x) = false;
        validIris(floor(bottomBoundaryPoint):end, x) = false;
    end

    % Further processing to try to remove pixels which aren't part of the iris
    imagewithnoise = double(eyeImage);

    [columnsInImage, rowsInImage] = meshgrid(1:size(eyeImage,2), 1:size(eyeImage,1));

    pupilRegion = (rowsInImage - pupilRow).^2 ./ pupilRadius^2 ...
        + (columnsInImage - pupilCol).^2 ./ pupilRadius^2 <= 1;

    irisRegion = (rowsInImage - irisRow).^2 ./ irisRadius^2 ...
        + (columnsInImage - irisCol).^2 ./ irisRadius^2 <= 1;
    irisRegion(pupilRegion) = false;

    validIris = validIris & irisRegion;

    imagewithnoise(~validIris) = NaN;

    avg = mean(imagewithnoise, 'all', 'omitnan');
    stdeviation = std(imagewithnoise, 0, 'all', 'omitnan');

    % Adjust these values for datasets
    upperThreshold = 2 * stdeviation;
    lowerThreshold = 2 * stdeviation;

    noiseFlags = ~logical(validIris);
    noiseFlags(pupilRegion) = false;
    noiseFlags(validIris) = ...
        imagewithnoise(validIris) > avg + upperThreshold |...
        imagewithnoise(validIris) < avg - lowerThreshold;

    uncorruptRegions = imfill(~noiseFlags, 'holes');

    % Remove extreme outliers which are caused by reflections and
    % missclassified sections of the pupil
    uncorruptRegions = uncorruptRegions & imagewithnoise >= 40 & ...
        imagewithnoise <= 250;

    imagewithnoise(~uncorruptRegions) = NaN;
return



% Helper function to isolate eyelids
function boundaryPoints = isolateEyelid(eyeImage, irisColumnLower, ...
        irisCol, irisColumnUpper, irisRadius, eyelidMin, eyelidMax, ...
        defualtBoundary)
    sampleX = [irisColumnLower, irisCol, irisColumnUpper];
    sampleY = [defualtBoundary, defualtBoundary, defualtBoundary];

    % Split iris in three and find eyelid for each of them
    irisThird = round((irisRadius * 2)/3);
    eyelidLeft = eyeImage(eyelidMin:eyelidMax, ...
        irisColumnLower:irisColumnLower+irisThird);
    linesLeft = findline(eyelidLeft);
    if size(linesLeft, 1) > 0
        [~, yLeft] = linecoords(linesLeft, size(eyelidLeft));
        sampleY(1) = yLeft(1);
    end

    eyelidCentre = eyeImage(eyelidMin:eyelidMax, irisColumnLower + ...
        irisThird + 1:irisColumnLower + (2*irisThird));
    linesCentre = findline(eyelidCentre);
    if size(linesCentre, 1) > 0
        [~, yCentre] = linecoords(linesCentre, size(eyelidCentre));
        sampleY(2) = yCentre(round(size(yCentre, 2)/2));
    end

    eyelidRight = eyeImage(eyelidMin:eyelidMax, irisColumnLower + ...
        (2*irisThird) + 1:irisColumnUpper);
    linesRight = findline(eyelidRight);
    if size(linesRight, 1) > 0
        [~, yRight] = linecoords(linesRight, size(eyelidRight));
        sampleY(3) = yRight(end);
    end

    % Combine three sides of the eyelid
    irisColumns = irisColumnLower:irisColumnUpper;
    boundaryPoints = interp1(double(sampleX), double(sampleY), irisColumns);
    boundaryPoints = boundaryPoints + eyelidMin;
return
