% findcircle - returns the coordinates of a circle in an image using the Hough transform
% and Canny edge detection to create the edge map.
%
% Usage: 
% [row, col, r] = findcircle(image,lradius,uradius,scaling, sigma, hithres, lowthres, vert, horz)
%
% Arguments:
%	image		    - the image in which to find circles
%	lradius		    - lower radius to search for
%	uradius		    - upper radius to search for
%	scaling		    - scaling factor for speeding up the
%			          Hough transform
%	sigma		    - amount of Gaussian smoothing to
%			          apply for creating edge map.
%	hithres		    - threshold for creating edge map
%	lowthres	    - threshold for connected edges
%	vert		    - vertical edge contribution (0-1)
%	horz		    - horizontal edge contribution (0-1)
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

function [row, col, radius] = findcircle(image, lowerRadius, upperRadius, scaling, ...
    sigma, highThresh, lowThresh, verticalWeight, horizontalWeight)

lowerRadiusScaled = round(lowerRadius*scaling);
upperRadiusScaled = round(upperRadius*scaling);

% Generate the edge image.
[I2, orientation] = canny(image, sigma, scaling, verticalWeight, horizontalWeight);
I3 = adjgamma(I2, 1.9);
I4 = nonmaxsup(I3, orientation, 1.5);
edgeimage = hysthresh(I4, highThresh, lowThresh);

% Perform the circular Hough transform.
houghSpace = houghcircle(edgeimage, lowerRadiusScaled, upperRadiusScaled);

% Find the maximum in the Hough space, and hence
% the parameters of the circle.
[~, maxInd] = max(houghSpace, [], 'all', 'linear');
[row, col, radius] = ind2sub(size(houghSpace), maxInd);

% Rescale radius and coordinates
radius = (radius(1) + lowerRadiusScaled) / scaling;
col = int32(col(1) / scaling);
row = int32(row(1) / scaling);
