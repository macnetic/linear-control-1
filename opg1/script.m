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

%% Preprocessing
% Remove rows with missing data
T = rmmissing(T);

% Remove rows where the time does not appear in order
i = 2;
while i < height(T)
    isBetween = (T.t(i-1) < T.t(i)) && (T.t(i) < T.t(i+1));
    if ~isBetween
        T(i,:) = [];
    end
    i = i+1;
end

%% Plot
% Plot recorded path
pathplot = figure('Name','Recorded path driven');
hold on;
grid on;
plot(T.x,T.y);
text(T.x(1)-0.15, T.y(1)-0.05, ['t = ' num2str(T.t(1)) ' s']);
text(T.x(end)-0.15, T.y(end)-0.05, ['t = ' num2str(T.t(end)) ' s']);
hold off;
xlabel('x [m]');
ylabel('y [m]');

% Plot motor voltage vs. time
voltageplot = figure('Name', 'Motor voltages vs. time');
hold on;
grid on;
plot(T.t,T.u_l);
plot(T.t,T.u_r);
hold off
xlabel('time [s]');
ylabel('Motor voltage [V]');
legend('Left motor', 'Right motor', 'Location', 'best');

% Plot motor current vs. time
currentplot = figure('Name', 'Motor currents vs. time');
hold on;
grid on;
plot(T.t,T.i_l);
plot(T.t,T.i_r);
hold off
xlabel('time [s]');
ylabel('Motor current [A]');
legend('Left motor', 'Right motor', 'Location', 'best');

% Plot wheel velocities vs. time
wheelplot = figure('Name', 'Wheel velocities vs. time');
hold on;
grid on;
plot(T.t,T.v_l);
plot(T.t,T.v_r);
hold off
xlabel('time [s]');
ylabel('Wheel velocity [m/s]');
legend('Left wheel', 'Right wheel', 'Location', 'best');

% Plot heading vs. time
headingplot = figure('Name', 'Heading vs. time');
hold on;
grid on;
plot(T.t,T.h);
hold off;
ylim([-pi pi]);
yticks(-pi:pi/2:pi);
yticklabels({'-\pi' '-\pi/2' '0' '\pi/2' '\pi'});
xlabel('time [s]');
ylabel('Heading [rad]');

tiltplot = figure('Name', 'Tilt angle vs. time');
hold on;
grid on;
plot(T.t,T.tilt);
hold off;
ylim([-pi pi]);
yticks(-pi:pi/2:pi);
yticklabels({'-\pi' '-\pi/2' '0' '\pi/2' '\pi'});
xlabel('time [s]');
ylabel('Tilt angle [rad]');

%% Save plots
% Create folder for storing the figures in
if ~isfolder('figures')
    mkdir('figures');
end

% Save plots to folder
saveas(pathplot,'figures/path','epsc');
saveas(voltageplot,'figures/motor-voltage','epsc');
saveas(currentplot,'figures/motor-current','epsc');
saveas(wheelplot,'figures/wheel-velocity','epsc');
saveas(headingplot,'figures/heading','epsc');
saveas(tiltplot,'figures/tilt','epsc');
