function [newx, n_breaks,break_marks]=remove_breaks_from_spike_trains_info(spiketrain,breaklimit)
%this function recieves the spiketrain and the breaklimit (the longest
%possible "natural" break) it will then remove the breaks and concatinate
%the spikes


% break marks mark the sample after the cutting point in the beginning of a
% break (in the corrected sown train). n_breaks mark the number of such breaks
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
d=diff(newx);
g=find(abs(d)>900);
first_index=[];
interval_lengths=g(2:2:end)-g(1:2:end);
indexes=[];
temp_g=g(1:2:end)
for i=1:length(interval_lengths);
    indexes(i)=temp_g(i);
    temp_g=temp_g-interval_lengths(i);
end
    
newx(newx==1000)=[];
last_saccade=find(newx==1,1,'last');
newx=(newx(1:(last_saccade+500)));
n_breaks=length(c);
break_marks=indexes+1;
end
