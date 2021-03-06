clear all; close all; clear all hidden;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%       Define parameters       %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%    Define File Location    %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(cd);

folder = 'C:\Users\win-ajk009-admin\Documents\Behaviour_Scripts\Two_AFC\Imaging_Training_MATLAB\';
%folder = '/Users/samuelpicard/Desktop/Sensorimotor/';

base = [folder 'Data' filesep];
fTime = datestr(datetime('now','TimeZone','local'),'yyyymmdd-HHMMSS');
subj = input('Type subject name: ','s');

fName = ['Pretaining1_self_' subj '_' fTime '_data.txt'];
file_loc = strcat(base,fName);
fileID = fopen(file_loc,'at+');
paramfName = ['Pretaining1_self_' subj '_' fTime '_parameters'];
save(strcat(base,paramfName), 'params')

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


outputSingleScan(s,[1,1]); pause(0.1); outputSingleScan(s,[0,0])


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%        Setup Audio         %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

InitializePsychSound(1);
pahandle = PsychPortAudio('Open', [], 1, [], params.sampleRate, 1, [], 0.015);

global frqs sndMat


f_span = logspace(log10(params.minfreq),log10(params.maxfreq),params.numSteps);
centreFreq = f_span(2);
frqs = [8000,8000*2^1.5];
i = 1;
sndMat = cell(1);

%generate sounds
for frq = frqs
    sndMat{i} = gensin(frq,params.sndDur,params.sampleRate,params.edgeWin);
    i = i+1;
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%         Run Script
%%%%%%%%%%%%%%%%%%%%%%         %%%%%%%%%%%%%%%%%%%%%%%%%20161707
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%initialise the timers
tStart = tic; prevL = toc(tStart); sndT = toc(tStart); rewT = prevL; screenUpdateT = toc(tStart);



%initialise the counters
RlickCtr = 0; LlickCtr = 0; rewCnt = 0;

%initliase others
rewOn = false;
prevSnd = 0;
hasLicked = true;
licked = false;
side = 99;
hasplayed = false;
%intialise ITI
collected = [0,0]; rew_mtx = [0,0];

curr_ISI = abs(normrnd(params.ISI_short_MEAN,params.ISI_STD)) + 2;

%in this case, the stimulus is a click
clickL = 50; %clicklength in samples
click =  cat(2,zeros(1,500),ones(1,clickL),- ones(1,clickL),zeros(1,500));

while toc(tStart)<params.maxDur && rewCnt<params.maxRew
    
    
    %% lick detection and processing
    input = inputSingleScan(s);
    frame_Nr = input(5);
    %Here side is R or L when lick_side is 1 or 2, respectively
    [licked, side, lick_side, prevL] = proc_lick_2AFC(input,tStart, prevL);
    
    %update text file with lick times
    if any(lick_side==[1,2])
        fprintf(fileID,strcat('lick:',num2str(side),'_', ... 
                              num2str(toc(tStart)),'_', ...
                              num2str(frame_Nr),'\n'));
    end
    
    %deliver free reward on one side and print that you have done so in
    %text file
    if any(lick_side==[3,4])
        rew_mtx(lick_side-2) = 1;
        outputSingleScan(s,rew_mtx);
        rewT =  toc(tStart);
        rewOn = true;
        rewCnt = rewCnt + 1;
        
        fprintf(fileID,strcat('freeRew:',num2str(lick_side),'_',...
                               num2str(toc(tStart)),'_',...
                               num2str(frame_Nr),'\n'));
    end
    
    %Block of Code to get and play new stimulus
    if ((toc(tStart) - sndT) >= curr_ISI)
        rew_side = randi([1,2]);
        curr_ISI = abs(normrnd(params.ISI_long_MEAN,params.ISI_STD)) + 2;
        
        
        %[snd, vol, frq] = get_stim(sndIdx,frqs,centreFreq,params);
        %The click is callibrated to ~70dB
        snd = click;
        %PLAY SOUND
        PsychPortAudio('FillBuffer', pahandle, snd);
        PsychPortAudio('Start', pahandle);
        sndT = toc(tStart);
        
        
        fprintf(fileID,strcat('Sound:','click','_', ...
            num2str(sndT),'_', ...
            num2str(frame_Nr),'\n'));
        
        %flag specifying whether the animals has responded until now
        hasLicked = false;
        hasplayed = true;
    end
    
    if ((((toc(tStart)-sndT)>params.sndRewIntv)||hasLicked==true) && hasplayed==true)
        rew_mtx = [1,1];
        fprintf(fileID, ...
                strcat('rew:',num2str('RL'),'_', ...
                num2str(toc(tStart)),'_', ... 
                num2str(frame_Nr),'\n'));

        outputSingleScan(s,rew_mtx);
        fprintf('reward ')
        rewT =  toc(tStart);
        rewOn = true;
        rewCnt = rewCnt + 2;
        hasplayed = false;
        collected = [0,0];
        
        
    end
    
    
    %STOP REWARD DELIVERY
    if ( (toc(tStart)-rewT )>params.rewDur && rewOn )
        outputSingleScan(s,[0,0]) %close solenoids
        rew_mtx = [0,0];
        rewOn = false;
    end
    
    if (toc(tStart)-screenUpdateT)>2
        fprintf('\n');
        screenUpdateT = toc(tStart);
    end
    if (hasplayed==true && any(lick_side==[1,2]) && (toc(tStart)-sndT )<2)
        hasLicked = true;
    end
    
    if (hasplayed==false && any(lick_side==[1,2]))
        collected(lick_side) = 1;
        
    end
    
    if sum(collected)==2
        curr_ISI = abs(normrnd(params.ISI_short_MEAN,params.ISI_STD)) + 2;
    end
end


PsychPortAudio('Close');

