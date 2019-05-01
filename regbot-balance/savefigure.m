function savefigure(filepath)
fig = gcf;
fig.PaperUnits = 'centimeters';
fig.PaperPosition = [0 0 12 10];
saveas(fig, filepath, 'epsc');
end
