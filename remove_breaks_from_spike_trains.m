function [newx]=remove_breaks_from_spike_trains(spiketrain,breaklimit)
%this function recieves the spiketrain and the breaklimit (the longest
%possible "natural" break) it will then remove the breaks and concatinate
%the spikes

%deulat parmaters
break_spare_time=500;


%x=sp_train{12};
newx=double(spiketrain);
a=find(spiketrain);
b=diff(a);
c=find(b>breaklimit);
for i=c
    newx(a(i)+break_spare_time:(a(i)+b(i)+1-break_spare_time))=1000;
end
newx(newx==1000)=[];
last_saccade=find(newx==1,1,'last');
newx=[(newx(1:(last_saccade))) zeros(1,500)];

end
