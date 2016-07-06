clear all; close all; clear all hidden;

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
    'rewDur',0.08,...         %solenoid opening duration in seconds
    'maxRew',300, ...          %maximum number of rewards during experiment
    'ISI_MEAN',6,...        %inter stimulus interval
    'ISI_STD',2,...
    'maxDur',2700, ...          %maximum time of experiment in seconds
    'sndRewIntv',0.7 ...
    );



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%    Define File Location    %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(cd);

folder = 'C:\Users\win-ajk009-admin\Documents\Behaviour_Scripts\Two_AFC\Imaging Training_MATLAB';
%folder = '/Users/samuelpicard/Desktop/Sensorimotor/';

base = [folder 'Data' filesep];
fTime = datestr(datetime('now','TimeZone','local'),'yyyymmdd-HHMMSS');
subj = input('Type subject name: ','s');

fName = ['2AFC_' subj '_' fTime '_data.txt'];
file_loc = strcat(base,fName);
fileID = fopen(file_loc,'at+');


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
%%%%%%%%%%%%%%%%%%%%%%         Run Script         %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%initialise the timers
tStart = tic; prevL = toc(tStart); sndT = toc(tStart); rewT = prevL;


%initialise the counters
RlickCtr = 0; LlickCtr = 0; rewCnt = 0;

%initliase others
rewOn = false;
prevSnd = 0;
resp = true;
licked = false;
side = 99;

%intialise ITI
curr_ISI = abs(normrnd(params.ISI_MEAN,params.ISI_STD)) + 2;

while toc(tStart)<params.maxDur && rewCnt<params.maxRew
    
    
    %% lick detection and processing
    %% lick detection and processing
    input = inputSingleScan(s);
    frame_Nr = input(3);
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
    
    
    %%
    %Block of Code to get and play new stimulus
    if (toc(tStart) - sndT) >= curr_ISI
        rew_side = randi([1,2]);
        
        
        if params.numSteps>2;
            sndIdx = randi([1,params.numSteps/2]) + (rew_side-1)*params.numSteps/2;
        else
            sndIdx = rew_side;
        end
        
        [snd, vol, frq] = get_stim(sndIdx,frqs,centreFreq,params);
        
        %PLAY SOUND
        PsychPortAudio('FillBuffer', pahandle, snd);
        PsychPortAudio('Start', pahandle);
        sndT = toc(tStart);
        
        
        fprintf(fileID,strcat('Sound:',num2str(sndIdx),'_', ...
            'V:',num2str(vol),'_', ...
            'F:',num2str(frq),'_', ...
            num2str(sndT),'_', ...
            num2str(frame_Nr),'\n'));
        
        %flag specifying whether the animals has responded until now
        resp = false;
        free = true;
    end
    %% Free Reward Delivery
    %if free reward is to be delivered (ie. if the mouse responded
    %incorrectly or not at all)
    if free==true
        %and sndRewInv seconds have passed since the sound was played
        if (toc(tStart)-sndT)>params.sndRewIntv
            rew_mtx = [0,0];
            rew_mtx(rew_side) = 1;  %set side to deliver reward on
            outputSingleScan(s,rew_mtx); %deliver reward
            rewT =  toc(tStart); %update timer
            rewOn = true; %set reward to being delivered
            rewCnt = rewCnt+1; %increment reward counter
            fprintf(fileID,strcat('rew:',num2str(rew_side),'_',num2str(rewT),'_',num2str(frame_Nr),'\n')); %print rew to file
        end
    end
    
    %% Response ckecing
    %If the mouse licks either right or left
    if (side=='R' || side=='L')
        'responded'
        %if the mouse has not responded yet and is within the response
        %window
        if (resp==false && (toc(tStart)-sndT)<params.sndRewIntv-0.1)
            %if the lick is on the correct side
            if lick_side==rew_side
                rew_mtx = [0,0];
                rew_mtx(rew_side) = 1;  %set reward to be delivered
                outputSingleScan(s,rew_mtx);   %deliver reward on the appropriate side
                Disp('reward')
                rewT =  toc(tStart);
                rewOn = true;
                rewCnt = rewCnt+1;
                
                % write the file
                fprintf(fileID,strcat('rew:',num2str(rew_side),'_',num2str(rewT),'_',num2str(frame_Nr),'\n'));
                free = false; %set flag for free reward to false                
            end
            resp=true; %signal that the mouse has responded
        end
    end
        
        
        
    
    %STOP REWARD DELIVERY
    if ( (toc(tStart)-rewT )>params.rewDur && rewOn )
        outputSingleScan(s,[0,0]) %close solenoids
        rewOn = false;
    end
    
    
    
end


PsychPortAudio('Close');

