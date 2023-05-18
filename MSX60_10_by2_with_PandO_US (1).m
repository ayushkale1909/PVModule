function MSX60_10_by2_with_PandO_US()
% Solar Cell Parameters
Isc=3.8;
Voc=21.1;
Ns=1;
Gstc=1000;
n=1.3;
Rs=0.58;
N=10;
a=1.1;
Vt=0.7;

Isc_stc=3.8;
Impp_stc=3.5;

Sim_program='MSX60_10_by2_PandO_US';
% Setting Parameter's to Model Workspace
mdlWks = get_param(Sim_program,'ModelWorkspace');
assignin(mdlWks,'Isc',Isc);
assignin(mdlWks,'Voc',Voc);
assignin(mdlWks,'Ns',Ns);
assignin(mdlWks,'Gstc',Gstc);
assignin(mdlWks,'n',n);
assignin(mdlWks,'Rs',Rs);
Voc_array=205.66;
assignin(mdlWks,'Voc_array',Voc_array);

% Initialize
persistent  Dprev  Vprev  Pprev 
if isempty(Dprev)
Pprev=630.5;
Vprev=173.15;
Dprev= 0.84;
end
format shortG;
Vd=[]; Id=[];Pd=[];Gd=[];
T_start=0;
T_step=50e-3;
T_sim=5;
count=0.0;

for t=T_start:T_step:T_sim
 
[V,I,P,G] = Sample(t,mdlWks,Sim_program,Dprev);
Voc_array= Voc*N +a*Vt*N*log(G/Gstc);
assignin(mdlWks,'Voc_array',Voc_array);
%-------------------------------------------%
 % Check power limits for 10%
 e=10*Pprev/100;
 Pub=Pprev + e;
 Plb=Pprev - e;
 C10=(P <Pub  & P > Plb);
 [Pub,P,Plb]
 [G1,G2,DG] = PS_Check(C10,mdlWks,Sim_program,t,Voc_array,...
     Gstc,Isc_stc,Impp_stc)
 if DG < 42
     'No Partial Shading'
     % Power limits for 1%
     e=1*Pprev/100;
     Pub=Pprev + e;
     Plb=Pprev - e;
     C1=(P <Pub  & P > Plb);
     [Pub,P,Plb]
     [D] =PANDO(V,Vprev,P,Pprev,Dprev,C1);
     Dprev=D;Pprev=P;Vprev=V;
     Vd=[Vd;V];
     Id=[Id;I];
     Pd=[Pd;P];
     Gd=[Gd;G];
     count=count+1;
     disp(['Count',num2str(count)]);
   else 
     'Yes, Partial Shading';
     'Global Search';
 end 
 

end 
subplot(4,1,1)
plot(Vd); hold all;
subplot(4,1,2)
plot(Id); hold all;
subplot(4,1,3)
plot(Pd); hold all;
subplot(4,1,4)
plot(Gd); hold all;
end 

function [V,I,P,G] = Sample(S_time,mdlWks,Sim_program,D)
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

function [D] =PANDO(Vs,Vp,Ps,Pp,Dp,C)
DeltaD=0.001;
 if C~=1
    
      if  Ps-Pp >0.0
      
          if  Vs-Vp >0.0
            D= Dp + DeltaD;
             
          else
              
              D=Dp - DeltaD;
          end
          
      else
          if  Vs-Vp >0.0
             D=Dp - DeltaD;
          else
              D=Dp + DeltaD;
          end
          
      end
      
  else
      D=Dp;
  end 
end 


function [G1,G2,DG] = PS_Check(C10,mdlWks,Sim_program,t,Voc_array,Gstc,Isc_stc,Impp_stc)
assignin(mdlWks,'Voc_array',Voc_array);
assignin(mdlWks,'D',0.8);
assignin(mdlWks,'Flag',0);
assignin(mdlWks,'Flag',1);
[tout,xout,yout] = sim(Sim_program,[t,t]);
assignin(mdlWks,'Flag',0);
V_oc_array=yout(:,1);
I_oc_array=yout(:,2);
G=yout(:,3);
I_oc_cell=yout(:,4);
V_oc_cell=yout(:,5);
G1=I_oc_cell*Gstc/Isc_stc;
G2=I_oc_array*Gstc/(2*Impp_stc);
DG=(G2-G1)/2;
end 