function [snd_container, volm, frq] = get_stim_J_3_tones(idx,frqs,centreFreq,params,callibration_functions,stimType)


if strcmp(stimType,'fullDist')
    volm = randi([40,140]);
    boundary = centreFreq;
    
    SD = 1/6;
    %df = 6;
    %var_correction = 2*df/(df-2);
    
    frqMean = frqs(idx);
    
    if length(frqs)>2
        error('function not configured to deal with more than two frequencies')
    end
    
    
    if idx==1
        frq = boundary + 1000;
        while (frq>boundary || frq<2000)
            frq = frqMean*(2^normrnd(0,SD));
        end
    elseif idx==2
        frq = boundary - 1000;
        while (frq<boundary)
            frq = frqMean*(2^normrnd(0,SD));
            %frq = frqMean*(2^(trnd(df)/var_correction));
        end
    end
    
    
    snd_container =  gensin(frq,params.sndDur,params.sampleRate,params.edgeWin);
    
elseif strcmp(stimType,'ThreeByThree')
    %Here just select one of three stimuli for the task
    frqs_dist = [frqs(idx)*2.^(-1/4),frqs(idx),frqs(idx)*2.^(1/4)];
    
    probs = [.3333,.3334,.3333];%Johannes
    selector = cumsum(probs);
    [~, stim_idx] = max(selector>rand());
    
    snd_wave =  gensin(frqs_dist(stim_idx),params.sndDur,params.sampleRate,params.edgeWin);
    
    
    
    %Correct for volume stuff
    sndIdx = (idx-1)*3 + stim_idx;
    vols = [63,60 ,57,70,73,76];
    vol_idx = 4;%Johannes

    volm = vols(vol_idx);
    
    frq = callibration_functions{sndIdx,1};
    
    levels_stim_calibration = [57.9,61.9,58.6,58.1,57.2,57.4];
    gainF =  sqrt(10^((volm - levels_stim_calibration(sndIdx))/10));
    
    
    fprintf('__frq:_%.2f V:_%.2f__',round(frq),volm)
    exponent = 0.01*gainF;
    
    snd_container = snd_wave.*exponent;
    
    
elseif strcmp(stimType,'FRA')
    
    
    levels = [50,60,70,80];
    freq_idxs = 1:16;
    freqs = logspace(log10(4000),log10(48000),16);
    combinations = combvec(freq_idxs,levels);
    [~,nStim] = size(combinations);
    
    snd_container = cell(nStim+1,6);
    snd_container(1,1) = {'Frequency'};
    snd_container(1,2) = {'Level'};
    snd_container(1,3) = {'sndArr'};
    snd_container(1,4) = {'duration'};
    snd_container(1,5) = {'sample_rate'};
    snd_container(1,5) = {'ramp_dur'};

    
    snd_container(2:end,4) = {params.sndDur};
    snd_container(2:end,5) = {params.sampleRate};
    snd_container(2:end,6) = {params.edgeWin};
    x_test = logspace(log10(1e-3),log10(0.11481),5000);
    
    
    shuffle_order = randperm(nStim);
    shuffled_combinations = combinations(:,shuffle_order);
    
    for i=2:nStim+1
        fq_idx = shuffled_combinations(1,i-1);
        fq = freqs(fq_idx);                %extract frequency
        l = shuffled_combinations(2,i-1);  %extract level
        
        %callibration_functions{fq_idx,1};
        coeffs = callibration_functions{fq_idx,2};
        f_handle = @(x) coeffs(1).*x.^coeffs(2)+coeffs(3) - l;
        
        samples = f_handle(x_test);
        [~,idx] = min(abs(samples));
        exponent = x_test(idx);
        
        snd_wave =  gensin(fq,params.sndDur,params.sampleRate,params.edgeWin);

        snd_container(i,1) = {fq};
        snd_container(i,2) = {l};
        snd_container(i,3) = {snd_wave.*exponent};
    end
end

end
