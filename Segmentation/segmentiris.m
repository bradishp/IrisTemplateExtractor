% segmentiris - peforms automatic segmentation of the iris region
% from an eye image. Also isolates noise areas such as occluding
% eyelids and eyelashes.
%
% Usage: 
% [circleiris, circlepupil, imagewithnoise] = segmentiris(image)
%
% Arguments:
%	eyeimage		- the input eye image
%	
% Output:
%	circleiris	    - centre coordinates and radius
%			          of the detected iris boundary
%	circlepupil	    - centre coordinates and radius
%			          of the detected pupil boundary
%	imagewithnoise	- original eye image, but with
%			          location of noise marked with
%			          NaN values
%
% Author: 
% Libor Masek
% masekl01@csse.uwa.edu.au
% School of Computer Science & Software Engineering
% The University of Western Australia
% November 2003

function [circleiris, circlepupil, imagewithnoise] = segmentiris(eyeimage)

% define range of pupil & iris radii

%CASIA Interval
%lowerPupilRadius = 25;
%upperPupilRadius = 70;
%lowerIrisRadius = 70;
%upperIrisRadius = 125;

%CASIASyn
%lowerPupilRadius = 30;
%upperPupilRadius = 65;
%lowerIrisRadius = 65;
%upperIrisRadius = 125;

%IITD
lowerPupilRadius = 30;
upperPupilRadius = 65;
lowerIrisRadius = 65;
upperIrisRadius = 125;

%    %LIONS
%    lpupilradius = 32;
%    upupilradius = 85;
%    lirisradius = 145;
%    uirisradius = 169;


% define scaling factor to speed up Hough transform
scaling = 0.4;

reflecthres = 240;

% find the iris boundary
[row, col, radius] = findcircle(eyeimage, lowerIrisRadius, upperIrisRadius, scaling, 2, 0.20, 0.19, 1.00, 0.00);

circleiris = [row col radius];

rowd = double(row);
cold = double(col);
radiusD = double(radius);

irisRowLower = round(rowd-radiusD);
irisRowUpper = round(rowd+radiusD);
irisColumnLower = round(cold-radiusD);
irisColumnUpper = round(cold+radiusD);

imgsize = size(eyeimage);

if irisRowLower < 1
    irisRowLower = 1;
end

if irisColumnLower < 1
    irisColumnLower = 1;
end

if irisRowUpper > imgsize(1)
    irisRowUpper = imgsize(1);
end

if irisColumnUpper > imgsize(2)
    irisColumnUpper = imgsize(2);
end

% to find the inner pupil, use just the region within the previously
% detected iris boundary
imagepupil = eyeimage( irisRowLower:irisRowUpper,irisColumnLower:irisColumnUpper);

%find pupil boundary
[rowPupil, colPupil, radiusPupil] = findcircle(imagepupil, lowerPupilRadius, upperPupilRadius ,0.6,2,0.25,0.25,1.00,1.00);

rowPupil = double(rowPupil);
colPupil = double(colPupil);
radiusPupil = double(radiusPupil);

row = double(irisRowLower) + rowPupil;
col = double(irisColumnLower) + colPupil;

row = round(row);
col = round(col);

circlepupil = [row col radiusPupil];

% set up array for recording noise regions
% noise pixels will have NaN values
imagewithnoise = double(eyeimage);

%find top eyelid
topeyelid = imagepupil(1:(rowPupil-radiusPupil),:);
lines = findline(topeyelid);

if size(lines,1) > 0
    [~, yl] = linecoords(lines, size(topeyelid));
    yl = double(yl) + irisRowLower-1;
    lowerEyelidBound = max(yl);
else
    lowerEyelidBound = irisRowLower;
end

%find bottom eyelid
bottomeyelid = imagepupil((rowPupil+radiusPupil):size(imagepupil,1),:);
lines = findline(bottomeyelid);

if size(lines,1) > 0
    [~, yl] = linecoords(lines, size(bottomeyelid));
    yl = double(yl)+ irisRowLower+rowPupil+radiusPupil-2;
    upperEyelidBound = min(yl);
else
    upperEyelidBound = irisRowUpper;
end

% Calculate noise regions
irisRow = double(circleiris(1));
irisCol = double(circleiris(2));
irisRadius = double(circleiris(3));
pupilRow = double(circlepupil(1));
pupilCol = double(circlepupil(2));
pupilRadius = double(circlepupil(3));

[columnsInImage, rowsInImage] = meshgrid(1:size(eyeimage,2), 1:size(eyeimage,1));
irisRegion = (rowsInImage - irisRow).^2 ./ irisRadius^2 ...
    + (columnsInImage - irisCol).^2 ./ irisRadius^2 <= 1;

pupilRegion = (rowsInImage - pupilRow).^2 ./ pupilRadius^2 ...
    + (columnsInImage - pupilCol).^2 ./ pupilRadius^2 <= 1;

irisRegion(pupilRegion) = false;
innerIrisRegion = logical(irisRegion);
innerIrisRegion(1:lowerEyelidBound, irisColumnLower:irisColumnUpper) = false;
innerIrisRegion(upperEyelidBound:size(eyeimage, 1), irisColumnLower:irisColumnUpper) = false;
outerIrisRegion = irisRegion & ~innerIrisRegion;

%Get threshold values for noise detection by only taking average over areas
%in iris which are probably unobstructed by noise
avg = mean(imagewithnoise(innerIrisRegion), 'all', 'omitnan');
stdeviation = std(imagewithnoise(innerIrisRegion), 0, 'all', 'omitnan');

% Adjust these values for datasets
upperThresholdInBorderRegion = 0.7 * stdeviation;
lowerThresholdInBorderRegion = stdeviation;
upperThresholdInInnerRegion = 2 * stdeviation;
lowerThresholdInInnerRegion = 2.2 * stdeviation;

noiseFlags = ~logical(irisRegion);
noiseFlags(outerIrisRegion) = ...
    imagewithnoise(outerIrisRegion) > avg + upperThresholdInBorderRegion |...
    imagewithnoise(outerIrisRegion) < avg - lowerThresholdInBorderRegion;
noiseFlags(innerIrisRegion) = ...
    imagewithnoise(innerIrisRegion) > avg + upperThresholdInInnerRegion |...
    imagewithnoise(innerIrisRegion) < avg - lowerThresholdInInnerRegion;
noiseFlags(pupilRegion) = false;

uncorruptRegions = imfill(~noiseFlags, 'holes');
% Hacky code to remove the 'uncorrupted' areas of the iris
% which aren't connected to the iris centre.
for r = 1:size(uncorruptRegions, 1)
    uncorrupted = sum(uncorruptRegions(r,:) & irisRegion(r,:));
    total = sum(irisRegion(r,:));
    if uncorrupted/total < 0.5
        % Over half the pixels in a row are corrupted so mark them all as corrupted
        uncorruptRegions(r,:) = 0;
    end
end
% Split iris at centre so two sides are facing out. Fill image to remove areas
% not connected to the center of the iris. Put iris back together.
splitIris = cat(1, ~uncorruptRegions(irisRow+1:size(uncorruptRegions, 1),:),~uncorruptRegions(1:irisRow,:));
splitCorruptedRegion = imfill(splitIris, 'holes');
corruptedRegion = cat(1, splitCorruptedRegion(size(uncorruptRegions, 1)-irisRow+1:size(uncorruptRegions, 1),:), ...
    splitCorruptedRegion(1:size(uncorruptRegions, 1)-irisRow,:));

imagewithnoise(corruptedRegion) = NaN;
