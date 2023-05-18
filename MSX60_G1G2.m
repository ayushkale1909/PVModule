function MSX60_G1G2()
%% Solar Cell Parameters
Isc=3.8;Voc=21.1;Ns=1;Gstc=1000;n=1.3;Rs=0.58; Voc_array=210;
%% Parameters for Updating Voc_array
N=10;a=1.1;Vt=0.7;D=0.80;
%% parameeters for calclating G1 & G2
Isc_stc=3.8*2;
Impp_stc=3.5*2;
%% Simulink Program
%Sim_program='MSX60_US_G1G2';
Sim_program='MSX60_PS_G1G2';
format shortG;
%% Load parameters to Model Worksape
mdlWks = get_param(Sim_program,'ModelWorkspace');
assignin(mdlWks,'Isc',Isc);
assignin(mdlWks,'Voc',Voc);
assignin(mdlWks,'Ns',Ns);
assignin(mdlWks,'Gstc',Gstc);
assignin(mdlWks,'n',n);
assignin(mdlWks,'Rs',Rs);
assignin(mdlWks,'Voc_array',Voc_array);
%% Plot IV and PV
tp=0.0;
Plot_IV=false; % Change to flase or true 
Plot_PV(tp,Plot_IV,mdlWks,Sim_program);
%% Initialization 
persistent  Dmpp  Vmpp  Pmpp 
if isempty(Dmpp)
    Pmpp=1220;
    Vmpp=168.2;
    Dmpp= 0.80;
end
for t=[ 0.5,1.5,2.5,3.5]

    [Vs,Is,Ps,G] = Measure(t,mdlWks,Sim_program,Dmpp);
    e=10*Pmpp/100;
    Pub=Pmpp + e;
    Plb=Pmpp - e;
    C10=(Ps <Pub  & Ps > Plb);
    [G1,G2,DG] = PS_Check(C10,mdlWks,Sim_program,t,Voc_array,...
             Gstc,Isc_stc,Impp_stc);
 if DG >45
     disp(['Time   ', num2str(t),'   Partial Shading   :', num2str(DG)]);
     
 else
     disp(['Time    ', num2str(t),'    Uniform Irradiance  :', num2str(DG)]);
 end
 
end 
end 
%% PS Check
function [G1,G2,DG] = PS_Check(C10,mdlWks,Sim_program,t,Voc_array,Gstc,Isc_stc,Impp_stc)
assignin(mdlWks,'Voc_array',Voc_array);
[Vs,Is,Ps,G] = Measure(t,mdlWks,Sim_program,0.8);
I_oc_array=Is;
V_oc_array=Vs;
[Vs,Is,Ps,G] = Measure(t,mdlWks,Sim_program,0.08);

I_oc_cell=Is;
V_oc_cell=Vs;
G1=I_oc_cell*Gstc/Isc_stc;
G2=I_oc_array*Gstc/(Impp_stc);
DG=abs(G2-G1);
end 

%% Measure V,I,P and G
function [V,I,P,G] = Measure(S_time,mdlWks,Sim_program,D)
assignin(mdlWks,'D',D);
assignin(mdlWks,'Flag',0);
assignin(mdlWks,'Flag',1);
[tout,xout,yout] = sim(Sim_program,[S_time,S_time]);
assignin(mdlWks,'Flag',0);
V=yout(:,1);
I=yout(:,2);
G=yout(:,3);
P=V*I;
end 
%% Update Voc Array
function [Voc_array]= Update_Voc(t,mdlWks,Sim_program,Voc,N,Vt,a,Gstc)
 [V,I,P,G] = Measure(t,mdlWks,Sim_program,0.8);
 Voc_array= Voc*N +a*Vt*N*log(G/Gstc);
 assignin(mdlWks,'Voc_array',Voc_array);
end 
%% Plot IV and PV Characteristics
function Plot_PV(t,Plot_IV,mdlWks,Sim_program)
Vp=[]; Ip=[]; Pp=[];
if Plot_IV==true
 for D=0:0.05:1.5
[V1,I1,P1,G1] = Measure(t,mdlWks,Sim_program,D);
Vp=[Vp;V1];
Ip=[Ip;I1];
Pp=[Pp;P1];
 end 
 %% Plot
 subplot(2,1,1);
 plot(Vp,Ip); hold all;
 axis([0 210 0 10]);
 grid on;
 subplot(2,1,2); hold all;
 plot(Vp,Pp); hold all;
 axis([0 210 0 1200]);
 grid on;
end 
end 
%% Hill Climbing P&O Method
function [D,Vs,Ps,C] =PANDO(mdlWks,Sim_program,t,Vp,Pp,Dp,C)
 PHY=0.001;
 [Vs,Is,Ps,Gs] = Measure(t,mdlWks,Sim_program,Dp+PHY);

 if C~=1
     S=(Ps-Pp)/(Vs-Vp);
     dP=(Ps-Pp);
     dPC=(dP > 0.0);
     if dPC == 1
         D=Dp+ PHY*S;
         [Vs,Is,Ps,Gs] = Measure(t,mdlWks,Sim_program,D);
     else
         D=Dp+ PHY*S;
          [Vs,Is,Ps,Gs] = Measure(t,mdlWks,Sim_program,D);
     end 
 else
     D=Dp;
      [Vs,Is,Ps,Gs] = Measure(t,mdlWks,Sim_program,D);
 end 
 % Power limits for 1%
 e=1*Pp/100;
 Pub=Pp + e;
 Plb=Pp - e;
 C=(Ps <Pub  & Ps > Plb);
 
end 