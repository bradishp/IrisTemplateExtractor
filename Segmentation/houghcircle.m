% houghcircle - takes an edge map image, and performs the Hough transform
% for finding circles in the image.
%
% Usage: 
% h = houghcircle(edgeim, rmin, rmax)
%
% Arguments:
%	edgeim      - the edge map image to be transformed
%   rmin, rmax  - the minimum and maximum radius values
%                 of circles to search for
% Output:
%	h           - the Hough transform
%
% Author: 
% Libor Masek
% masekl01@csse.uwa.edu.au
% School of Computer Science & Software Engineering
% The University of Western Australia
% November 2003
% Reworked and updated for optimisation
% Philip Bradish
% Trinity College Dublin
% July 2021

function h = houghcircle(edgeim, rmin, rmax)

[rows, cols] = size(edgeim);
nradii = rmax-rmin+1;
h = zeros(rows, cols, nradii);

[edgeYs, edgeXs] = find(edgeim~=0);

% For each edge point, draw circles of different radii
% to get all the centre points it intersects with
for rInd = 1:nradii
    radius = rInd+rmin-1;
    x = 0:fix(radius/sqrt(2));
    costheta = sqrt(1 - (x.^2 / radius^2));
    y = round(radius*costheta);

    % Now fill in the 8-way symmetric points on a circle for each edge
    % point to get all centre coordinates it intersects with
    centreYs = edgeYs + [x  y  y  x -x -y -y -x];
    centreXs = edgeXs + [y  x -x -y -y -x  x  y];

    % Cull points that are outside limits
    valid = centreYs>=1 & centreYs<=rows & centreXs>=1 & centreXs<=cols;

    centreYs = centreYs(valid);
    centreXs = centreXs(valid);

    indexes = sub2ind([rows, cols], centreYs, centreXs);
    [counts, indexes] = groupcounts(indexes);

    absIndexes = ((rInd-1) * rows * cols) + indexes;
    h(absIndexes) = counts;
end

return
