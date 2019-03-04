%% Restart
clear variables;
close all;
clc;

%% Load data
T = readtable('log.txt', 'CommentStyle', '%');

% MATLAB produces an empty column on the end, we remove it here.
T(:,end) = [];

T.Properties.VariableNames = {'t' 'u_l' 'u_r' 'i_l' 'i_r'...
    'v_l' 'v_r' 'x' 'y' 'h' 'tilt'};
T.Properties.VariableUnits = {'s' 'V' 'V' 'A' 'A'...
    'm/s' 'm/s' 'm' 'm' 'rad' 'rad'};

%% Plot

% Create folder for storing the figures in
if ~isfolder('figures')
    mkdir('figures');
end

% Plot recorded path
figure('Name','Recorded path driven');
hold on;
grid on;
plot(T.x,T.y);
text(T.x(1)-0.1, T.y(1)-0.05, ['t = ' num2str(T.t(1))]);
text(T.x(end)-0.1, T.y(end)-0.05, ['t = ' num2str(T.t(end))]);
hold off;
xlabel('x [m]');
xlabel('y [m]');
saveas(gcf(),'figures/path','epsc');

% Plot motor voltage vs. time
figure('Name', 'Motor voltages vs. time');
hold on;
grid on;
plot(T.t,T.u_l);
plot(T.t,T.u_r);
hold off
xlabel('time [s]');
ylabel('Motor voltage [V]');
legend('Left motor', 'Right motor', 'Location', 'best');
saveas(gcf(),'figures/motor-voltage','epsc');

% Plot motor current vs. time
figure('Name', 'Motor currents vs. time');
hold on;
grid on;
plot(T.t,T.i_l);
plot(T.t,T.i_r);
hold off
xlabel('time [s]');
ylabel('Motor current [A]');
legend('Left motor', 'Right motor', 'Location', 'best');
saveas(gcf(),'figures/motor-current','epsc');

% Plot wheel velocities vs. time
figure('Name', 'Wheel velocities vs. time');
hold on;
grid on;
plot(T.t,T.v_l);
plot(T.t,T.v_r);
hold off
xlabel('time [s]');
ylabel('Wheel velocity [m/s]');
legend('Left wheel', 'Right wheel', 'Location', 'best');
saveas(gcf(),'figures/wheel-velocity','epsc');

% Plot heading vs. time
figure('Name', 'Heading vs. time');
hold on;
grid on;
plot(T.t,T.h);
hold off;
ylim([-pi pi]);
yticks(-pi:pi/2:pi);
yticklabels({'-\pi' '-\pi/2' '0' '\pi/2' '\pi'});
xlabel('time [s]');
ylabel('Heading [rad]');
saveas(gcf(),'figures/heading','epsc');

figure('Name', 'Tilt angle vs. time');
hold on;
grid on;
plot(T.t,T.tilt);
hold off;
ylim([-pi pi]);
yticks(-pi:pi/2:pi);
yticklabels({'-\pi' '-\pi/2' '0' '\pi/2' '\pi'});
xlabel('time [s]');
ylabel('Tilt angle [rad]');
saveas(gcf(),'figures/tilt','epsc');
