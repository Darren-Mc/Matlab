function [ang1,ang2] = findLimit(fun1, fun2, ri, dr, R)
    global threshold deltamax;
    
    ulim=fun2(R,0)+(threshold+deltamax);
    llim=fun2(R,0)-(threshold+deltamax);
    ru = findZeroPrev(@(r) fun2(r,ulim),ri,dr,R);
    ang1u = fun1(ru,0)
    rl = findZeroPrev(@(r) fun2(r,llim),ri,dr,R);
    ang1l = fun1(rl,0)
%     rmin = findZeroPrev(@(r) fun1(r,smin),ri,dr,R);

%     phi = linspace(threshold-deltamax,threshold+deltamax,100);
    phi = [threshold-deltamax, threshold+deltamax];
    
    ang1 = zeros(size(phi));
    ang2 = zeros(size(phi));

    for i=1:length(phi)
        ang1(i) = fun1(R,0)+phi(i);
        if (~isnan(ang1(i)))
            r = findZeroPrev(@(r) fun1(r,ang1(i)),ri,dr,R);
            ang2(i) = fun2(r,0);
            if (~isnan(r))
                if ( ang1(i) > ang1u )
                    ang1(i) = ang1u;
                    ang2(i) = ulim;
                elseif ( ang1(i) < ang1l )
                    ang1(i) = ang1l;
                    ang2(i) = llim;
                end   
            end
        else
            ang2(i) = NaN;
        end
    end
end