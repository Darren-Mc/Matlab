clear; clc;

global BASE_HEIGHT HUMERUS ULNA HAND;
BASE_HEIGHT = 169.0;   % base height (all mm)
HUMERUS = 146.05;      % shoulder to elbow
ULNA = 187.325;        % elbow to wrist 
HAND = 90.0;           % wrist to gripper tip

delta = 10;

delta2 = 10;

basAngle_d = 90;
shlAngle_d = 90;
elbAngle_d = 90;
wriAngle_d = 90;

[elb_r, elb_h, wri_r, wri_h, tip_r, tip_h, handAngle_d] = forwardsKinematics(shlAngle_d, elbAngle_d, wriAngle_d);

tip_h_max = tip_h;

ri = wri_r;
hi = wri_h;
thetai = basAngle_d;

dr = 0.5;
dh = -1;
dtheta = 0.005;
hvec = tip_h:dh:0;
rvec = tip_r:dr:(wri_r+(length(hvec)-1)*dr);
thvec = basAngle_d:dtheta:(basAngle_d+(length(hvec)-1)*dtheta);

for i=2:length(hvec)

r1 = wri_r; h1 = wri_h; x1 = wri_r*sind(basAngle_d); y1 = wri_r*cosd(basAngle_d);
    
[shlAngle_d, elbAngle_d, wriAngle_d] = inverseKinematics(rvec(i), hvec(i), handAngle_d);

[elb_r, elb_h, wri_r, wri_h, tip_r, tip_h, handAngle_d] = forwardsKinematics(shlAngle_d, elbAngle_d, wriAngle_d);

basAngle_d = thvec(i);

r2 = wri_r; h2 = wri_h; x2 = wri_r*sind(basAngle_d); y2 = wri_r*cosd(basAngle_d);

elbx = elb_r*sind(basAngle_d); elby = elb_r*cosd(basAngle_d);

dh = h2-h1; dr = r2-r1;

m = dh/dr; c = h1-m*r1;
theta = atan2d(dr,-dh);

a2 = HUMERUS*cosd(shlAngle_d+delta);

b2 = HUMERUS*sind(shlAngle_d+delta) + BASE_HEIGHT;

d = abs((r2-r1)*(h1-b2)-(r1-a2)*(h2-h1))/sqrt((r2-r1)^2+(h2-h1)^2);

e = shlAngle_d + delta2 + elbAngle_d - 180;

if (e < ULNA)
    e2 = theta - acosd(d/ULNA);
    if (e2 < e)
        e = e2;
    end
end

a3 = a2 + ULNA*cosd(e);
b3 = b2 + ULNA*sind(e);
th = thetai + (a3-ri)*dtheta/dr;

a2x = a2*sind(th);
a2y = a2*cosd(th);
a2z = b2;

a3x = a3*sind(th);
a3y = a3*cosd(th);
a3z = b3;

C = cross([x2-elbx,y2-elby,h2-elb_h],[a2x-elbx,a2y-elby,a2z-elb_h]);

t = linspace(0,1,2);

ux = elbx + t*(x2-elbx);
uy = elby + t*(y2-elby);
uz = elb_h + t*(h2-elb_h);
vx = a2x + t*(a3x-a2x);
vy = a2y + t*(a3y-a2y);
vz = a2z + t*(a3z-a2z);

s = linspace(0,1,100)';

for n=1:length(s)
    wx(:,n) = ux + s(n)*(vx-ux);
    wy(:,n) = uy + s(n)*(vy-uy);
    wz(:,n) = uz + s(n)*(vz-uz);
end



% syms x y a b m c u
%    
% S = solve([(x-a)^2+(y-b)^2==u^2, y == m*x+c],x,y)
%    
% x2 = double(real(subs(S.x,{a,b,c,m,u},[a2,b2,C,M,ULNA])))
% 
% y2 = double(real(subs(S.y,{a,b,c,m,u},[a2,b2,C,M,ULNA])))

t1 = -500;
t2 = 500;

plot3(wx,wy,wz,'m',[0, 0, elb_r*sind(basAngle_d), x2, tip_r*sind(basAngle_d)],[0, 0, elb_r*cosd(basAngle_d), y2, tip_r*cosd(basAngle_d)],[0, BASE_HEIGHT, elb_h, h2, tip_h], 'r', [0*sind(basAngle_d) a2x a3x a3x],[0*cosd(th) a2y a3y a3y],[BASE_HEIGHT a2z a3z, a3z-HAND],'b',rvec.*sind(thvec),rvec.*cosd(thvec),hvec+HAND,'k.','MarkerSize',1,'LineWidth',2);
%plot3(x2(1),0,y2(1));

%fill3([elb_r*sind(basAngle_d), x2; a2*sind(th), a3*sind(th)],[elb_r*cosd(basAngle_d), y2; a2*cosd(th) a3*cosd(th)],[elb_h, h2; b2 b3],[0 0 0])

axis([-1.1*(HUMERUS+ULNA+HAND), 1.1*(HUMERUS+ULNA+HAND), -1.1*(HUMERUS+ULNA+HAND), 1.1*(HUMERUS+ULNA+HAND), 0, 1.1*(BASE_HEIGHT+HUMERUS)])

grid on

view(37.5,30)

pause(0.01);

end


