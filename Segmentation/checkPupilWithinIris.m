% checkPupilWithinIris - Checks that the boundaries of the iris are valid
%
% Usage:
% function validBoundaries = checkPupilWithinIris(circleiris, circlepupil)
%
% Arguments:
%           circleIris      - centre coordinates and radius of the iris
%           circlePupil     - centre coordinates and radius of the pupil
% Output:
%           validBoundaries	- boolean to indicate whether the pupil lies
%                             entirely within the iris
%
% Author: Philip Bradish
% July 2021
function pupilWithinIris = checkPupilWithinIris(circleIris, circlePupil)
centreDisplacement = sqrt(double((circleIris(1) - circlePupil(1)) ^ 2 + ...
    (circleIris(2) - circlePupil(2)) ^ 2));
% If the radius of the circle and the centre displacement is larger than
% than the radius of the iris than it must go outside it at some point.
pupilWithinIris = centreDisplacement + circlePupil(3) > circleIris(3);
return
