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

%CASIA
lowerPupilRadius = 28;
upperPupilRadius = 75;
lowerIrisRadius = 80;
upperIrisRadius = 150;

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
    [xl, yl] = linecoords(lines, size(topeyelid));
    yl = double(yl) + irisRowLower-1;
    xl = double(xl) + irisColumnLower-1;
    
    yla = max(yl);
    
    y2 = 1:yla;
    
    ind3 = sub2ind(size(eyeimage),yl,xl);
    imagewithnoise(ind3) = NaN;
    
    imagewithnoise(y2, xl) = NaN;
end

%find bottom eyelid
bottomeyelid = imagepupil((rowPupil+radiusPupil):size(imagepupil,1),:);
lines = findline(bottomeyelid);

if size(lines,1) > 0
    
    [xl, yl] = linecoords(lines, size(bottomeyelid));
    yl = double(yl)+ irisRowLower+rowPupil+radiusPupil-2;
    xl = double(xl) + irisColumnLower-1;
    
    yla = min(yl);
    
    y2 = yla:size(eyeimage,1);
    
    ind4 = sub2ind(size(eyeimage),yl,xl);
    imagewithnoise(ind4) = NaN;
    imagewithnoise(y2, xl) = NaN;
    
end

%For CASIA, eliminate eyelashes by thresholding
%ref = eyeimage < 10;
%coords = find(ref==1);
%imagewithnoise(coords) = NaN;
