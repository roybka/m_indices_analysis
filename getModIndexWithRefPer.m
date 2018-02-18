function [modulation, originalModulation] = getModIndexWithRefPer(spikeTrain, refPeriod, fs, freq, winLen)
% This function includes a correction procedure that corrects the
% modulation index to accomodate for the refractory period.
% Input parameters:
%   spikeTrain: point process spike train
%   refPeriod: length of the absolute refractory period, in ms
%   fs: the sampling rate of the spike train, in Hz.
%   freq: the frequncy of the spectral peak.
%   winLen: the window length to use in the estimation of the spectrum
%
% Output parameters:  
%   modulation : The corrected modulation index of the spike train
%   originalModulation : The original modulation index of the spike train, without correction.

startBand = freq-2;
endBand = freq+2;
totalTime = length(spikeTrain);
firingRate = sum(spikeTrain)/(totalTime/1000);
[spectrum, freqRange,snr, peakPower, peakFreq] = powerSpectrum(spikeTrain, fs, startBand, endBand, winLen);
originalModulation=  getModulationIndex(peakPower, firingRate/1000 ,totalTime  , 10000, fs);

modulation = originalModulation;
if (originalModulation==0)
    return;
end
if (originalModulation > 1)
    return;
end

% calculate the firing rate without refractory period
totalTimeWithoutRef = totalTime - refPeriod*sum(spikeTrain);
meanRateWithoutRef  = (sum(spikeTrain)/(totalTimeWithoutRef /fs))/fs;
        
time=[1/fs:1/fs:totalTime/fs];

ex=1;
N= 100;
while ex
        rateFunc = (modulation*meanRateWithoutRef) *(cos(2*pi*freq*time))+meanRateWithoutRef;
        amps = zeros(1,N);
        for j = 1:N
            st= generatePoissonTrain(totalTime, rateFunc, refPeriod);              
            firingRate = sum(st)/(totalTime/1000);
            [spectrum, freqRange,snr, peakPower, peakFreq] = powerSpectrum(st, fs, startBand, endBand, winLen);

            amps(j) =  getModulationIndex(peakPower, firingRate/1000 ,totalTime  , 10000, fs);
        end
        reconstructedMods = mean(amps);
        if (reconstructedMods >=originalModulation)
            ex=0;
        else 
            modulation = modulation+0.01;
        end
end 


