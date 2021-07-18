
function imagewithnoise = isolateEyelids(eyeImage, circleIris, circlePupil, ...
    irisColumnLower, irisColumnUpper, irisRowLower, irisRowUpper)

irisRow = double(circleIris(1));
irisCol = double(circleIris(2));
irisRadius = double(circleIris(3));
pupilRow = double(circlePupil(1));
pupilCol = double(circlePupil(2));
pupilRadius = double(circlePupil(3));

validIris = logical(eyeImage);

% Split top of the iris in three and find top eyelid for each of them
irisThird = round((irisRadius * 2)/3);
topEyelidLeft = eyeImage(irisRowLower:(pupilRow-pupilRadius), ...
    irisColumnLower:irisColumnLower+irisThird);
linesLeft = findline(topEyelidLeft);
if size(linesLeft,1) > 0
    [xLeft, yLeft] = linecoords(linesLeft, size(topEyelidLeft));
    xLeft = xLeft + irisColumnLower;
else
    xLeft = [];
    yLeft = [];
end

bottomEyelidCentre = eyeImage(irisRowLower:(pupilRow-pupilRadius), ...
    irisColumnLower + irisThird + 1:irisColumnLower + (2*irisThird));
linesCentre = findline(bottomEyelidCentre);
if size(linesCentre,1) > 0
    [xCentre, yCentre] = linecoords(linesCentre, size(bottomEyelidCentre));
    xCentre = xCentre + irisColumnLower + irisThird + 1;
else
    xCentre = [];
    yCentre = [];
end

bottomEyelidRight = eyeImage(irisRowLower:(pupilRow-pupilRadius), ...
    irisColumnLower + (2*irisThird) + 1:irisColumnUpper);
linesRight = findline(bottomEyelidRight);
if size(linesRight,1) > 0
    [xRight, yRight] = linecoords(linesRight, size(bottomEyelidRight));
    xRight = xRight + irisColumnLower + (2*irisThird) + 1;
else
    xRight = [];
    yRight = [];
end

% Combine two sides of the bottom eyelid
xs = [xLeft, xCentre, xRight];
ys = [yLeft, yCentre, yRight];
ys = ys + irisRowLower;

for ind = 1:size(xs, 2)
    y = ys(ind);
    x = xs(ind);
    validIris(1:y, x) = false;
end

% Split bottom of the iris in two and find bottom eyelid for each of them
bottomEyelidLeft = eyeImage((pupilRow+pupilRadius):irisRowUpper, ...
    irisColumnLower:irisCol);
linesLeft = findline(bottomEyelidLeft);
if size(linesLeft,1) > 0
    [xLeft, yLeft] = linecoords(linesLeft, size(bottomEyelidLeft));
    xLeft = xLeft + irisCol - irisRadius;
else
    xLeft = [];
    yLeft = [];
end

bottomEyelidRight = eyeImage((pupilRow+pupilRadius):irisRowUpper, ...
    irisCol+1:irisColumnUpper);
linesRight = findline(bottomEyelidRight);
if size(linesRight,1) > 0
    [xRight, yRight] = linecoords(linesRight, size(bottomEyelidRight));
    xRight = xRight + irisCol + 1;
else
    xRight = [];
    yRight = [];
end

% Combine two sides of the bottom eyelid
xs = [xLeft, xRight];
ys = [yLeft, yRight];
ys = ys + pupilRow + pupilRadius + 2;

for ind = 1:size(xs, 2)
    y = ys(ind);
    x = xs(ind);
    validIris(y:end, x) = false;
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
imagewithnoise(~uncorruptRegions) = NaN;

return
