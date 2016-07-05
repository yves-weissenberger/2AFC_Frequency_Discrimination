%function [gainF] = gain_factor_function(targetF,targetLevel)

%% Figure out the relationship between the offset

%This is the list of levels measured for the frequencies defined in frqs
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

%fit the relationship between frequency and level to get the offset level
p = polyfit(frqs,longsweep_2_32_03,12);

targetF= 4001;
%tarF_idx = argmin(abs(x1-targetF));
offset_level = polyval(p,targetF); %offset at that level

%%

x1 = linspace(min(frqs),max(frqs),100001);
y1 = polyval(p,x1);
hold on 
plot(frqs,longsweep_2_32_03,'o')
plot(x1,y1,'.')
hold off

        
figure()
hist(longsweep_2_32_03-polyval(p,frqs))

%%
gain_factors_test = logspace(log10(0.01),log10(4),10);  %gain factors to


levels_8kHz_deltaLevel = [40.5,46.5,52.1,57.9,63.7,69.5,75.3,80.9,82.3,82.6];
levels_16kHz_deltaLevel = [35.1,40.8,46.5,52.3,58.1,63.9,69.7,75.3,76.6,77.1];
levels_32kHz_deltaLevel = [21.1,26.8,32.5,38.3,44.0,49.7,55.3,60.9,62.2,63.2];


level_Mtx_deltaLevel = cat(1,levels_8kHz_deltaLevel, ...
                             levels_16kHz_deltaLevel, ...
                             levels_32kHz_deltaLevel);


                         
%reshape the data

gainData = level_Mtx_deltaLevel + repmat(level_Mtx_deltaLevel(1,1) - level_Mtx_deltaLevel(:,1),1,10);


add_offset = offset_level - gainData(1,1);


gainData = gainData + add_offset;
%convert data into easily fittable format
x = reshape(repmat(gain_factors_test,3,1),1,30);
y = reshape(gainData,1,30);

%fit the data with smoothing splines
f = fit(x', y', 'smoothingspline');

gain_factors = linspace(0,5,1001);
fit_vals = f(gain_factors);
target_level = 60;
gain_factors(argmin(abs(target_level-fit_vals)))



