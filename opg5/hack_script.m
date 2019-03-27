%% Restart
clear variables;
close all;
clc;

%% Load data
wheelsdown = readtable('wheelsdown_blackbox.txt', 'CommentStyle', '%');

% MATLAB produces an empty column on the end, we remove it here.
wheelsdown(:,end) = [];

% Column names and units
wheelsdown.Properties.VariableNames = {'t' 'u_l' 'u_r' 'v_l' 'v_r'};
wheelsdown.Properties.VariableUnits = {'s' 'V' 'V' 'm/s' 'm/s'};

% Start and end times of the data we are interested in looking at, in
% seconds.
t_start = 0.4;
t_end = wheelsdown.t(end);

% Time of step
t_step = 0.5;

%% Preprocessing
% Refactored the previously used preprocessing code into separate function
% wheelsdown = preprocess(wheelsdown);

% Remove obvious outliers from data
[ans, mask] = rmoutliers(wheelsdown, 'movmedian', 20);
wheelsdown = wheelsdown(~mask,:);

% Trim measurements before t_start since this part is non-linear
% Trim measurements after t_end since we have reached steady state
wheelsdown((wheelsdown.t < t_start) | (wheelsdown.t > t_end), :) = [];

% SUPER HAXXX
% wheelsdown.u_l = wheelsdown.u_r;
% wheelsdown.v_l = wheelsdown.v_r;

% Remove offset so we start in zero
wheelsdown.u_l = wheelsdown.u_l - mean(wheelsdown.u_l( (t_start < wheelsdown.t) & (wheelsdown.t < t_step) ));
wheelsdown.v_l = wheelsdown.v_l - mean(wheelsdown.v_l( (t_start < wheelsdown.t) & (wheelsdown.t < t_step) ));

% Scale signals so max is 1
wheelsdown.u_l = wheelsdown.u_l/max(wheelsdown.u_l);
wheelsdown.v_l = wheelsdown.v_l/max(wheelsdown.v_l);

% wheelsdown.v_l = smoothdata(wheelsdown.v_l, 'gaussian', 10);

%% Plot the time series
% wheelsdown_step_response = figure('Name', 'Wheels down step response, left wheel');
% hold on;
% grid on;
% plot(wheelsdown.t, wheelsdown.u_l);
% plot(wheelsdown.t, wheelsdown.v_l);
% hold off;
% legend({'Motor voltage' 'Wheel velocity'}, 'Location', 'best');
% xlim([t_start, t_end]);
% xticks(t_start:0.5:t_end);
% xlabel('time [s]');
% ylabel('a.u');
% title('Wheels down step response, left wheel');

%% Estimate transfer function - wheelsdown
% test = zeros(size(wheelsdown.t));
% test(274:end) = 1;

wheelsdown_data = iddata(wheelsdown.v_l, wheelsdown.u_l, 0.002);
% wheelsdown_data = iddata(test, wheelsdown.u_l, 0.006);

% opt = tfestOptions('InitializeMethod', 'all');
wheelsdown_tf1 = tfest(wheelsdown_data, 1, 0);
wheelsdown_tf2 = tfest(wheelsdown_data, 2, 0);
wheelsdown_tf3 = tfest(wheelsdown_data, 2, 1);

% Step response of estimated transfer function
[Y1, T1] = step(wheelsdown_tf1, t_end - t_start);
[Y2, T2] = step(wheelsdown_tf2, t_end - t_start);
[Y3, T3] = step(wheelsdown_tf3, t_end - t_start);

%% Plot results - wheelsdown
close all
wheelsdown_tf_fig = figure('Name', 'Wheels down transfer function step response');
hold on;
grid on;
plot(T1+t_step, Y1);
plot(T2+t_step, Y2);
plot(T3+t_step, Y3);
legend('1p0z', '2p0z', '2p1z', 'Location', 'best');
plot(wheelsdown.t, wheelsdown.u_l, 'DisplayName', 'Motor voltage');
plot(wheelsdown.t, wheelsdown.v_l, 'DisplayName', 'Wheel velocity');
% plot(wheelsdown.t, test, 'DisplayName', 'Wheel velocity');
hold off
xlim([t_start, t_end]);
xlabel('time [s]');
ylabel('a.u');
title('Wheels down transfer functions step response, left wheel');

%% Save figures
if ~isfolder('figures')
    mkdir('figures');
end

saveas(wheelsdown_tf_fig, 'figures/wheelsdown_tf_step', 'epsc');
% saveas(wheelsdown_step_response, 'figures/wheelsdown_step_response', 'epsc');
