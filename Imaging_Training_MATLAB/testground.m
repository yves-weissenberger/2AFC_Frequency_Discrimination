%%
tic
n = 5000;
idx =1;
a = zeros(1,n);
for i=1:n
    [snd, vol, frq] =  get_stim(idx,frqs,centreFreq,params,false);
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

%%
tStart = tic;
prevL = toc(tStart);

while true
    %% lick detection and processing
    input = inputSingleScan(s);
    input;
    frame_Nr = input(5)
    %Here side is R or L when lick_side is 1 or 2, respectively
    [licked, side, lick_side, prevL] = proc_lick_2AFC(input,tStart, prevL);
    
    if side~=99
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



%%

side = 'R';
fprintf('lick %s at time: %f\n',side,5.2)





%% Test manual reward delivery
%initialise the timers
tStart = tic; prevL = toc(tStart); sndT = toc(tStart); rewT = prevL; screenUpdateT = toc(tStart);



%initialise the counters
RlickCtr = 0; LlickCtr = 0; rewCnt = 0;

%initliase others
rewOn = false;
prevSnd = 0;
resp = true;
licked = false;
side = 99;
hasplayed = false;
%intialise ITI
collected = [0,0];

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Setup NI-board        %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

s = daq.createSession('ni');
device = daq.getDevices;
dev =  device(1);


addDigitalChannel(s,dev.ID, 'Port0/Line0:3', 'InputOnly');

%Setup digital outputs
addDigitalChannel(s,dev.ID,'Port1/Line2:3','OutputOnly')
outputSingleScan(s,[1,1])
outputSingleScan(s,[0,0])


% P2.7 can be configured as a counter; that is pin 9
addCounterInputChannel(s,dev.ID,0,'EdgeCount');



%%

rew_mtx = [0,0];

while true
    
    input = inputSingleScan(s);
    if sum(input)~=4
        input
    end
    
    frame_Nr = input(3);
    %Here side is R or L when lick_side is 1 or 2, respectively
    [licked, side, lick_side, prevL] = proc_lick_2AFC(input,tStart, prevL);
    
    if side~=99
        lick_side
    end
    
    %update text file with lick times
    if any((lick_side-[1,2])==0)
        %fprintf(fileID,strcat('lick:',num2str(side),'_', ... 
        %                     num2str(toc(tStart)),'_', ...
        %                      num2str(frame_Nr),'\n'));
    end
    
    %deliver free reward on one side and print that you have done so in
    %text file
    if any((lick_side-[3,4])==0)
        rew_mtx(lick_side-2) = 1;
        outputSingleScan(s,rew_mtx);
        rewT =  toc(tStart);
        rewOn = true;
        rewCnt = rewCnt + 1;

        %fprintf(fileID,strcat('rew:',num2str(lick_side),'_',...
        %                       num2str(toc(tStart)),'_',...
        %                       num2str(frame_Nr),'\n'));
    end
  %STOP REWARD DELIVERY
    if ( (toc(tStart)-rewT )>params.rewDur && rewOn )
        outputSingleScan(s,[0,0]) %close solenoids
        rew_mtx = [0,0];
        rewOn = false;
    end
end