% generate_colormap.m
%
% Utility script for generating a colormap along a user-defined path in hsv
% space.
%
% Nathanael Kazmierczak, 06/28/2023


% degrees = 0:355;
%% Generate the hue ring
n = 400;
rectbase = linspace(-1,1,n);
[xspace,yspace] = meshgrid(rectbase,rectbase);
[theta,rho] = cart2pol(xspace,yspace);
goodinds = (rho <= 1) & (rho >= 0.9);
hues = (theta - min(min(theta)))/(2*pi);
sats = ones(size(hues));
vals = ones(size(hues));
[rgb] = hsv2rgb([hues(:),sats(:),vals(:)]);
rgb(~goodinds,:) = 0.94;
r = reshape(rgb(:,1),size(hues));
g = reshape(rgb(:,2),size(hues));
b = reshape(rgb(:,3),size(hues));
figure;
imshow(cat(3,r,g,b));

%% Generate the saturation/value triangle 
thishue = 0.5;  % for the sake of generating this.
density = 0.002;
[ RGB_color_stack ] = getTriangleColorLegend(density,[thishue,1,1],[thishue,0,1]);
figure;
imagesc(RGB_color_stack);
% points = [0,0;
%           0.5,sqrt(3)/2;
%           1,0];
% n2 = 400;
% rectbase2 = linspace(0,1,n);
% [xspace2,yspace2] = meshgrid(rectbase2,rectbase2);
% ppoints = permute(points,[3,2,1]);
% xdist = ppoints(:,1,:) - xspace2;
% ydist = ppoints(:,2,:) - yspace2;
% dists = sqrt(xdist.^2 + ydist.^2);
% % saturation as dist1 / total dist to points 1 v 2
% sat2 = dists(:,:,1)./(dists(:,:,1) + dists(:,:,3));
% % val2 = dists(:,:,2)./(dists(:,:,2) + dists(:,:,3));
% val2 = dists(:,:,2);
% % sat2 = xspace2;
% % val2 = flipud(yspace2);
% hue2 = thishue*ones(size(sat2));
% [rgb2] = hsv2rgb([hue2(:),sat2(:),val2(:)]);
% goodinds2 = 
% % rgb2(~goodinds,:) = 0.94;
% r2 = reshape(rgb2(:,1),size(hues));
% g2 = reshape(rgb2(:,2),size(hues));
% b2 = reshape(rgb2(:,3),size(hues));
% figure;
% imshow(cat(3,r2,g2,b2));

