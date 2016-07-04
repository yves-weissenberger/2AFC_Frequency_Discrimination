%%
tic
n = 5000;
idx =1;
a = zeros(1,n);
for i=1:n
    [snd, vol, frq] =  get_stim(idx,frqs,centreFreq,params);
    frq;
    a(i) = frq;
end
toc

hist(a)
%set(gca, 'XScale', 'log')

%%

df = 6;
t_variance = 2*df/(df-2); %calculate variance of student t-distribution
arr = trnd(df,1,5000)/t_variance;
var(arr)
%aahist(arr)


%%
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%       Setup NI-board        %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    s = daq.createSession('ni');
    device = daq.getDevices;
    dev =  device(1);


    addDigitalChannel(s,dev.ID, 'Port0/Line0:1', 'InputOnly');

    %Setup digital outputs
    addDigitalChannel(s,dev.ID,'Port1/Line2:3','OutputOnly')
    outputSingleScan(s,[1,1])
    outputSingleScan(s,[0,0])


    % P2.7 can be configured as a counter; that is pin 9
    addCounterInputChannel(s,dev.ID,0,'EdgeCount');


tStart = tic;
prevL = toc(tStart);

while true
    %% lick detection and processing
    input = inputSingleScan(s);
    frame_Nr = input(3);
    %Here side is R or L when lick_side is 1 or 2, respectively
    [licked, side, lick_side, prevL] = proc_lick_2AFC(input,tStart, prevL);
    
    if side~=99
        side
    end
    
    %update text file with lick times
end


%%

outputSingleScan(s,[1,1])
outputSingleScan(s,[0,0])
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%        Setup Audio         %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

InitializePsychSound(1);
pahandle = PsychPortAudio('Open', [], 1, [], params.sampleRate, 1, [], 0.015);
%%
global frqs sndMat


f_span = logspace(log10(8000),log10(16000),6);
i = 1;
sndMat = cell(1);

%generate sounds
for frq = f_span
    sndMat{i} = gensin(frq,3,params.sampleRate,params.edgeWin);
    i = i+1;
end


%%

exponents = linspace(-.4,.4,20)

for exponent = exponents
    frq = 8000*(2^(exponent));
    frq
    snd = gensin(frq,8,params.sampleRate,params.edgeWin);
    PsychPortAudio('FillBuffer', pahandle, (1/2)*snd/3);
    PsychPortAudio('Start', pahandle);
    pause(10)

end



%%



%%

frqs = logspace(log10(2000),log10(32000),100);
iii = 0
for frq = frqs
    iii = iii+1
    frq
    snd = gensin(frq,5,params.sampleRate,params.edgeWin);
    PsychPortAudio('FillBuffer', pahandle, (1/2)*snd/3);
    PsychPortAudio('Start', pahandle);
    pause(7)

end


%% 


levels = logspace(log10(0.01),log10(4),10);

for level = levels
    frq = 32000;
    snd = gensin(frq,8,params.sampleRate,params.edgeWin);
    PsychPortAudio('FillBuffer', pahandle, snd*level);
    level
    PsychPortAudio('Start', pahandle);
    pause(10)

end