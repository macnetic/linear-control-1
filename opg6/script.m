clear variables;
close all;
clc;

num = [6.424];
denom = [1 6.892];
G = tf(num, denom);

MAX_MOTOR_VOLTAGE = 3;
K_p = 0.45;
K_i =0.002;

sim('wheelsdown_sim', 20);

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
legend('Position step', 'Step response');

%%
% open_system('wheelsdown_sim');
% print(['-s' 'wheelsdown_sim'], '-dpdf', '-bestfit')

