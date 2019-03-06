%% Restart
clear variables;
close all;
clc;

%% Load data
wheelsup = readtable('wheelsup_blackbox.txt', 'CommentStyle', '%');
wheelsdown = readtable('wheelsup_blackbox.txt', 'CommentStyle', '%');

% MATLAB produces an empty column on the end, we remove it here.
wheelsup(:,end) = [];
wheelsdown(:,end) = [];

% Column names and units
wheelsup.Properties.VariableNames = {'t' 'u_l' 'u_r' 'v_l' 'v_r'};
wheelsup.Properties.VariableUnits = {'s' 'V' 'V' 'm/s' 'm/s'};
wheelsdown.Properties.VariableNames = {'t' 'u_l' 'u_r' 'v_l' 'v_r'};
wheelsdown.Properties.VariableUnits = {'s' 'V' 'V' 'm/s' 'm/s'};

%% Preprocessing
% Refactored the previously used preprocessing code into separate function
wheelsup = preprocess(wheelsup);
wheelsdown = preprocess(wheelsdown);

% Trim measurements before 400 ms since this part is non-linear
wheelsup(wheelsup.t < 0.4,:) = [];
wheelsdown(wheelsdown.t < 0.4,:) = [];

% Trim measurements after 1500 ms since we have reached steady state
wheelsup(wheelsup.t > 1.5,:) = [];
wheelsdown(wheelsdown.t > 1.5,:) = [];

%% Plot the time series
figure('Name', 'Wheels up motor voltage time series');
hold on;
grid on;
plot(wheelsup.t, wheelsup.u_l);
plot(wheelsup.t, wheelsup.u_r);
hold off;
legend({'Left motor' 'Right motor'});
xlim([0.4, 1.5]);
xticks(0.4:0.1:1.5);
xlabel('time [s]');
ylabel('Motor voltage [V]');


figure('Name', 'Wheels up wheel velocity time series');
hold on;
grid on;
plot(wheelsup.t, wheelsup.v_l);
plot(wheelsup.t, wheelsup.v_r);
hold off;
legend({'Left wheel' 'Right wheel'});
xlim([0.4, 1.5]);
xticks(0.4:0.1:1.5);
xlabel('time [s]');
ylabel('Wheel speed [m/s]');

%% Estimate transfer function
tfest(wheelsup.u_l, wheelsup.v_l);
