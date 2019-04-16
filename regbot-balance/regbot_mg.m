%% mekanisk_model_regbot
close all
clear
%% parametre
% motor
RA = 3.3;    % ohm
JA = 1.3e-6; % motor inerti
LA = 6.6e-3; % ankerspole
BA = 3e-6;   % ankerfriktion
Kemf = 0.0105; % motorkonstant
Km = Kemf;
% køretøj
NG = 9.69; % gear
WR = 0.03; % hjul radius
Bw = 0.155; % hjulafstand
% 
%% model af dele af robot - opdelt for at få rimelig både masse og inertimoment
% disse tal er brugt i simulink model
mmotor = 0.193;   % samlet masse af motor og gear [kg]
mframe = 0.32;    % samlet masse af ramme og print [kg]
mtopextra = 0.27; % extra masse på top (lader og batteri) [kg]
mpdist =  0.10;   % afstand til låg [m]
startAngle = 25;  % in degrees
% forstyrrelse - skub position (Z)
pushDist = 0.1; % hvor på robot (i forhold til motoraksen) [m]
%% velocity controller (no balance) PI-regulator
% design resultat - hastighedsregulator:
wcwv = 32; % rad/s % krydsfrekvens (ikke brugt)
Kpwv = 13;     % Kp
tiwv = 0.06;   % Tau_i
%% linear model of robot in balance med motor controller
% fra velocity ref til tilt vinkel
[A,B,C,D] = linmod('regbot_1mg_2018a');
[num,den] = ss2tf(A,B,C,D);
%% poler og nulpunkter fra hastigheds-reference til tilt (pitch)
Gmp = minreal(tf(num,den)) %  motor vel-ref til pitch/tilt angle
tf_poler = pole(Gmp)
tf_nulpunkter = zero(Gmp)
%% bodeplot balance - hastigheds-reference til tilt (pitch)
figure(100)
hold off
ww = logspace(-3,3,300);
bode(Gmp, ww)
grid on
title('Bodeplot fra motor vel\_ref til tilt\_vinkel')
