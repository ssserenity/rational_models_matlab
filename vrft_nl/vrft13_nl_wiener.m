% VRFT method using a non-linear model
% real system: y(k)=0.9y(k-1)+tanh(u(t-1))
%========================================================================
close all; clear all;
clc;
P=path;
path(P,'../functions')
P=path;
path(P,'../functions/signal')
P=path;
path(P,'../functions/plots')
P=path;
path(P,'../functions/rational')
P=path;
path(P,'../functions/vrft')

% simulation parameters
rho_size=10;
cut=1;
m=3;

% static non linearity
b1=1.5;b3=0.5;
ga1=0.5;
gb1=0.9;

Ts=1;
exper = 10;

model.a = [1 -gb1]; 
model.b = [ga1];
model.mn = [0.4];
model.md = [1 -0.6];
model.TS = Ts;
model.delay = 1;
model.delay_func = tf([1],[1 0], model.TS);
model.noise_std = 0;

M=tf(model.mn,model.md, model.TS);
G=tf(model.b,model.a, model.TS);
L=(1-M)*M;
Filter=tf([1],[1 -1], model.TS);


theta = zeros(exper, rho_size);
[u N]=f_get_prbs(m);
%========================================================================
% plant simul
%========================================================================
y2=lsim(G,u);
%% apply non linearity
for k=1:N
    y(k)=1*(b1*y2(k)+b3*y2(k)^3);
end

if max(y) > 10000
    error('y divergiu');
end
%========================================================================
% Controller model definition
%========================================================================

%% model parameter definition
% model example 
%y(k) = (y(k-a1)^b1)*(y(k-c1)^d1)+...+(y(k-an)^bn)*(y(k-cn)^dn)+(y(k-ua1)^ub1)*(u(k-uc1)^ud1)+...+(y(k-uan)^ubn)*(u(k-ucn)^udn)
%       1+(y(k-an1)^bn1)*(y(k-cn1)^dn1)+...+(y(k-am)^bm)*(y(k-cm)^dm)+(y(k-ua1)^ub1)*(u(k-uc1)^ud1)+...+(y(k-uan)^ubn)*(u(k-ucn)^udn)
m_rat.n_dim   = 10;
m_rat.dim     = 10;
% to indo do
m_rat.texp    = [1 2 3 4 5 1 2 3 4 5];
m_rat.yu      = [2 2 2 2 2 2 2 2 2 2];
m_rat.regr    = [0 0 0 0 0 1 1 1 1 1];
% tels if there is some non linearity like (y(k-a)^b)*(y(k-c)^d)
% r = 3 u = 2 y=1 none =0
m_rat.yplus_yur = [0 0 0 0 0 0 0 0 0 0];
% tels the d param
m_rat.yplus_exp = [0 0 0 0 0 0 0 0 0 0];
% tels the C param
m_rat.yplus_regr = [0 0 0 0 0 0 0 0 0 0];

m_rat.err_enable = true
%% Simulation parameters
simul=struct('N', N-2, 'nEstimates', 1, 'np', model.noise_std, 'maxError', 0.001, 'l', 100, 'diffConv', .1);

%========================================================================
% vrft
%========================================================================
for i = 1: exper
    [e y1] = f_get_vrft_e_nl(model, u, y');
    el=lsim(Filter, e);
    theta(i,:)= f_rational_model(simul, m_rat, [u(1)], u(1:max(size(u))-2), el(2:max(size(e))), 0, 0);
end

mtheta=mean(theta);
r=ones(1,N);
y=zeros(1,N);
e=zeros(1,N);
u=zeros(1,N);
u_hat=zeros(1,N);
for k=2:N
    e(k)=r(k)-y(k-1);
    u(k)=u(k-1)+mtheta(1)*e(k)+mtheta(2)*e(k)^2+mtheta(3)*e(k)^3+mtheta(4)*e(k)^4+mtheta(5)*e(k)^5+mtheta(6)*e(k-1)+mtheta(7)*e(k-1)^2+mtheta(8)*e(k-1)^3+mtheta(9)*e(k-1)^4+mtheta(10)*e(k-1)^5;
    u_hat(k+1)=gb1*u_hat(k)+ga1*u(k);
    y(k)=(b1*u_hat(k+1)+b3*u_hat(k)^3);
end
f_get_vrft_nl_Jmr(M,u(1:N-1), y(2:N))


stairs(y(2:N))
hold
step(M)
