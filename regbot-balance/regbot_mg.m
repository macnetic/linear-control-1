%% mekanisk_model_regbot
close all
clear
clc
%% parametre
% motor
RA = 3.3;    % ohm
JA = 1.3e-6; % motor inerti
LA = 6.6e-3; % ankerspole
BA = 3e-6;   % ankerfriktion
Kemf = 0.0105; % motorkonstant
Km = Kemf;
% kÃ¸retÃ¸j
NG = 9.69; % gear
WR = 0.03; % hjul radius
Bw = 0.155; % hjulafstand
% 
%% model af dele af robot - opdelt for at fÃ¥ rimelig bÃ¥de masse og inertimoment
% disse tal er brugt i simulink model
mmotor = 0.193;   % samlet masse af motor og gear [kg]
mframe = 0.32;    % samlet masse af ramme og print [kg]
mtopextra = 0.27; % extra masse pÃ¥ top (lader og batteri) [kg]
mpdist =  0.10;   % afstand til lÃ¥g [m]
startAngle = 25;  % in degrees
% forstyrrelse - skub position (Z)
pushDist = 0.1; % hvor pÃ¥ robot (i forhold til motoraksen) [m]
%% velocity controller (no balance) PI-regulator
% design resultat - hastighedsregulator:
% wcwv = 32; % rad/s % krydsfrekvens (ikke brugt)

% From previously designed position controller
alpha_wv = 0.1;
Kp_wv = 7.756; % Kp
Ti_wv = 0.250; % Tau_i
Td_wv = 0.264; % tau_d
%% linear model of robot in balance med motor controller
% fra velocity ref til tilt vinkel
[A,B,C,D] = linmod('regbot_1mg_2018b_wv_PIlead');
[num,den] = ss2tf(A,B,C,D);
%% poler og nulpunkter fra hastigheds-reference til tilt (pitch)
Gmp = minreal(tf(num,den)) %  motor vel-ref til pitch/tilt angle
tf_poler = pole(Gmp)
tf_nulpunkter = zero(Gmp)

figure(1);
pzmap(Gmp);
grid on;

% 1 pol i højre halvplan - systemet er ustabilt.
%% bodeplot balance - hastigheds-reference til tilt (pitch)
figure(2);
hold off;
ww = logspace(-3,4,1000);
bode(Gmp)
grid on
title('Bodeplot fra motor vel\_ref til tilt\_vinkel')

figure(3);
hold on;
nyquist(Gmp);
grid on;
set(gcf(),'PaperUnits','centimeters','PaperPosition',[0 0 12 10]);

%% Design af balance-regulator (PI-lead)
% Nyquists fulde stabilitetskriterie skal opfyldes for at systemet er
% stabilt:
% 1 pol i højre halvplan -> 1 gang mod uret rundt om -1 i Nyquist plot.

% Skal Kp være negativ? Vi kigger på Nyquist-plot for at bestemme dette.
% Ja det skal det.
figure(4);
hold on;
bode(-Gmp,ww);
grid on;
% Fra bodeplot vælges tau_i så gain cross-over frequency for integrator
% ligger lidt før peak response
Ti_b = 0.35;
bode(-Gmp * (1 + tf(1,[Ti_b 0])),ww);

% Tænker et lead-led vil forbedre fasemargen
w_cdb = 60;
alpha_b = 0.15;
Td_b = 1/(sqrt(alpha_b)*w_cdb);

% Bestem Kp. Vælg w_c med 60 graders fasemargen
bode(-Gmp * (1 + tf(1,[Ti_b 0])) * tf([Td_b 1],[alpha_b*Td_b 1]),ww);
Kp_b = -10^(28/20);

% Control loop
C_i_b = (1 + tf(1,[Ti_b 0]));
C_d_b = tf([Td_b 1],[alpha_b*Td_b 1]);
C_b = Kp_b * C_i_b * C_d_b;

bode(C_b,ww); % Controller open-loop

bode(C_b * Gmp,ww); % Controlled system

G_cl = (Kp_b * C_i_b * Gmp)/(1 + C_b * Gmp); % Closed-loop TF

bode(G_cl,ww);
hold off;

%% Design af balance-hastighedsregulator
% Linearize simulink model and get transfer function
[A,B,C,D] = linmod('regbot_1mg_2018b_wv_PIlead_balance_pitch2vel');
[num,den] = ss2tf(A,B,C,D);
Gmp_b = minreal(tf(num,den)) %  motor vel-ref til pitch/tilt angle
tf_poler_b = pole(Gmp_b)
tf_nulpunkter_b = zero(Gmp_b)

% There are 0 poles in the RHP -> we can use the reduced nyquist stability
% criterium.

%%
% Nyquist and bode plots
figure(5);
bode(Gmp_b,ww);
grid on;

figure(6);
nyquist(Gmp_b);

% System is closed-loop unstable (see nyquist plot near (-1,0)).
% Risk of two cross-over frequencies. 
% System cannot be too fast, we don't want to risk our balance.
% Integrators should have limits
% Let's design a standard-issue PI-lead controller.

% Place integrator cross frequency at first corner
% Max Ti in REGBOT software is 99.990, so we must place the cross-frequency
% a bit higher
w_cibv = 0.03;
Ti_bv = 1/w_cibv;
% C_i_bv = 1 + tf([1],[Ti_bv 0]);

T_lag_bv = 1/390;
beta = 30;
C_lag_bv = tf([T_lag_bv 1],[beta*T_lag_bv 1]);

% Place Lead at phase cross-over frequency
% Ni = 10;
% w_cdbv = 71.9;
% alpha = 0.6;
% Td_bv = 1/(sqrt(alpha)*w_cdbv);
% C_d_bv = tf([Td_bv 1],[alpha*Td_bv 1]);
figure;
bode(Gmp_b * C_lag_bv);

% Place P cross frequency so gain margin is 10 dB
w_cpbv = 2;
Kp_bv = 10^(-9.52/20);

figure(5);
hold on;
bode(Kp_bv * C_lag_bv * Gmp_b,ww);
hold off;

figure(10);
nyquist(Kp_bv * C_i_bv * Gmp_b * C_d_bv);
grid on;

% Closed-loop bode plot
G_cl_bv = (Kp_bv * C_i_bv * Gmp_b)/(1 + Kp_bv * C_i_bv * Gmp_b);
figure(11);
bode(G_cl_bv);
grid on;

%% Position balance regulator
% Linearize simulink model and get transfer function
[A,B,C,D] = linmod('regbot_1mg_2018b_wv_b_v');
[num,den] = ss2tf(A,B,C,D);
Gmp_bv = minreal(tf(num,den)) %  motor vel-ref til pitch/tilt angle
tf_poler_b = pole(Gmp_bv)
tf_nulpunkter_b = zero(Gmp_bv)

%%
figure;
hold on;
grid on;
bode(Gmp_bv, ww);

alpha=0.2;
w_dbvp=14;
Td_bvp = 1/(sqrt(alpha)*w_dbvp);
C_d = tf([Td_bvp 1],[alpha*Td_bvp 1]);

bode(C_d*Gmp_bv, ww);

Kp_bvp = 10^(4/20);

bode(Kp_bvp * C_d * Gmp_bv, ww);
