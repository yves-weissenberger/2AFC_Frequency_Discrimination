function wave =gensin_legacy(freq, duration,sampleRate,edge_window)
% gensin generates smoothed sinwaves
%   wave = gensin(k) generates a 1s, kHz, sinusoid 
%   with rate of 195312Hz (TDT-default) and 10ms
%   cosine on-off ramps
%
%   Extended argument specification:
%   wave = gensin(freq,duration,sampleRate,edge_window)
%


switch nargin
    case 1
        duration = 1;
        sampleRate = 195312;
        edge_window = 0.01;
    case 2
        sampleRate = 195312;
        edge_window = 0.01;
    case 3
        edge_window = 0.01;
    case 4
        1+1;
    otherwise
        error('not enough arguments');
end


cycles = linspace(0,duration*2*pi,duration*sampleRate);
wave = sin(cycles*freq);
smoothSamps = round(edge_window*sampleRate);
wave(1:smoothSamps) = wave(1:smoothSamps).* cos(pi*linspace(.5,1,smoothSamps)).^2;
wave(end-smoothSamps+1:end) = wave(end-smoothSamps+1:end).* cos(pi*linspace(1,.5,smoothSamps)).^2;
wave = single(wave);
end

%%

