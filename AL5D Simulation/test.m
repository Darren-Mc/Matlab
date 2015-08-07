clear; clc;
BASE_HEIGHT = 169.0;   % base height (all mm)
HUMERUS = 146.05;      % shoulder to elbow
ULNA = 187.325;        % elbow to wrist 
HAND = 90.0;           % wrist to gripper tip
dr = 0.5;
dh = -1;
hi = 315.05;
ri = -12.675;
syms x y r
h = (dh/dr)*(r-ri)+hi;
s2w_r = r;
s2w_h = h-BASE_HEIGHT;
s2w = ( s2w_h * s2w_h ) + ( s2w_r * s2w_r ); % (Length of line from shoulder to wrist (S-W))^2
a1 = atan( s2w_h, s2w_r ); % Angle between S-W line and ground
a2 = acos((( HUMERUS^2 - ULNA^2 ) + s2w ) / ( 2 * HUMERUS * sqrt( s2w ) )); % Angle between S-W line and humerus
t = radtodeg(a1+a2);
tr = diff(t,r);
% a1x = solve(a1==x,r)
% 
% a2x = solve(a2==x,r)
% 
% solve(a1x+a2x==y,x)
funky = @(r) t;



hvec = hi:dh:HAND;
rvec = ri:dr:(ri+(length(hvec)-1)*dr);
thetavec = double(subs(t,r,rvec));
tr = double(subs(tr,r,rvec));
delta = 5;

% for i=50:rvec(end)
% i=50;
for n=1:100
index = n+70;
rf(n) = rvec(index);
[er(n), et(n), tf(n)] = findLimit(rvec(1),rf(n),delta);
% tf(n) = double(subs(t,r,rf(n)));
% % myfun = @(r) t == tf-10;
% delta = 2;
% ct(n)=tf(n)+delta;
% dt(n)=tf(n)-delta;
% 
% fun = @(r,C) (1007958012753983*acos((10*((2*r - 1207/10)^2 + r^2 - 3782334602438243/274877906944))/(2921*((2*r - 1207/10)^2 + r^2)^(1/2))))/17592186044416 + (1007958012753983*angle(r*(1 - 2*i) + (1207*i)/10))/17592186044416-C;
% func = @(r) fun(r,ct(n));
% fund = @(r) fun(r,dt(n));
% 
% skip=0;
% count=1;
% rtest = rvec(1);
% while (sign(func(rtest)) == sign(func(rf(n))))
%     if(count == index) 
%         skip = 1;
%         break;
%     end
%     count=count+1;
%     rtest = rvec(count);
% end
% 
% if (skip~=1)
%     cr(n)=fzero(func,[rtest,rf(n)])
% else
%     cr(n) = NaN;
% end
% 
% count=1;
% skip=0;
% rtest = rvec(1);
% while (sign(fund(rtest)) == sign(fund(rf(n))))
%     if(count == index) 
%         skip = 1;
%         break;
%     end
%     count=count+1;
%     rtest = rvec(count);
% end
% 
% if (skip~=1)
%     dr(n)=fzero(fund,[rtest,rf(n)]);
% else
%     dr(n) = NaN;
% end
% 
% % 
% % 
% 
% if isnan(cr(n))
%     if (isnan(dr(n)))
%         er(n) = NaN;
%     else
%         er(n) = dr(n);
%         et(n) = dt(n);
%     end
% else
%     if (isnan(dr(n)))
%         er(n) = cr(n);
%         et(n) = ct(n);
%     else
%         if (ct(n) > dt(n))
%             er(n) = cr(n);
%             et(n) = ct(n);
%         else
%             er(n) = dr(n);
%             et(n) = dt(n);
%         end
%     end
% end

pause(0.1);
plot(rvec,thetavec,rvec,10*tr,rf,tf,'r*',er,et,'c*');

end



% tr = subs(tr,[B,H,U],[BASE_HEIGHT, HUMERUS, ULNA]);
% th = subs(tr,[B,H,U],[BASE_HEIGHT, HUMERUS, ULNA]);
