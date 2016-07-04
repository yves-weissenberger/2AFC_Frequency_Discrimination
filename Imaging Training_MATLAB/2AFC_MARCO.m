

clear all; close all; clear all hidden;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%       Define parameters       %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

params = struct(...
    'sndDur', 0.2, ...         %length of sounds in s
    'numOct', 2, ...           %range of sounds in Octaves
    'minfreq',6000, ...        %min sound frequency in Hz
    'maxfreq',24000, ...        %max sound frequency in Hz
    'numSteps',6, ...
    'sampleRate',192000, ...   %audio sample rate in Hz
    'edgeWin',0.01, ...        %size of cosine smoothing edge window in seconds
    'rewDur',0.08,...         %solenoid opening duration in seconds
    'maxRew',300, ...          %maximum number of rewards during experiment
    'ISI_MEAN',6,...        %inter stimulus interval
    'ISI_STD',2,...
    'maxDur',2700 ...          %maximum time of experiment in seconds
    );


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%    Define File Location    %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(cd);

folder = 'C:\Users\win-ajk009-admin\Documents\Behaviour_Scripts\Two_AFC\';
%folder = '/Users/samuelpicard/Desktop/Sensorimotor/';

base = [folder 'Data' filesep];
fTime = datestr(datetime('now','TimeZone','local'),'yyyymmdd-HHMMSS');
subj = input('Type subject name: ','s');

fName = ['2AFC_' subj '_' fTime '_data'];
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


frqs = logspace(log10(params.minfreq),log10(params.maxfreq),params.numSteps);
%frqs = [6000,24000];
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

%sndIdx = targetFreq;a
prevSnd = 0;
tStart = tic;
prevL = toc(tStart);
sndT = toc(tStart);
rewT = prevL;
licked = false;
side = 99;
RlickCtr = 0; LlickCtr = 0;  %counters to keep track of licks for chaning sound frequency
rewCnt = 0;
rewOn = false;
resp = true;
curr_ISI = abs(normrnd(params.ISI_MEAN,params.ISI_STD)) + 2;
sndIdx = 0;
while toc(tStart)<params.maxDur && rewCnt<params.maxRew
    
    
    %% lick detection and processing
    input = inputSingleScan(s);
    frame_Nr = input(3);
    %Here side is R or L when lick_side is 1 or 2, respectively
    [licked, side, lick_side, prevL] = proc_lick_2AFC(input,tStart, prevL);
        
    
    %update text file with lick times
    if side~=99
        fprintf(fileID,strcat('lick:',num2str(side),'_',num2str(toc(tStart)),'_',num2str(frame_Nr),'\n'));
    end
    
    
    %Block of Code to get and play new stimulus
    if (toc(tStart) - sndT) >= curr_ISI
        frame_Nr
        rew_side = randi([1,2]);
        curr_ISI = abs(normrnd(params.ISI_MEAN,params.ISI_STD)) + 2;
        
        if params.numSteps> 2;
            sndIdx = randi([1,params.numSteps/2]) + (rew_side-1)*params.numSteps/2;
        else
            sndIdx = rew_side;
        end
        
        stim = gensin(frqs(sndIdx),params.sndDur,params.sampleRate,params.edgeWin);

        %PLAY SOUND
        
        PsychPortAudio('FillBuffer', pahandle, sndMat{sndIdx});
        PsychPortAudio('Start', pahandle);
        sndT = toc(tStart);
        
        
        fprintf(fileID,strcat('Sound:',num2str(sndIdx),'_',num2str(sndT),'_',num2str(frame_Nr),'\n'));
        resp = false;
    end
    
    
    %REW DELIVERY AND CHECK
    if resp==false
        if (side=='R' || side=='L')
            'responded'
            resp=true;
            if lick_side==rew_side
               rew_mtx = [0,0];
               rew_mtx(rew_side) = 1;
               outputSingleScan(s,rew_mtx);
               'reward'
               rewT =  toc(tStart);
               rewOn = true;
               rewCnt = rewCnt+1;
            
               % write the file
               fprintf(fileID,strcat('rew:',num2str(rew_side),'_',num2str(rewT),'_',num2str(frame_Nr),'\n'));

            end
        end
    end

    
   %STOP REWARD DELIVERY 
   if ( (toc(tStart)-rewT )>params.rewDur && rewOn )
        outputSingleScan(s,[0,0]) %close solenoids
        rewOn = false;
   end
    

        
end
    

PsychPortAudio('Close');