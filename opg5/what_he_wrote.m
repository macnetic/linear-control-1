clear variables;
close all;
clc;

dd = load('wheelsdown_blackbox_new_regulated.txt');

data = dd;
i1 = 500/4;
i2 = 1900/4;
v0_ind = mean(data(i1:i2,2));
v0_ud = mean(data(i1:i2,4));

dd1ind = (data(i1:end, 2) - v0_ind);
dd1ud = data(i1:end, 4) - v0_ud;

figure(50)
hold off
plot(data(i1:end, 1), dd1ind);
hold on
plot(data(i1:end, 1), dd1ud);
grid on

idd1 = iddata(dd1ud, dd1ind, 0.004);
sys1 = tfest(idd1, 2, 0)
sys2 = tfest(idd1, 3, 0)

sys1
sys2

[Y1,T] = step(sys1, 3);
plot(T + 2, Y1*2,'--r','linewidth',2);
legend('Measured in', 'Measured out','Estimated out','location','northwest');
