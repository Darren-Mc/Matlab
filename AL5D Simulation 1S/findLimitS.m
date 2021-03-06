function [sp,sm,rlim,slim] = findLimitS(sfun, afun, ri, dr, R)
    global threshold;
    sp= sfun(R,0)+threshold;
    rsp = findZeroPrev(@(r) sfun(r,sp),ri,dr,R);
    sm = sfun(R,0)-threshold;
    rsm = findZeroPrev(@(r) sfun(r,sm),ri,dr,R);
    rval = [R rsp rsm];
    rval = rval(~isnan(rval));   
    if (dr > 0)
        rval = sort(rval);
    else
        rval = sort(rval,'descend');
    end
    rval = rval(cumsum(rval==R)==0);
    if (numel(rval) > 0)
        rlim = rval;
    else
        rlim = ri;
    end

    slim = sfun(rlim,0);
end