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
cl%%
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


centreFreq = frqs(1);

frqs_dist = [centreFreq*2.^(-1/4),centreFreq,centreFreq*2.^(1/4)];

frq = frqs_dist(3)


%%
sndNr = 0
for exponent = logspace(log10(1e-3),log10(0.11481),20);
    sndNr = sndNr + 1
    exponent
    snd = gensin(frq,6,params.sampleRate,params.edgeWin);
    PsychPortAudio('FillBuffer', pahandle, snd*exponent);
    PsychPortAudio('Start', pahandle);
    pause(10)
    
end

%% Data

exponents = logspace(log10(1e-3),log10(0.11481),20);

%Volume in db
k16 =     [35.7,37.9,40.1,42.2,44.5,46.7,48.8,51.1,53.2,55.4,57.5,59.8,61.9, ...
    64.1,66.2,68.5,70.6,72.7,75.1,77.2];

k13 =     [39.0,41.1,43.1,45.5,47.6,49.8,51.9,54.0,56.3,58.4,60.5,62.7,64.9, ...
    67.1,69.2,71.3,73.5,75.7,77.9,80.1];

k11 =     [40.5,42.6,44.9,47.1,49.3,51.3,53.6,55.8,57.9,60.2,62.2,64.3,66.5, ...
    68.8,71.0,73.1,75.3,77.4,79.7,81.6];


k5 =    7.7 +  [37.9,40.4,42.8,44.4,46.9,48.5,50.7,52.8,55.2,57.1,59.5,61.8,64.1, ...
    66.0,68.2,70.1,72.5,74.9,76.9,78.9];

k4dot7 =  [38.3,40.1,42.3,45.0,46.8,48.6,51.0,53.2,55.4,57.7,59.9,61.9, ...
    64.1,66.0,68.3,70.6,73.0,74.7,77.2,79.3,];

k4 =      [40.1,42.4,44.3,45.8,48.8,50.5,52.6,54.8,56.8,58.9,61.4,63.1, ...
    65.6,67.9,69.7,72.1,74.4,76.6,78.7,80.8];

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
target = 50;
fit_F = @(x) coeffs(1).*x.^coeffs(2)+coeffs(3) - target;
fzero(fit_F,0.01)

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
end


%% Test
tic
sndIdx = 3;
global target
target = 47;
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

