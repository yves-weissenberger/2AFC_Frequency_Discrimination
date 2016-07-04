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