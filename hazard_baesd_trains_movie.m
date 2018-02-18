

% simulates new spiketrains from Haz function. 
%to do:
%- verify saccade numbers
% - verify train length and distributions
% 


clear
load('C:\Users\Owner\Google Drive\Roy- experiments\checkerMicSac\dms8\sp_c_train_movie.mat')

cnt=0;pdfs=zeros(23,5000);
subjs=[5,8,9 ,12, 14:18, 20,22:23];
for snum=subjs
    cnt=cnt+1; 
    
    spikeTrain=double(sp_c_train{snum});
    
    %correction so that no pwelch window contains any "stitches":
    %************************
    for p=1:length(breakmarks{snum})
        
    spikeTrain(1+floor(breakmarks{snum}(p)/10000)*10000:ceil(breakmarks{snum}(p)/10000)*10000)=9;
    end
    spikeTrain(spikeTrain==9)=[];
    %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    
    a=find(spikeTrain);
    gaps=diff(a);
    %gaps=gaps(gaps<5000);
    for i=gaps
        if i<5000
        pdfs(snum,i)=pdfs(snum,i)+1;
        end
    end
   % pdfs(snum,:)=pdfs(snum,:)./(sum(pdfs(snum,:)));
    
    pd=smoothy(pdfs(snum,1:5000),50);
    pd=pd./sum(pd);
    pdfs(snum,:)=pd;
    cd=cumsum(pd);
    su=1-cd;
    haz=pd./su;
    hazs(cnt,:)=haz;
    
    
    
end
   

permute=1;

freq = 4;
fs = 1000;
%baseRate = 0.03;
%modulation = 0.25;
refPeriod = 0;
winLen = 10000;
cnt=0;
for snum=[5,8,9,12, 14:18, 20,22:23]
    cnt=cnt+1;
    spikeTrain=double(sp_c_train{snum});
    
    %correction so that no pwelch window contains any "stitches":
    %************************
    for p=1:length(breakmarks{snum})
        
    spikeTrain(1+floor(breakmarks{snum}(p)/10000)*10000:ceil(breakmarks{snum}(p)/10000)*10000)=9;
    end
    spikeTrain(spikeTrain==9)=[];
    %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    %spikeTrain=remove_breaks_from_spike_trains(spikeTrain,10000);
    %length(spikeTrain)==length(spikeTrain2)
    %spikeTrain=double(c_trains{snum});
    totalTime = length(spikeTrain)
    time=[0:1/fs:totalTime/fs];
    %baseRate = 0.03;
    %modulation = 0.25;
    refPeriod = 0;
    winLen = 10000;
    % rateFunc = (modulation*baseRate) * (cos(2*pi*freq*time))+baseRate;
    % spikeTrain = generatePoissonTrain(totalTime, rateFunc, refPeriod);
    firingRate = sum(spikeTrain)/(totalTime/1000);
    [spectra(cnt,:), freqRange,snr, peakPower, peakFreq] = powerSpectrum(spikeTrain, fs, freq-2, freq+2, winLen);
    modulationIndex = getModulationIndex(peakPower,firingRate/fs, totalTime , winLen, fs);
    frates(cnt)=firingRate;
    m_inds(cnt)=modulationIndex;
    
    
    nsacs=sum(sp_c_train{snum});
    nsacs_sub{cnt}=nsacs;
    if permute
    parfor k=1:1000
    gaps=[];
    
    haz=hazs(cnt,:);
    
    trace=false(1,length(sp_c_train{snum}));
    cur=1000;
    for i=1:nsacs
        %sacdone=0;
        cnt2=0;
        sacvec=rand(1,5000)<haz(1,:);
        t=find(sacvec,1,'first');
        if isempty(t)
            t=0;
        end
        trace(cur+t)=1;
        gap=t;
        %gaps=[gaps cnt2];
        cur=cur+t;
        
    end
    %gaps_sub{cnt}=gaps;
    if k==1
    subplot(3,4,cnt)
    gaps=diff(find(trace));
    hist(gaps,50)
    end
    spikeTrain= double(trace);
    totalTime = length(spikeTrain);
    firingRate = sum(spikeTrain)/(totalTime/1000);
    [spectrum, freqRange,snr, peakPower, peakFreq] = powerSpectrum(spikeTrain, fs, freq-2, freq+2, winLen);
         modulationIndex = getModulationIndex(peakPower,firingRate/fs, totalTime , winLen, fs);
            c_minds_sim(cnt,k)=modulationIndex;
    end
    end
end
    figure;
for i=1:12
   [y inds]=sort(c_minds_sim(i,:));
    p=(1000-find(m_inds(i)<y,1,'first'))/1000;
    if ~isempty(p)
    ps(i)=p;
    else
        ps(i)=0.001;
    end
    
    subplot(3,4,i)
    histogram(c_minds_sim(i,:),100)
    hold on
    plot([m_inds(i) m_inds(i)],[0 30],'r')
    title(['pval (rank) = ' num2str(ps(i))])

end

