function [ KL ] = KL_correction( KL_tube,Num_MFRS,Num_PS,Num_TS,Num_BV,Num_CV )
%KL_CORRECTION contains minor losses for the experimental system in the
%   Alleyne Research Group at the University of Illinois at Urbana-
%   Champaign.

Mass_Sense_KL   = 20;
P_Sense_KL      = 3;
T_Sense_KL      = 1.5;
Ball_KL         = 3;
Check_Valve_KL  = 50;

KL = KL_tube +...
    Num_MFRS*Mass_Sense_KL +...
    Num_PS  *P_Sense_KL +...
    Num_TS  *T_Sense_KL +...
    Num_BV  *Ball_KL +...
    Num_CV  *Check_Valve_KL;
end

