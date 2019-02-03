% Brian Yuen
% z5115851
% 18/10/18


function lib = LibraryBrian()
    lib.getDepth = @getDepth;
    lib.rotate = @rotate;
    lib.rotateRoll = @rotateRoll;
    lib.useful = @useful;
    lib.plotCircle = @plotCircle;
    lib.interest = @interest;
    lib.notInterest = @notInterest;
    lib.checkSize = @checkSize;
end

% This function converts the given information into x,y,z coordinates 
% using the given formulas. It also adjusts for the 0.2m height change.

function [xx, yy, zz] = getDepth(RR, iinz)
    [r , c] = find(RR>0);
    depth = single(RR(iinz))*0.001;
    xx = depth.';
    yy = transpose(depth.*(c-80)*(4/594));    
    zz = transpose(-depth.*(r-60)*(4/592))+0.2;

end

% This function inputs the x,y,z coordinates and rotates then by
% multiplying by the rotation matrix.
function [xx, yy, zz] = rotate(xx, yy, zz, angle)
    
    rotation = [cos(angle), 0, sin(angle); 0, 1, 0; -sin(angle), 0, cos(angle)];
    vector = (transpose([xx; yy; zz]) * rotation);
    xx = vector(:,1);
    yy = vector(:,2);
    zz = vector(:,3);
end

% This function rotates the points along the x axis.
function [xx, yy, zz] = rotateRoll(xx, yy, zz, angle)
    
    rotation = [1, 0, 0; 0, cos(angle), -sin(angle); 0, sin(angle), cos(angle)];
    vector = (transpose([xx; yy; zz]) * rotation);
    xx = vector(:,1);
    yy = vector(:,2);
    zz = vector(:,3);
end

% This functions finds the "useful" points .
function [xx2, yy2, zz2] = useful(xx, yy, zz)
    filtered = find(zz > 0.05 & zz < 1);
    zz2 = zz(filtered);
    xx2 = xx(filtered);
    yy2 = yy(filtered);
end

% This functions plots the two circles on the 3D plot.
function plotCircle(small_circle, big_circle)
    length = linspace(0, 2*pi);
    
    xCircleSmall = small_circle*cos(length);
    yCircleSmall = small_circle*sin(length);

    
    xCircleBig = big_circle*cos(length);
    yCircleBig = big_circle*sin(length);
    
    line(xCircleSmall,yCircleSmall,zeros(size(length)));
    line(xCircleBig,yCircleBig,zeros(size(length)));
end

% This function checks if the point is of interest.
function [xx, yy, zz] = interest(xx, yy, zz, small, big, zHeight)
    filtered = find(sqrt(xx.^2 + yy.^2) > small & sqrt(xx.^2 + yy.^2) < ...
        big & zz > zHeight);
    xx = xx(filtered);
    yy = yy(filtered);
    zz = zz(filtered);
end

% This function checks if the point is of interest.
function [xx2, yy2, zz2] = notInterest(xx, yy, zz, small, big, zHeight)
    filtered = find(~(sqrt(xx.^2 + yy.^2) > small & sqrt(xx.^2 + yy.^2) < ...
        big & zz > zHeight));
    xx2 = xx(filtered);
    yy2 = yy(filtered);
    zz2 = zz(filtered);
end

% This function checks if the vector is in the right format to be used in a
% a matrix multiplication, transforms it if not.
function [xx, yy, zz] = checkSize(xx, yy, zz)
    [r,c] = size(xx);
    if r > 1
        xx = xx.';
        yy = yy.';
        zz = zz.';  
    end;
end