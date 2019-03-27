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
tau_i = 50;
K_i = 1/tau_i;
alpha = 0.20;
% tau_d = 0.0105;
tau_d = 0.3472;

%%
G_c = tf([6249*tau_i*tau_d, 6249*(tau_i+tau_d), 6249], [alpha*tau_i*tau_d, (1904*alpha*tau_i*tau_d + tau_i), (6718*alpha*tau_i*tau_d + 1904*tau_i), 6718*tau_i])

G*G_c
%%
% sim('wheelsdown_sim', 5);
sim('wheelsdown_sim_pi_lead', 20);

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

%%
% open_system('wheelsdown_sim');
% print(['-s' 'wheelsdown_sim'], '-dpdf', '-bestfit')

