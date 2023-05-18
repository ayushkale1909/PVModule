% PV Characteristic of Single Cell
% Solar Cell Parameters 
Tsim=250;
Isc=3.8;
Voc=21.1;
Ns=1;
Gstc=1000;
n=1.3;
Rs=0.58;
G=1000;
[tout,xout,yout] = sim('MSX60_10_by2_PS',[0 Tsim]);
V=yout(:,1);
I=yout(:,2);
P=V.*I;
Pmpp=max(P);
Vmpp=V(find(P==Pmpp));
Impp=I(find(P==Pmpp));
Voc=V(find(I <= 0));
Voc=Voc(1);
Isc=I(find(V==0));
Isc=Isc(1);
D={ 'G=',num2str(G(1));...
    'Pmpp=',num2str(Pmpp);...
    'Vmpp=',num2str(Vmpp);...
    'Impp=',num2str(Impp);...
    'Voc=',num2str(Voc);...
    'Isc=',num2str(Isc); };
disp(D);
subplot(2,1,1)
plot(V,I); hold all;
axis([0 220 0 10]);
grid on;
 subplot(2,1,2)
plot(V,P); hold all;
axis([0 220 0 1500]);
grid on;
