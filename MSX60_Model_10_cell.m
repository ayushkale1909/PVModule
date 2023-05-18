% PV Characteristic
Tsim=250;
%Open 'MSX60_10.mdl'
Isc=3.8;
Voc=21.1;
Ns=1;
Gstc=1000;
n=1.3;
Rs=0.58;

for G=[1000]
[tout,xout,yout] = sim('MSX60_10_cell',[0 Tsim]);
V=yout(:,1);
I=yout(:,2);
P=V.*I;
subplot(2,1,1)
plot(V,I); hold all;
axis([0 220 0 5]);
grid on;
 subplot(2,1,2)
plot(V,P); hold all;
axis([0 220 0 700]);
grid on;
Pmax=max(P);
Vmpp=V(find(P==Pmax));
Impp=I(find(P==Pmax));
R= Vmpp/Impp;

D={'G',num2str(G(1));'Pmax',num2str(Pmax);...
   'Vmpp',num2str(Vmpp); 'Impp',num2str(Impp);...
   'RL',num2str(R)};
disp(D);
end 