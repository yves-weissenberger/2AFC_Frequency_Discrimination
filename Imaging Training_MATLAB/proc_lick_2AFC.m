function [licked, side, lick_side, prevL] = proc_lick(lick_input,startTimer, prevL)
licked = false;
side = 99;
lick_side = 99;
if lick_input(1)==0
    
    if (toc(startTimer) - prevL)>0.02
        lickT = toc(startTimer);
        side = 'R';
        lick_side = 1;
        licked = true;
        fprintf('%s-%f_____',side,toc(startTimer));

    end
    prevL = toc(startTimer);
    
    
elseif lick_input(2)==0
    
    if (toc(startTimer) - prevL)>0.02
        lickT = toc(startTimer);
        side = 'L';
        lick_side = 2;
        licked = true;
        fprintf('%s-%f_____',side,toc(startTimer));
    end
    prevL = toc(startTimer);
    
end

end