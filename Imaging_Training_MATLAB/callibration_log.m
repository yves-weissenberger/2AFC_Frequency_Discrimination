%%

longsweep_2_32_03 = [75.6,76.4,73.9,75.0,76.2,73.3,73.9,74.7,72.2,72.9,73.7,73.2,73.1,72.4,72.2,70.8,72.2, ...
                     72.0,72.0,70.7,71.1,71.1,71.1,72.0,72.7,71.7,71.6,71.9,72.1,72.1,71.3,71.7,71.2,70.6, ...
                     70.4,70.8,69.8,70.0,70.9,71.2,71.0,69.6,69.0,68.7,68.6,68.2,67.6,67.1,66.1,65.5,65.5, ...
                     65.1,64.5,64.1,63.4,63.2,63.6,63.0,62.5,62.3,62.2,62.6,62.8,62.4,62.1,61.5,61.7,61.5, ...
                     61.3,60.9,60.3,60.7,59.9,60.1,60.0,59.7,60.3,59.4,59.2,58.5,58.7,59.1,57.9,57.9,57.5, ...
                     57.1,58.0,56.2,55.6,54.9,54.8,56.0,54.0,53.0,54.2,50.0,54.2,49.4,48.6];
                 
n = 80;
                 
longsweep_2_32_03 = longsweep_2_32_03(1:n);
frqs = logspace(log10(2000),log10(32000),100);
frqs = frqs(1:n);

plot(frqs,longsweep_2_32_03)


%% Fit Data
%Here we fit the offsets of the frequencies
x1 = 1:n;
global p
p = polyfit(frqs,longsweep_2_32_03,12);

x1 = linspace(min(frqs),max(frqs),100001);
y1 = polyval(p,x1);
hold on 
plot(frqs,longsweep_2_32_03,'o')
plot(x1,y1,'.')
hold off

        
figure()
hist(longsweep_2_32_03-polyval(p,frqs))


%% Now we get those offset

%get_offset = @(x) polval(p,x);
get_offset = @(p,x) polyval(p,x);
get_offset(p,600)
%%
levels_8kHz_sweep_03 = [77.3,75.8,74.9,74.2,74.8,74.4,73.9,72.7,72.1,71.1,71.1,70.9,70.2,69.9,69.2,68.9,68.8,69.1,68.8,68.2];
levels_8kHz_sweep_015 =[71.4,69.6,69.1,68.0,68.9,68.5,68.0,66.8,66.4,65.4,65.1,65.0,64.4,64.0,63.3,63.6,63.0,63.2,62.6,62.5];

hold on
plot(levels_8kHz_sweep_03,'o-')
plot(levels_8kHz_sweep_015,'o-')
%%
levels_8kHz_deltaLevel = [66.6,78.6,81.8,82.3];
levels_12kHz_deltaLevel = [63.2,75.2,78.3,78.8];
levels_16kHz_deltaLevel = [61.1,73.1,76.3,76.7];
levels_32kHz_deltaLevel = [47.2,58.9,62.1,63.0];
levels =[0.2, 0.8,1.4,2];


level_Mtx_deltaLevel = cat(1,levels_8kHz_deltaLevel, ...
                             levels_12kHz_deltaLevel, ...
                             levels_16kHz_deltaLevel, ...
                             levels_32kHz_deltaLevel);
                         
                         
level_Mtx_deltaLevel_norm = cat(1,levels_8kHz_deltaLevel./max(levels_8kHz_deltaLevel), ...
                             levels_12kHz_deltaLevel./max(levels_12kHz_deltaLevel), ...
                             levels_16kHz_deltaLevel./max(levels_16kHz_deltaLevel), ...
                             levels_32kHz_deltaLevel./max(levels_32kHz_deltaLevel));


