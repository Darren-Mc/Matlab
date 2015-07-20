clear; clc;

global BASE_HEIGHT HUMERUS ULNA HAND;
BASE_HEIGHT = 169.0;   % base height (all mm)
HUMERUS = 146.05;      % shoulder to elbow
ULNA = 187.325;        % elbow to wrist 
HAND = 90.0;           % wrist to gripper tip

threshold = 10;
deltamax = 7.5;

basAngle_d = 90;
shlAngle_d = 90;
elbAngle_d = 90;
wriAngle_d = 90;

[elb_r, elb_h, wri_r, wri_h, tip_r, tip_h, handAngle_d] = forwardsKinematics(shlAngle_d, elbAngle_d, wriAngle_d);

wri0r = wri_r;
wri0h = wri_h;
theta0 = basAngle_d;

dr = 0.5;
dh = -1;
dtheta = 0.5;
hvec = tip_h:dh:0;
rvec = tip_r:dr:(wri_r+(length(hvec)-1)*dr);
thvec = theta0:dtheta:(theta0+(length(hvec)-1)*dtheta);

for i=2:length(hvec)

r1 = wri_r; h1 = wri_h; x1 = wri_r*sind(basAngle_d); y1 = wri_r*cosd(basAngle_d);
    
[shlAngle_d, elbAngle_d, wriAngle_d] = inverseKinematics(rvec(i), hvec(i), handAngle_d);

[elb_r, elb_h, wri_r, wri_h, tip_r, tip_h, handAngle_d] = forwardsKinematics(shlAngle_d, elbAngle_d, wriAngle_d);

basAngle_d = thvec(i);

r2 = wri_r; h2 = wri_h; wri1x = wri_r*sind(basAngle_d); wri1y = wri_r*cosd(basAngle_d); wri1z = wri_h;

elb1x = elb_r*sind(basAngle_d); elb1y = elb_r*cosd(basAngle_d); elb1z = elb_h;

tip1x = tip_r*sind(basAngle_d); tip1y = tip_r*cosd(basAngle_d); tip1z = tip_h;

dh = h2-h1; dr = r2-r1;

m = dh/dr; c = h1-m*r1;
omega = atan2d(dr,-dh);

delta = [-deltamax 0 deltamax];

elbr = HUMERUS*cosd(shlAngle_d+threshold-delta);

elbz = HUMERUS*sind(shlAngle_d+threshold-delta) + BASE_HEIGHT;

d = abs((r2-r1)*(h1-elbz)-(r1-elbr)*(h2-h1))/sqrt((r2-r1)^2+(h2-h1)^2);

phi = shlAngle_d + threshold-delta + elbAngle_d - 180;

for i=1:length(phi)

    if (phi(i) < ULNA)
        if (phi(i) > omega - acosd(d(i)/ULNA))
            phi(i) = omega - acosd(d(i)/ULNA);
        end
    end

end

wrir = elbr + ULNA*cosd(phi);
wriz = elbz + ULNA*sind(phi);
theta = theta0 + (wrir-wri0r)*dtheta/dr;

wrix = wrir.*sind(theta);
wriy = wrir.*cosd(theta);

elbx = elbr.*sind(theta);
elby = elbr.*cosd(theta);

t = linspace(0,1,50);
s = linspace(0,1,100)';
c = normpdf(s,0.5,0.2);
c = c - min(c);
c = c./abs(max(c));

wr = wrir(1) + s*(wrir(3)-wrir(1));
wz = wriz(1) + s*(wriz(3)-wriz(1));

for n=1:length(s)
    s2w = wr(n)^2 + (wz(n)-BASE_HEIGHT)^2;
    theta4 = acosd((s2w+ULNA^2-HUMERUS^2)/(2*sqrt(s2w)*ULNA))+ atan2d(wr(n),wz(n)-BASE_HEIGHT)-90;
    wr4(n,:) = wr(n)-t*ULNA*cosd(theta4);
    wz4(n,:) = wz(n)+t*ULNA*sind(theta4);
    %wr4(n,:) = wr(n)-t*(wr(n)^2+ULNA^2-(wz(n)-BASE_HEIGHT)-HUMERUS^2)./(2*wr(n));
    %wz4(n,:) = sqrt(t*ULNA - wr4(n,:));
