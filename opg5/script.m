%% Restart
clear variables;
close all;
clc;

%% Load data
wheelsup = readtable('wheelsup_blackbox.txt', 'CommentStyle', '%');
wheelsdown = readtable('wheelsdown_blackbox.txt', 'CommentStyle', '%');

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

% Start and end times of the data we are interested in looking at, in
% seconds.
t_start = 0.3;
t_end = 3;

% Time of step
t_step = 0.5;

% Trim measurements before t_start since this part is non-linear
% Trim measurements after t_end since we have reached steady state
wheelsup( (wheelsup.t < t_start) | (wheelsup.t > t_end), :) = [];
wheelsdown((wheelsdown.t < t_start) | (wheelsdown.t > t_end), :) = [];

% Remove offset so we start in zero
wheelsup.u_l = wheelsup.u_l - mean(wheelsup.u_l( (t_start < wheelsup.t) & (wheelsup.t < t_step) ));
wheelsup.v_l = wheelsup.v_l - mean(wheelsup.v_l( (t_start < wheelsup.t) & (wheelsup.t < t_step) ));
wheelsdown.u_l = wheelsdown.u_l - mean(wheelsdown.u_l( (t_start < wheelsdown.t) & (wheelsdown.t < t_step) ));
wheelsdown.v_l = wheelsdown.v_l - mean(wheelsdown.v_l( (t_start < wheelsdown.t) & (wheelsdown.t < t_step) ));

% Scale signals so max is around 1
wheelsup.u_l = wheelsup.u_l/max(wheelsup.u_l);
wheelsup.v_l = wheelsup.v_l/max(wheelsup.v_l);
wheelsdown.u_l = wheelsdown.u_l/max(wheelsdown.u_l);
wheelsdown.v_l = wheelsdown.v_l/max(wheelsdown.v_l);

%% Plot the time series
% figure('Name', 'Wheels up motor voltage time series');
% hold on;
% grid on;
% plot(wheelsup.t, wheelsup.u_l);
% plot(wheelsup.t, wheelsup.u_r);
% hold off;
% legend({'Left motor' 'Right motor'});
% xlim([t_start, t_end]);
% xticks(t_start:0.1:t_end);
% xlabel('time [s]');
% ylabel('Motor voltage [V]');
% 
% 
% figure('Name', 'Wheels up wheel velocity time series');
% hold on;
% grid on;
% plot(wheelsup.t, wheelsup.v_l);
% plot(wheelsup.t, wheelsup.v_r);
% hold off;
% legend({'Left wheel' 'Right wheel'});
% xlim([0.4, 1.5]);
% xticks(0.4:0.1:1.5);
% xlabel('time [s]');
% ylabel('Wheel speed [m/s]');

wheelsup_step_response = figure('Name', 'Wheels up step response, left wheel');
hold on;
grid on;
plot(wheelsup.t, wheelsup.u_l);
plot(wheelsup.t, wheelsup.v_l);
hold off;
legend({'Motor voltage' 'Wheel velocity'}, 'Location', 'best');
xlim([t_start, t_end]);
xticks(t_start:0.5:t_end);
xlabel('time [s]');
ylabel('a.u');
title('Wheels up step response, left wheel');
% ylabel('Wheel speed [m/s]');

wheelsdown_step_response = figure('Name', 'Wheels down step response, left wheel');
hold on;
grid on;
plot(wheelsdown.t, wheelsdown.u_l);
plot(wheelsdown.t, wheelsdown.v_l);
hold off;
legend({'Motor voltage' 'Wheel velocity'}, 'Location', 'best');
xlim([t_start, t_end]);
xticks(t_start:0.5:t_end);
xlabel('time [s]');
ylabel('a.u');
title('Wheels down step response, left wheel');

%% Estimate transfer function - wheelsup
clear wheelsup_tf;
wheelsup_data = iddata(wheelsup.v_l, wheelsup.u_l, 0.001);
wheelsup_tf{1} = tfest(wheelsup_data, 1, 0);
wheelsup_tf{2} = tfest(wheelsup_data, 2, 1);
wheelsup_tf{3} = tfest(wheelsup_data, 4, 3);
for i=1:length(wheelsup_tf); wheelsup_tf{i}, end

%% Estimate transfer function - wheelsdown
wheelsdown_data = iddata(wheelsdown.v_l, wheelsdown.u_l, 0.001);
wheelsdown_tf{1} = tfest(wheelsdown_data, 1, 0);
wheelsdown_tf{2} = tfest(wheelsdown_data, 2, 1);
wheelsdown_tf{3} = tfest(wheelsdown_data, 4, 3);
for i=1:length(wheelsdown_tf); wheelsdown_tf{i}, end

%% Plot results - wheelsup
wheelsup_tf_fig = figure('Name', 'Wheels up transfer function step response');
hold on;
grid on;
for i=1:length(wheelsup_tf)
    [Y, T] = step(wheelsup_tf{i}, 2.5);
    plot(T+0.5, Y, 'DisplayName', ['wheelsup\_tf\{' num2str(i) '\}']);
end
plot(wheelsup.t, wheelsup.u_l, 'DisplayName', 'Motor voltage');
plot(wheelsup.t, wheelsup.v_l, 'DisplayName', 'Wheel velocity');
hold off
xlim([0, 2.5+0.5]);
xlabel('time [s]');
ylabel('a.u');
legend({'1 pole' '2 poles, 1 zero' '4 poles, 3 zeros' 'Motor voltage' 'Wheel velocity'}, 'Location', 'best');
title('Wheels up transfer functions step response, left wheel');


%% Plot results - wheelsdown
wheelsdown_tf_fig = figure('Name', 'Wheels down transfer function step response');
hold on;
grid on;
for i=1:length(wheelsdown_tf)
    [Y, T] = step(wheelsdown_tf{i}, 2.5);
    plot(T+0.5, Y,  'DisplayName', ['wheelsdown\_tf\{' num2str(i) '\}'])
end
plot(wheelsdown.t, wheelsdown.u_l, 'DisplayName', 'Motor voltage');
plot(wheelsdown.t, wheelsdown.v_l, 'DisplayName', 'Wheel velocity');
hold off
xlim([0, 2.5+0.5]);
xlabel('time [s]');
ylabel('a.u');
legend({'1 pole' '2 poles, 1 zero' '4 poles, 3 zeros' 'Motor voltage' 'Wheel velocity'}, 'Location', 'best');
title('Wheels down transfer functions step response, left wheel');

%% Save figures
if ~isfolder('figures')
    mkdir('figures');
end

saveas(wheelsup_tf_fig, 'figures/wheelsup_tf_step', 'epsc');
saveas(wheelsdown_tf_fig, 'figures/wheelsdown_tf_step', 'epsc');
saveas(wheelsup_step_response, 'figures/wheelsup_step_response', 'epsc');
saveas(wheelsdown_step_response, 'figures/wheelsdown_step_response', 'epsc');