plot(levels,flipud(level_Mtx_deltaLevel)','o-')
%set(gca, 'XScale', 'log')






%%
levels = logspace(log10(0.01),log10(4),10);


levels_8kHz_deltaLevel = [40.5,46.5,52.1,57.9,63.7,69.5,75.3,80.9,82.3,82.6];
levels_16kHz_deltaLevel = [35.1,40.8,46.5,52.3,58.1,63.9,69.7,75.3,76.6,77.1];
levels_32kHz_deltaLevel = [21.1,26.8,32.5,38.3,44.0,49.7,55.3,60.9,62.2,63.2];


level_Mtx_deltaLevel = cat(1,levels_8kHz_deltaLevel, ...
                             levels_16kHz_deltaLevel, ...
                             levels_32kHz_deltaLevel);

                         
hold on                        
%plot(levels,level_Mtx_deltaLevel + repmat(level_Mtx_deltaLevel(1,1) - level_Mtx_deltaLevel(:,1),1,10),'o-')


hold on
plot(levels,levels_8kHz_deltaLevel,'o-')
plot(levels,levels_16kHz_deltaLevel,'o-')
plot(levels,levels_32kHz_deltaLevel,'o-')

hold off


figure()

hold on
plot(levels,levels_8kHz_deltaLevel/max(levels_8kHz_deltaLevel),'o-')
plot(levels,levels_16kHz_deltaLevel/max(levels_16kHz_deltaLevel),'o-')
plot(levels,levels_32kHz_deltaLevel/max(levels_32kHz_deltaLevel),'o-')

hold off


%So this implies that there is an exponential relationship between "gain
%factor" and level. Different frequencies will offset by different amounts
%so then I guess the equation should look something like. Ok this is
%beautiful. Now we know that exponential function + an offset. A



%% Analysis
%Fit exponential function to the data from different frequencies to fit
%gain parameter

gainData = level_Mtx_deltaLevel + repmat(level_Mtx_deltaLevel(1,1) - level_Mtx_deltaLevel(:,1),1,10);

x = reshape(repmat(levels,3,1),1,30);
y = reshape(gainData,1,30);

hold on                        
plot((level_Mtx_deltaLevel + repmat(level_Mtx_deltaLevel(1,1) - level_Mtx_deltaLevel(:,1),1,10))','o-')


%%
f = fit(x',y','power2'); 
plot(f,x,y);

%% polynomial fit
p2 = polyfit(x,y,4);
x1 = x;
x1= linspace(0,4,1001);
y1 = polyval(p2,x1);
hold on 
plot(x,y,'o')
plot(x1,y1)
hold off


%% Find roots

global target
target = 60;
f = @(x) polyval(p,x) - target;
tic

fzero(f,1)
toc


%% Spline fit
global f
f = fit(x', y', 'smoothingspline');
plot(f,x,y);

spline_fit = @(x) feval(f,x);



gain_factors = linspace(0,5,1001);
fit_vals = f(gain_factors);

%% 

target_level = 60;
gain_factors(argmin(abs(target_level-fit_vals)))
%%
f = @(x) polyval(p,x) - target;

%%
modelFun = @(b,x) b(1).*log2(1+b(2).*x - b(3));
out = nlinfit(x',y',modelFun,rand(3,1));

hold on
plot(x,y,'o')
plot(x1,modelFun(out,x1))
%%

xx = linspace(min(levels),max(levels),40);
yy = spline(levels,gainData(1,:),xx);
hold on
plot(x(1:30),y(1:30),'o')
plot(xx,yy)


%% Inverse Exponential

funa = @(b,x) b(1) -1./(1+exp(x.*b(2) -b(3)));
out = nlinfit(x',y',funa,rand(2));
plot(x,funa(out,x))


%%
figure()
hold on
plot(ones(10,1),levels_8kHz_deltaLevel/max(levels_8kHz_deltaLevel),'o')
plot(ones(10,1)*2,levels_12kHz_deltaLevel/max(levels_12kHz_deltaLevel),'o')
plot(ones(10,1)*3,levels_16kHz_deltaLevel/max(levels_16kHz_deltaLevel),'o')
plot(ones(10,1)*4,levels_32kHz_deltaLevel/max(levels_32kHz_deltaLevel),'o')

xlim([0,6])


%%


figure()
hold on
plot(ones(4),levels_8kHz_deltaLevel,'o')
plot(ones(4)*2,levels_12kHz_deltaLevel,'o')
plot(ones(4)*3,levels_16kHz_deltaLevel,'o')
plot(ones(4)*4,levels_32kHz_deltaLevel,'o')

xlim([0,6])












%% calibration log 
%here record the lvel of a bunch of an 32Khz Pure tone presented at many
%different levels
%Can use very low gain factors for low frequencies then (ie around 0.001).
%For high frequency stimuli, can then 


%Notes: 
%1. Characterise frequencies with current gain on the amplifier and and 0.5
%this will get the level offset for all stimuli. Then get the level
%calibration curve at 

InitializePsychSound(1);
pahandle = PsychPortAudio('Open', [], 1, [], params.sampleRate, 1, [], 0.015);
%%

levels = logspace(log10(0.01),log10(0.1),2);

snd_dur = 20;
for level = levels
    frq = 2000;
    snd = gensin(frq,snd_dur,params.sampleRate,params.edgeWin);
    PsychPortAudio('FillBuffer', pahandle, snd*level);
    level
    PsychPortAudio('Start', pahandle);
    pause(snd_dur+3)

    
    
end
%% This is final code to do the callibration
% We can extract the offset from the polynomial fit to the data. And, given
% some offset, extract the gain that will give us the correct level, within
% bounds. Thus first, we need to work out what the upper and lower bound
% for level changes are. The lower bound is not too much of a problem, but
% the lowest level is the key question.
% Q1: What is the maximum level at the frequency with the lowest 'base'
% level?
%         A1: part1: From looking at the data, it seems it is 2x the lowest
%         level
%             part2:     
% Q2: How do we get a stimulus at the given level
%% Ok solution is just to do a fucking look up table. Can't be bothered...

measured_levels = [
                    ];
