end


    
ur1 = 0 + t*(elbr(1)); uz1 = BASE_HEIGHT + t*(elbz(1)-BASE_HEIGHT);
vr1 = 0 + t*(elbr(3)); vz1 = BASE_HEIGHT + t*(elbz(3)-BASE_HEIGHT);

ur2 = elbr(1) + t*(wrir(1)-elbr(1)); uz2 = elbz(1) + t*(wriz(1)-elbz(1));
vr2 = elbr(3) + t*(wrir(3)-elbr(3)); vz2 = elbz(3) + t*(wriz(3)-elbz(3));

ur3 = wrir(1) + t*0; uz3 = wriz(1) - t*HAND;
vr3 = wrir(3) + t*0; vz3 = wriz(3) - t*HAND;

for n=1:length(s)
    wr1(:,n) = ur1 + s(n)*(vr1-ur1); wz1(:,n) = uz1 + s(n)*(vz1-uz1);
    wr2(:,n) = ur2 + s(n)*(vr2-ur2); wz2(:,n) = uz2 + s(n)*(vz2-uz2);
    wr3(:,n) = ur3 + s(n)*(vr3-ur3); wz3(:,n) = uz3 + s(n)*(vz3-uz3);
end

wtheta = ((theta(1) + s*(theta(3)-theta(1)))*ones(size(t)))';
wtheta2 = (theta(1) + s*(theta(3)-theta(1))*ones(size(t)));

wx1 = wr1.*sind(wtheta);
wy1 = wr1.*cosd(wtheta);

wx2 = wr2.*sind(wtheta);
wy2 = wr2.*cosd(wtheta);

wx3 = wr3.*sind(wtheta);
wy3 = wr3.*cosd(wtheta);

wx4 = wr4.*sind(wtheta2);
wy4 = wr4.*cosd(wtheta2);

C = (c*ones(size(t)))';
C2 = (c*ones(size(t)));

% syms x y a b m c u
%    
% S = solve([(x-a)^2+(y-b)^2==u^2, y == m*x+c],x,y)
%    
% x2 = double(real(subs(S.x,{a,b,c,m,u},[a2,b2,C,M,ULNA])))
% 
% y2 = double(real(subs(S.y,{a,b,c,m,u},[a2,b2,C,M,ULNA])))

t1 = -500;
t2 = 500;

%C = -gradient(wz2);


plot3([0, 0, elb1x, wri1x, tip1x],[0, 0, elb1y, wri1y, tip1y],[0, BASE_HEIGHT, elb1z, wri1z, tip1z], 'r', [0 elbx(2) wrix(2) wrix(2)],[0 elby(2) wriy(2) wriy(2)],[BASE_HEIGHT elbz(2) wriz(2), wriz(2)-HAND],'b',rvec.*sind(thvec),rvec.*cosd(thvec),hvec+HAND,'k.','MarkerSize',1,'LineWidth',2);
hold on
%plot3(wx4,wy4,wz4,'g')
surf(wx1,wy1,wz1,'FaceAlpha','flat','AlphaDataMapping','none','AlphaData',C);
%surf(wx2,wy2,wz2,'FaceAlpha','flat','AlphaDataMapping','none','AlphaData',C);
surf(wx4,wy4,wz4,'FaceAlpha','flat','AlphaDataMapping','none','AlphaData',C2);
surf(wx3,wy3,wz3,'FaceAlpha','flat','AlphaDataMapping','none','AlphaData',C);
hold off
shading interp;
colormap([0.3 0.3 1]);
%plot3(x2(1),0,y2(1));

%fill3([elb_r*sind(basAngle_d), x2; a2*sind(th), a3*sind(th)],[elb_r*cosd(basAngle_d), y2; a2*cosd(th) a3*cosd(th)],[elb_h, h2; b2 b3],[0 0 0])

axis([-1.1*(HUMERUS+ULNA+HAND), 1.1*(HUMERUS+ULNA+HAND), -1.1*(HUMERUS+ULNA+HAND), 1.1*(HUMERUS+ULNA+HAND), 0, 1.1*(BASE_HEIGHT+HUMERUS)])

grid on

view(37.5,30)

pause(0.01);

end