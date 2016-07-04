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
            rew_side = randi([1,2]);
            curr_ISI = abs(normrnd(params.ISI_MEAN,params.ISI_STD)) + 2;

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
        end

        if (toc(tStart)-sndT)>params.sndRewIntv
            rew_mtx = [1,1];
            fprintf(fileID,strcat('rew:',num2str('RL'),'_',num2str(rewT),'_',num2str(frame_Nr),'\n'));
            outputSingleScan(s,rew_mtx);
            'reward'
            rewT =  toc(tStart);
            rewOn = true;
            rewCnt = rewCnt + 1;

        end


       %STOP REWARD DELIVERY 
       if ( (toc(tStart)-rewT )>params.rewDur && rewOn )
            outputSingleScan(s,[0,0]) %close solenoids
            rewOn = false;
       end



    end


    PsychPortAudio('Close');

