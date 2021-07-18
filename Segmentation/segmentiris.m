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
lowerPupilRadius = 25;
upperPupilRadius = 70;
lowerIrisRadius = 70;
upperIrisRadius = 125;

%CASIASyn
%lowerPupilRadius = 30;
%upperPupilRadius = 65;
%lowerIrisRadius = 65;
%upperIrisRadius = 125;

%IITD
%lowerPupilRadius = 30;
%upperPupilRadius = 65;
%lowerIrisRadius = 65;
%upperIrisRadius = 125;

%    %LIONS
%    lpupilradius = 32;
%    upupilradius = 85;
%    lirisradius = 145;
%    uirisradius = 169;


% Define scaling factor, thresholds and weights.
scaling = 0.4;
sigma = 2;
hiThres = 0.2;
lowThres = 0.18;
verticalWeight = 1;
horizontalWeight = 0;

% find the iris boundary
[row, col, radius] = findcircle(eyeimage, lowerIrisRadius, upperIrisRadius, ...
    scaling, sigma, hiThres, lowThres, verticalWeight, horizontalWeight);

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
imagepupil = eyeimage(irisRowLower:irisRowUpper, irisColumnLower:irisColumnUpper);

% Define scaling factor, thresholds and weights.
scaling = 1;
sigma = 2;
hiThres = 0.25;
lowThres = 0.25;
verticalWeight = 1;
horizontalWeight = 1;

%find pupil boundary
[rowPupil, colPupil, radiusPupil] = findcircle(imagepupil, lowerPupilRadius, ...
    upperPupilRadius, scaling, sigma, hiThres, lowThres, verticalWeight, ...
    horizontalWeight);

rowPupil = double(rowPupil);
colPupil = double(colPupil);
radiusPupil = double(radiusPupil);

row = double(irisRowLower) + rowPupil;
col = double(irisColumnLower) + colPupil;

row = round(row);
col = round(col);

circlepupil = [row col radiusPupil];

imagewithnoise = isolateEyelids(eyeimage, circleiris, circlepupil, ...
    irisColumnLower, irisColumnUpper, irisRowLower, irisRowUpper);

return
