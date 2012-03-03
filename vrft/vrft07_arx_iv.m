%% Very simple VRFT example
% PID controller in a ARX system
close all; clear all;
clc;
P=path;
path(P,'../functions')
P=path;
path(P,'../functions/signal')
P=path;
path(P,'../functions/plots')

rho_size=3;

m=10;
x=0.8;
y=0.9;
Ts=1;
exper = 100;
cut=1
%% ARX system: 
% G_0(z)=z/((z-x)(z-y))
% H_0(z)=z^2/((z-0.9)(z-0.8))
% M(z)=0.4/(z-0.6)

%% Ideal Controler
% C_0(z)=(0.4(z-0.9)(z-0.8))/(z(z-1))
% y(t)=G_0(z)*u(t)+H_0(z)*e(t)

model.a = [1 -(x+y) x*y]; 
model.b = [1 0];
model.c = [1 -(x+y) x*y];
model.d = [1 0 0];
model.mn = [0.4];
model.md = [1 -0.6];
model.TS = Ts;
model.delay = 1;
model.delay_func = tf([1],[1 0], model.TS);
model.noise_std = 0.001;
C_den=[1 -1 0];

M=tf(model.mn,model.md, model.TS);
L=(1-M)*M;
beta=[tf([1 0 0], C_den, model.TS); tf([1 0],C_den , model.TS);tf([1],C_den , model.TS)];

%Instrumental Variables
IV=beta*L*(inv(M)-1);

theta = zeros(exper, rho_size);
[u N]=f_get_prbs(m);

for i = 1: exper
    [el y] = f_get_vrft_el(model, u);
    [el2 y2] = f_get_vrft_el(model, u);
    ul=lsim(L,u);
    phy2=lsim(IV, y);
    instr2=lsim(IV, y2);
    phy=phy2(cut:max(size(phy2)),:,1);
    instr=instr2(cut:max(size(instr2)),:,1);
    theta(i,:)=inv(instr'*phy)*instr'*ul(cut:max(size(ul)));
end

variance =var(theta);
expect= [0.4 -0.68 0.288];
%f_draw_elipse3d(theta(:,1), theta(:,2), theta(:,3), expect(1), expect(2), expect(3));

C=tf(theta(1,:),C_den, model.TS);
Jvr=f_get_vrft_Jvr(C, el, u)*100000
Jmr=f_get_vrft_Jmr(C, model)*100000
variance
