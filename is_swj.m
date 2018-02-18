function out=is_swj(dx1,dy1,dx2,dy2,onset1,onset2,ang_c,r_c,timedif_c)
    [theta1,r1]=cart2pol(dx1,dy1);
    [theta2,r2]=cart2pol(dx2,dy2);
    mirrordifference=theta1-theta2+pi;
    if mirrordifference>pi
        mirrordifference=abs(mirrordifference-2*pi);
    end
    amp_dif=abs(r1-r2);
    timediff=  onset2-onset1;
    out=((mirrordifference<ang_c)&(timediff<timedif_c)&(amp_dif<r_c));
   % figure;compass([dx1 dx2],[dy1 dy2])
end
