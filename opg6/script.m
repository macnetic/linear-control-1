%% Restart
clear all;
close all;
clc;

%% Parameters

% Process transfer function
num = [6249];
denum = [1 1904 6718];
G = tf(num, denum);

% figure;
% bode(G);
% grid on;

MAX_MOTOR_VOLTAGE = 3;
K_p = 9.8855;
% tau_i = 0.0132;
tau_i = 0.0014;
K_i = 1/tau_i;
alpha = 0.20;
% tau_d = 0.0105;
tau_d = 7.6316e-4;

%%
G_c = tf([tau_i*tau_d, (tau_i+tau_d), 1], [alpha*tau_i*tau_d, tau_i, 0]);
G_c = G_c*K_p;
G
figure;
bode(G*G_c);
grid on;

G*G_c;
%%
% sim('wheelsdown_sim', 5);
sim('wheelsdown_sim_pi_lead', 5);

%% Plotting
figure;
hold on;
plot(step);
plot(simout);
hold off;
title('Regulator step response');
xlabel('Time [s]');
ylabel('Position [m]');
grid('on');
legend('Position step', 'Step response', 'Location', 'best');

%% Load data
log = readtable('position-regulator-log.txt', 'CommentStyle', '%');

% MATLAB produces an empty column on the end, we remove it here.
log(:,end) = [];

% Column names and units
log.Properties.VariableNames = {'t' 'x' 'y' 'h' 'tilt'};
% log.Properties.VariableUnits = {'s' 'V' 'V' 'm/s' 'm/s'};

log = preprocess(log);

figure;
hold on
plot(step);
plot(simout);
plot(log.t(1:500), log.x(1:500));
grid on;
xlabel('Time [s]');
ylabel('Position [m]');
legend('Position step','Simulated step response','Measured step response', ...
    'Location', 'best');
