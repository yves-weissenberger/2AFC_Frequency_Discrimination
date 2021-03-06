



params = struct(...
    'sndDur', 0.3, ...         %length of sounds in s
    'sampleRate',192000, ...   %audio sample rate in Hz
    'edgeWin',0.01, ...        %size of cosine smoothing edge window in seconds
    'sndRewIntv',0.7 ...
    );


levels_stim_calibration = [75.6,76.4,73.9,75.0,76.2,73.3,73.9,74.7,72.2,72.9,73.7,73.2,73.1,72.4,72.2,70.8,72.2, ...
                     72.0,72.0,70.7,71.1,71.1,71.1,72.0,72.7,71.7,71.6,71.9,72.1,72.1,71.3,71.7,71.2,70.6, ...
                     70.4,70.8,69.8,70.0,70.9,71.2,71.0,69.6,69.0,68.7,68.6,68.2,67.6,67.1,66.1,65.5,65.5, ...
                     65.1,64.5,64.1,63.4,63.2,63.6,63.0,62.5,62.3,62.2,62.6,62.8,62.4,62.1,61.5,61.7,61.5, ...
                     61.3,60.9,60.3,60.7,59.9,60.1,60.0,59.7,60.3,59.4,59.2,58.5,58.7,59.1,57.9,57.9,57.5, ...
                     57.1,58.0,56.2,55.6,54.9,54.8,56.0,54.0,53.0,54.2,50.0,54.2,49.4,48.6];
                 
n = 80;
                 
levels_stim_calibration = levels_stim_calibration(1:n);
frqs = logspace(log10(2000),log10(32000),100);
frqs = frqs(1:n);






%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%        Setup Audio         %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

InitializePsychSound(1);
pahandle = PsychPortAudio('Open', [], 1, [], params.sampleRate, 1, [], 0.015);



%%


volm = 70;


exponent = .05;
while 1
    
    x = input('input sound frequency:');
    frq = double(x)*1000;
   % [~,sndIdx] = min(abs(frqs-frq));
    %gainF =  sqrt(10^((volm - levels_stim_calibration(sndIdx))/10));
    %exponent = gainF;

    snd = gensin(frq,params.sndDur,params.sampleRate,params.edgeWin)*exponent;
    %snd = randint(1,48000,[-1,1])*exponent;
    PsychPortAudio('FillBuffer', pahandle, snd);
    PsychPortAudio('Start', pahandle);

    
end


%% Sweep

frqs2 = logspace(log10(2000),log10(64000),12);
exponent = .1
for ii=frqs2
    frq = ii;
    ii./1000
    [~,sndIdx] = min(abs(frqs-frq));
    %gainF =  sqrt(10^((volm - levels_stim_calibration(sndIdx))/10));
    %exponent = gainF;

    snd = gensin(frq,params.sndDur,params.sampleRate,params.edgeWin)*exponent;
    PsychPortAudio('FillBuffer', pahandle, snd);
    PsychPortAudio('Start', pahandle);
    pause(params.sndDur*3);
end
sprintf('done')

%%
exponent = .05;

%snd = gensin(frq,params.sndDur,params.sampleRate,params.edgeWin)*exponent;
snd = randint(1,48000,[-1,1])*exponent;
PsychPortAudio('FillBuffer', pahandle, snd);
PsychPortAudio('Start', pahandle);
