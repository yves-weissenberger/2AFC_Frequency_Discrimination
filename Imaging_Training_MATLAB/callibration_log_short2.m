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
pahandle = PsychPortAudio('Open', [], 1, [], params.sampleRate, 1, [], 0.1);
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

exponents = logspace(log10(1e-3),log10(.4),10);


centreFreq = frqs(1);

frqs_dist = [centreFreq*2.^(-1/4),centreFreq,centreFreq*2.^(1/4)];

frq = frqs_dist(3)

%frq = 32000;

%%

frqs = logspace(log10(2000),log10(32000),32);

for fr = frqs
    exponent = 0.01
    snd = gensin(fr,3,params.sampleRate,params.edgeWin);
    PsychPortAudio('FillBuffer', pahandle, snd*exponent);
    PsychPortAudio('Start', pahandle);

    pause(5)
end


%levels_global = [68,67,69,69,69.5,68,66.5,65.5,67,71.5,68.5,70,68,67,67.5,65.5,62.1,63.5,62.5,59,58,60,59.5,58.1,58.5,56.9,58.5,55,51.5,48,43,38];

%levels = [70,69,72,71,68,69.5,68,66.5,67.5,67.5,68.5,67.1,68.5,68.7,65.9,65.,65.,63.8,64.2,64.5,64.8,63.8,58.8,61.,59,57,58,53.2,53.2,51.8,47,46.5];
levels_rems = [68,66,69,69,68,68,66.1,65.5,66.8,67.8,68.4,70,67.3,67.1,66,65.5,61.7,62.1,62.5,59,58,59.5,56.5,57.8,59,56,57.5,52,50.8,48.5,42,41];
%%
frq = 32000
% 6dB is doubling of amplitude
for exponent = logspace(log10(1e-3),log10(0.11481),20);
    sndNr = sndNr + 1
    exponent = .01;
    snd = gensin(frq,2,params.sampleRate,params.edgeWin);
    PsychPortAudio('FillBuffer', pahandle, snd*exponent);
    PsychPortAudio('Start', pahandle);
    pause(1)
    
end

%%

frq = 32000;
snd = gensin(frq,6,params.sampleRate,params.edgeWin)/12;
for i = 1:10
    snd = snd + gensin(i*frq,1,params.sampleRate,params.edgeWin)/12;
    
end
    
%%

 PsychPortAudio('FillBuffer', pahandle, snd*exponent);
    PsychPortAudio('Start', pahandle);

%% Data

exponents = logspace(log10(1e-3),log10(0.11481),20);

%Volume in db
k16 =     [];

k13 =     [];

k11 =     [];


k5 =      [];

k4dot7 =  [];

k4 =      [];


%% Plot Data
figure()
%exponents = [1:20];
hold on
plot(exponents,k16)
plot(exponents,k13)
plot(exponents,k11)
plot(exponents,k5)
plot(exponents,k4dot7)
plot(exponents,k4)



%% Fit Data Example
xs=  [k4;k4dot7;k5;k11;k13;k16]
for i=1:6
    x = xs(i,:);
    f = fit(exponents',x','power2');
    coeffs = coeffvalues(f);
    fit_F = @(x) coeffs(1).*x.^coeffs(2)+coeffs(3);
    
    figure()
    hold on
    plot(exponents,x,'o')
    plot(f)
    coeffs = coeffvalues(f);
    fit_F = @(x) coeffs(1).*x.^coeffs(2)+coeffs(3);
    x_test = logspace(log10(1e-3),log10(0.11481),200);
    plot(x_test,fit_F(x_test),'.')
end

%% Find Zeros
tic
target = 70;
fit_F = @(x) coeffs(1).*x.^coeffs(2)+coeffs(3) - target;
fzero(fit_F,1)

toc



%% Create Storage for use

