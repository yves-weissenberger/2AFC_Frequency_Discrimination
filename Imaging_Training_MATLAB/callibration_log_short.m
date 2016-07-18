%%


params = struct(...
    'sndDur', 0.2, ...         %length of sounds in s
    'numOct', 1.5, ...           %range of sounds in Octaves
    'minfreq',8000, ...        %min sound frequency in Hz
    'maxfreq',8000*(2^1.5), ...        %max sound frequency in Hz
    'numSteps',3, ...
    'sampleRate',192000, ...   %audio sample rate in Hz
    'edgeWin',0.01, ...        %size of cosine smoothing edge window in seconds
    'rewDur',0.06,...         %solenoid opening duration in seconds
    'maxRew',300, ...          %maximum number of rewards during experiment
    'ISI_short_MEAN',8,...        %inter stimulus interval
    'ISI_STD',1,...
    'ISI_long_MEAN',12,...        %inter stimulus interval
    'maxDur',2700, ...          %maximum time of experiment in seconds
    'sndRewIntv',0.7 ...
    );


%%
InitializePsychSound(1);
pahandle = PsychPortAudio('Open', [], 1, [], params.sampleRate, 1, [], 0.015);
%%
global frqs sndMat


frqs = [8000*2^-0.75,8000*2^.75];


f_span = logspace(log10(frqs(1)),log10(frqs(2)),6);
i = 1;
sndMat = cell(1);

%generate sounds
for frq = f_span
    sndMat{i} = gensin(frq,3,params.sampleRate,params.edgeWin);
    i = i+1;
end


%%

exponents = logspace(log10(1e-3),log10(.4),25);


centreFreq = frqs(2);

frqs_dist = [centreFreq*2.^(-1/4),centreFreq,centreFreq*2.^(1/4)];

frq = frqs_dist(3)


%%
sndNr = 0
frq = 4000
for exponent = exponents
    sndNr = sndNr + 1
    exponent
    snd = gensin(frq,8,params.sampleRate,params.edgeWin);
    PsychPortAudio('FillBuffer', pahandle, snd*exponent);
    PsychPortAudio('Start', pahandle);
    pause(10)

end

%% Data

exponents = logspace(log10(1e-3),log10(.4),25);

%vvolume in db

k16 = [27,29.4,31.3,33.5,35.6,37.8,39.9,42.1,44.2,46.2,48.2,50.2,52.1,54,56,57.45,59.5, ... 
        61.2,63.1,65.1,67,69,71.2,73.4,75.5,]
k13 = [32.9,35.1,37.2,39.5,41.6,43.7,45.8,48.0,50.1,52.2 ...   
        ]