levels_8kHz_sweep = [77.3,75.8,74.9,74.2,74.8,74.4,73.9,72.7,72.1,71.1,71.1,70.9,70.2,69.9,69.2,68.9,68.8,69.1,68.8,68.2];


plot(levels_8kHz_sweep,'o-')

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

plot(level_Mtx_deltaLevel,'o-')

%%
figure()
hold on
plot(ones(4),levels_8kHz_deltaLevel/max(levels_8kHz_deltaLevel),'o')
plot(ones(4)*2,levels_12kHz_deltaLevel/max(levels_12kHz_deltaLevel),'o')
plot(ones(4)*3,levels_16kHz_deltaLevel/max(levels_16kHz_deltaLevel),'o')
plot(ones(4)*4,levels_32kHz_deltaLevel/max(levels_32kHz_deltaLevel),'o')

xlim([0,6])