callibration_functions = cell(6,3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fit 4
centreFreq = frqs(1);
frqs_dist = [centreFreq*2.^(-1/4),centreFreq,centreFreq*2.^(1/4)];
frq = frqs_dist(1);
callibration_functions(1,1) = {frq};


f = fit(exponents',k4','power2');
coeffs = coeffvalues(f);
callibration_functions(1,2) = {coeffs};


fit_F = @(x) coeffs(1).*x.^coeffs(2)+coeffs(3);
callibration_functions(1,3) = {fit_F};



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fit 4.7
centreFreq = frqs(1);
frqs_dist = [centreFreq*2.^(-1/4),centreFreq,centreFreq*2.^(1/4)];
frq = frqs_dist(2);
callibration_functions(2,1) = {frq};


f = fit(exponents',k4dot7','power2');
coeffs = coeffvalues(f);
callibration_functions(2,2) = {coeffs};

fit_F = @(x) coeffs(1).*x.^coeffs(2)+coeffs(3);
callibration_functions(2,3) = {fit_F};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fit 5.6
centreFreq = frqs(1);
frqs_dist = [centreFreq*2.^(-1/4),centreFreq,centreFreq*2.^(1/4)];
frq = frqs_dist(3);
callibration_functions(3,1) = {frq};


f = fit(exponents',k5','power2');
coeffs = coeffvalues(f);
callibration_functions(3,2) = {coeffs};

fit_F = @(x) coeffs(1).*x.^coeffs(2)+coeffs(3);
callibration_functions(3,3) = {fit_F};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fit 11
centreFreq = frqs(2);
frqs_dist = [centreFreq*2.^(-1/4),centreFreq,centreFreq*2.^(1/4)];
frq = frqs_dist(1);
callibration_functions(4,1) = {frq};


f = fit(exponents',k11','power2');
coeffs = coeffvalues(f);
callibration_functions(4,2) = {coeffs};

fit_F = @(x) coeffs(1).*x.^coeffs(2)+coeffs(3);
callibration_functions(4,3) = {fit_F};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fit 13
centreFreq = frqs(2);
frqs_dist = [centreFreq*2.^(-1/4),centreFreq,centreFreq*2.^(1/4)];
frq = frqs_dist(2);
callibration_functions(5,1) = {frq};


f = fit(exponents',k13','power2');
coeffs = coeffvalues(f);
callibration_functions(5,2) = {coeffs};

fit_F = @(x) coeffs(1).*x.^coeffs(2)+coeffs(3);
callibration_functions(5,3) = {fit_F};



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fit 16
centreFreq = frqs(2);
frqs_dist = [centreFreq*2.^(-1/4),centreFreq,centreFreq*2.^(1/4)];
frq = frqs_dist(3);
callibration_functions(6,1) = {frq};


f = fit(exponents',k16','power2');
coeffs = coeffvalues(f);
callibration_functions(6,2) = {coeffs};

fit_F = @(x) coeffs(1).*x.^coeffs(2)+coeffs(3);
callibration_functions(6,3) = {fit_F};



%% Check whether it worked
exponents = logspace(log10(1e-3),log10(0.11481),20);

xs=  [k4;k4dot7;k5;k11;k13;k16];
for i=1:6
    figure(i)

    x = xs(i,:);
    coeffs = callibration_functions{i,2};
    fit_F = @(x) coeffs(1).*x.^coeffs(2)+coeffs(3);
    
    hold on
    plot(exponents,x,'o')
    x_test = logspace(log10(1e-3),log10(0.11481),200);
    plot(x_test,fit_F(x_test),'.')
    grid()
end


%% Test
tic
sndIdx = 6;
global target
target = 76;
x_test = logspace(log10(1e-3),log10(0.11481),5000);

frq = callibration_functions{sndIdx,1};
coeffs = callibration_functions{sndIdx,2};
f_handle = @(x) coeffs(1).*x.^coeffs(2)+coeffs(3) - target;

samples = f_handle(x_test);
[val,idx] = min(abs(samples));
%expoenent = fzero(f_handle,0.01) %not working properly for some reason
exponent = x_test(idx)
%exponent = 0.05429;

toc
%% Works -save
%base = 'C:\Users\win-ajk009-admin\Documents\Behaviour_Scripts\Two_AFC\Imaging_Training_MATLAB\';

%save(strcat(base,'callibration_function'), 'callibration_functions')


%%
snd = gensin(frq,6,params.sampleRate,params.edgeWin);
PsychPortAudio('FillBuffer', pahandle, snd*exponent);
PsychPortAudio('Start', pahandle);

