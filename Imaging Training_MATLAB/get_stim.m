function [snd, vol, frq] = get_stim(idx,frqs,centreFreq,params)

vol = randi([40,140]);
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

end
