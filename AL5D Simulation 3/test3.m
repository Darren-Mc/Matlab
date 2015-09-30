clear;
clc;

yaw1 = 45;
d = 10;
dd = 1;
yaw2 = yaw1-d:dd:yaw1+d;
yaw2 = yaw2;
pitch1 = yaw1;
pitch2 = pitch1-d:dd:pitch1+d;
pitch2 = pitch2';
ux = cosd(pitch2)*cosd(yaw2);
uy = cosd(pitch2)*sind(yaw2);
uz = sind(pitch2)*ones(size(yaw2));
vx = cosd(pitch1)*cosd(yaw1)
vy = cosd(pitch1)*sind(yaw1)
vz = sind(pitch1)
UX = ux(:);
UY = uy(:);
UZ = uz(:);

c = acosd(cosd(pitch1)*cosd(pitch2)*cosd(yaw1-yaw2)+sind(pitch1)*sind(pitch2)*ones(size(yaw2)));
c = 2*c./max(max(c));
c = 1-c;
C = c(:);

for i=1:numel(UX)
    x(i,:) = linspace(0,UX(i),10);
    y(i,:) = linspace(0,UY(i),10);
    z(i,:) = linspace(0,UZ(i),10);
    cc(i,:) = ones(1,10)*C(i);
end


plot3([0 vx], [0 vy], [0 vz]);
hold on
% surf(ux,uy,uz,'FaceAlpha','flat','AlphaDataMapping','none','AlphaData',c)
fill3(x,y,z,C);
shading interp;
colormap([0.3 0.3 1]);
% mesh(pitch2-pitch1,yaw2-yaw1,c)
% xlabel('Pitch Disparity (Degrees)')
% ylabel('Yaw Disparity (Degrees)')
% zlabel('Total Disparity (Degrees)')
axis([0 1 0 1 0 1])