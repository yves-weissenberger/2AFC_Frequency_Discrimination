function [snd, volm, frq] = get_stim(idx,frqs,centreFreq,params,callibration_functions,stimType)


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
    
    
    snd =  gensin(frq,params.sndDur,params.sampleRate,params.edgeWin);
    
elseif strcmp(stimType,'ThreeByThree')
    %Here just select one of three stimuli for the task
    frqs_dist = [frqs(idx)*2.^(-1/4),frqs(idx),frqs(idx)*2.^(1/4)];
    
    probs = [.125,.75,.125];
    selector = cumsum(probs);
    [~, stim_idx] = max(selector>rand());
    
    snd_wave =  gensin(frqs_dist(stim_idx),params.sndDur,params.sampleRate,params.edgeWin);
    
    sndIdx = (idx-1)*3 + stim_idx;
    
    
    %Correct for volume stuff
    sndIdx = (idx-1)*3 + stim_idx;
    vols = [63,60,57,70,73,76];
    vol_idx = randi(6);

    volm = vols(vol_idx);
    x_test = logspace(log10(1e-3),log10(0.11481),5000);
    
    frq = callibration_functions{sndIdx,1};
    coeffs = callibration_functions{sndIdx,2};
    f_handle = @(x) coeffs(1).*x.^coeffs(2)+coeffs(3) - volm;
    fprintf('__frq:_%.2f V:_%.2f__',round(frq),volm)
    samples = f_handle(x_test);
    [~,idx] = min(abs(samples));
    exponent = x_test(idx);
    
    snd = snd_wave.*exponent;
    
    
elseif strcmp(stimType,'FRA')
        
     snd_wave =  gensin(frqs_dist(stim_idx),params.sndDur,params.sampleRate,params.edgeWin);
     vols = [63,60,57,70,73,76];

end

end
