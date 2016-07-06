function [licked, side, lick_side, prevL] = proc_lick_2AFC(lick_input,startTimer, prevL)
licked = false;
side = 99;
lick_side = 99;
if lick_input(1)==0
    
    if (toc(startTimer) - prevL)>0.02
        lickT = toc(startTimer);
        fprintf('R_%.2f',round(toc(startTimer),2))
        side = 'R';
        lick_side = 1;
        licked = true;
        
    end
    prevL = toc(startTimer);
    
    
elseif lick_input(2)==0
    
    if (toc(startTimer) - prevL)>0.02
        lickT = toc(startTimer);
        fprintf('L_%.2f',round(toc(startTimer),2))
        side = 'L';
        lick_side = 2;
        licked = true;
    end
    prevL = toc(startTimer);
    
elseif lick_input(3)==0
    
     if (toc(startTimer) - prevL)>0.02
        lickT = toc(startTimer);
        fprintf('freeL_%.2f',round(toc(startTimer),2))
        side = 'freeL';
        lick_side = 3;
        licked = false;
    end
    prevL = toc(startTimer);

elseif lick_input(4)==0
    
     if (toc(startTimer) - prevL)>0.02
        lickT = toc(startTimer);
        fprintf('freeR_%.2f',round(toc(startTimer),2))
        side = 'freeR';
        lick_side = 4;
        licked = false;
    end
    prevL = toc(startTimer);

    
end

end