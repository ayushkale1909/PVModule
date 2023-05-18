
%% for calling P&O
while true
    Voc_array=Update_Voc(t,mdlWks,Sim_program,Voc,N,Vt,a,Gstc);
   [D,C] =PANDO(mdlWks,Sim_program,t,Vmpp,Pmpp,Dmpp,C)
    [Vs,Is,Ps,Gs] = Measure(t,mdlWks,Sim_program,Dmpp);
    Vmpp=Vs; Pmpp=Ps; Dmpp=D; 
      st='P&O _IN';
      if C ==1;
        st='P&O_OUT';
        DV={t,Vs,Is,Ps,Gs,D,st,Voc_array}
        break;
    end
    
end

%% Hill Climbing P&O Method_07_04_2021
function [D,C] =PANDO(mdlWks,Sim_program,t,Vp,Pp,Dp,C)
 PHY=0.001;

 if C~=1
     [Vs,Is,Ps,Gs] = Measure(t,mdlWks,Sim_program,Dp+PHY);
     S=(Ps-Pp)/(Vs-Vp);
     dP=(Ps-Pp);
     dPC=(dP > 0.0);
     if dPC == 1
         D=Dp+ PHY*S;
     else
         D=Dp+ PHY*S;
     end
 else
     D=Dp;
 end
 [Vs1,Is,Ps1,Gs] = Measure(t,mdlWks,Sim_program,D);
  [Vs2,Is,Ps2,Gs] = Measure(t,mdlWks,Sim_program,D+PHY);
 S1=(Ps2-Ps1)/(Vs2-Vs1);
 C=(S1 < 1.0 & S1 > -1.0)
 [-1.0,S1,1]
end 
