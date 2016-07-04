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