%% PandO Method 
function PandO_method_with_global_R1()
%% Solar Cell Parameters
Isc=3.8;Voc=21.1;Ns=1;Gstc=1000;n=1.3;Rs=0.58; Voc_array=210;
%% Parameters for Updating Voc_array
N=10;a=1.1;Vt=0.7; t=0.0; D=0.80;
%% Simulink Program
Sim_program='MSX60_PS';
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
tp=1.5;
Plot_IV=0; % Change to flase or true 
Plot_PV(tp,Plot_IV,mdlWks,Sim_program);
%% Initialization 
persistent  Dmpp  Vmpp  Pmpp 
if isempty(Dmpp)
    Pmpp=1219.4;
    Vmpp=169.39;
    Dmpp=0.80142;
end
t=0.0; i=0; C=0;
%% Run P&O
while true
    Voc_array=Update_Voc(t,mdlWks,Sim_program,Voc,N,Vt,a,Gstc);
   [D,C] =PANDO(mdlWks,Sim_program,t,Vmpp,Pmpp,Dmpp,C);
    [Vs,Is,Ps,Gs] = Measure(t,mdlWks,Sim_program,Dmpp);
    Vmpp=Vs; Pmpp=Ps; Dmpp=D; 
      st='P&O _IN';
      if C ==1;
st='P&O_OUT :'; disp(st);
DV= {['time :',num2str(t)]...
     ['Pmpp :',num2str(Pmpp)],...
    ['Dmpp  :',num2str(Dmpp)]}; disp(DV);
        break;
    end
    
end


%% Global Search
t=1.5;
%% Check power limits for 10%
[Vs,Is,Ps,Gs] = Measure(t,mdlWks,Sim_program,Dmpp);
Voc_array=Update_Voc(t,mdlWks,Sim_program,Voc,N,Vt,a,Gstc);
e=10*Pmpp/100;
Pub=Pmpp + e;
Plb=Pmpp - e;
C10=(Ps <Pub  & Ps > Plb);
if C10==0 disp([' At Time :',num2str(t)]);
    disp('Global Serach Started');
    Vmpp=Vs; Pmpp=Ps;
end 

%% Track nearest Peak
 Vmpp=186.14;   Pmpp=561.92; Dmpp=0.88346;
Pd=[];Dd=[];
  while true
            Voc_array=Update_Voc(t,mdlWks,Sim_program,Voc,N,Vt,a,Gstc);
            [D,C] =PANDO(mdlWks,Sim_program,t,Vmpp,Pmpp,Dmpp,C10);
            [Vs,Is,Ps,Gs] = Measure(t,mdlWks,Sim_program,Dmpp);
            Vmpp=Vs; Pmpp=Ps; Dmpp=D;
            st='P&O _IN';
            if C ==1;
                 Pd=[Pd;Pmpp]; Dd=[Dd;Dmpp];
            break;
            end
  end
  
%% Start GP Track 
%% Define parameters 
Dmin=0.7*Voc/Voc_array; Dmax= Voc_array/Voc_array;
Delta=0.001; F=1; Pmpp_o=Pmpp; Dmpp_o=Dmpp; i=1;

% Global Tracking Start 
while true 
 
    % Define D
    D=Dmpp_o -i*F*Dmin; 
       disp([ 'i  :',num2str(i), '    D :', num2str(D)]);
    if F==1 %A
        if D> Dmin % B
             % Call Slope
    %------------------------------------------------------%
    [Vs1,Is,Ps1,Gs] = Measure(t,mdlWks,Sim_program,D); % 14
    [Vs2,Is,Ps2,Gs] = Measure(t,mdlWks,Sim_program,D+Delta);
    Slope=(Ps2-Ps1)/(Vs2-Vs1);
    if Slope < 0 % D
        % Call P&O
        while true
            Voc_array=Update_Voc(t,mdlWks,Sim_program,Voc,N,Vt,a,Gstc);
            [D,C] =PANDO(mdlWks,Sim_program,t,Vmpp,Pmpp,D,C10);
            [Vs,Is,Ps,Gs] = Measure(t,mdlWks,Sim_program,Dmpp);
            Vmpp=Vs; Pmpp=Ps; Dmpp=D;
            st='P&O _IN';
            if C ==1;
                 Pd=[Pd;Pmpp]; Dd=[Dd;Dmpp];
             break;
            end
        end
        if Pmpp > Pmpp_o %E
            i=1;
            Pmpp_o=Pmpp;
            Dmpp_o=Dmpp;
            continue;
        else %E
            if F==-1 %F
                'Direction Change'
                break;
            else %F
                % Direction Change
                F=-1;
                i=1;
                D=Dmpp_o;
                continue;
            end %F
        end %E
    else %D
        i=i+1;
        continue;
    end %D 
%------------------------------------------------------%
 else %B
            F=-1;
             'Direction Change'
            i=1;
            D=Dmpp_o;
            continue;
        end %B
 
    else %A
        if D < Dmax %C
            % Call slope 
%------------------------------------------------------%
    [Vs1,Is,Ps1,Gs] = Measure(t,mdlWks,Sim_program,D); % 14
    [Vs2,Is,Ps2,Gs] = Measure(t,mdlWks,Sim_program,D+Delta);
    Slope=(Ps2-Ps1)/(Vs2-Vs1);
    if Slope < 0 % D
        % Call P&O
        while true
            Voc_array=Update_Voc(t,mdlWks,Sim_program,Voc,N,Vt,a,Gstc);
            [D,C] =PANDO(mdlWks,Sim_program,t,Vmpp,Pmpp,D,C10);
            [Vs,Is,Ps,Gs] = Measure(t,mdlWks,Sim_program,Dmpp);
            Vmpp=Vs; Pmpp=Ps; Dmpp=D;
            st='P&O _IN';
            if C ==1;
                 Pd=[Pd;Pmpp]; Dd=[Dd;Dmpp];
            break;
            end
        end
        if Pmpp > Pmpp_o %E
            i=1;
            Pmpp_o=Pmpp;
            Vmpp_o=Vmpp;
            continue;
        else %E
            if F==-1 %F
                break;
            else %F
                % Direction Change
                F=-1;
                i=1;
                D=Dmpp_o;
                continue;
            end %F
        end %E
    else %D
        i=i+1;
        continue;
    end %D 
%------------------------------------------------------%
            
        else %C
            break;
        end %C
    end %A
       
end 
%Global Tracking end 
 PD=[Pd, Dd];
 PD(1:3)
 Pmpp=roundn(max(Pd),-2);
 Dmpp=Dd(find(Pd==max(Pd)));
 disp( ['Pmpp  :',num2str(Pmpp)]);
 disp(['Dmpp  :',num2str(Dmpp)]);
 end 

%% Plot IV and PV Characteristics
function Plot_PV(t,Plot_IV,mdlWks,Sim_program)
Vp=[]; Ip=[]; Pp=[];
if Plot_IV==true
 for D=0:0.01:1.5
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
%% Hill Climbing P&O Method
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
 C=(S1 < 1.0 & S1 > -1.0);
 [-1.0,S1,1];
end 
