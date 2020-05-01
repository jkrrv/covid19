clear;

%% download and format data

json = webread('https://phl.carto.com/api/v2/sql?q=SELECT%20*%20FROM%20covid_cases_by_date%20ORDER%20BY%20result_date');

data = json.rows;

dates = linspace(datetime('now'),datetime('now'),length(data))';
count = zeros(1, length(data))';
rollingAvg = zeros(1, length(data))';
rollingSum = zeros(1, length(data))';


for i = 1:length(data)
    dates(i) = datetime(erase(data(i).result_date,'Z'), 'InputFormat', 'yyyy-MM-dd''T''HH:mm:SS');
    count(i) = data(i).count;
    
    if i > 15
        rollingAvg(i) = mean(count((i-15):i));
        rollingSum(i) = sum(count((i-15):i));
    else
        rollingAvg(i) = mean(count(1:i));
        rollingSum(i) = sum(count(1:i));
    end
    
end

dateI = datenum(dates - datetime('now'));

last14data = count(numel(data)-14:numel(data)-1);


%% Figure 1
figure(1);
clf;
hold on;

target = 16 * 50;

% fill last 7 days where data is incomplete. 
fl = fill([
    max(dates) - days(7)
    max(dates) - days(7)
    max(dates)
    max(dates)
],[
    0
    max(rollingSum)
    max(rollingSum)
    0
], [.9 .9 .9], 'EdgeColor', 'none');
% do not display fill in legend
set(get(get(fl,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
text(max(dates) - days(3.5), max(rollingSum)/2, "Data May be Delayed", 'HorizontalAlignment', 'center', 'rotation', 270, 'color', [.6 .6 .6])

text(datetime(2020, 03, 23), 0, "Stay-at-Home Order",  'HorizontalAlignment', 'right', 'rotation', 270, 'color', [.6 .6 .6]);
text(datetime(2020, 03, 16), 0, "Schools Closed", 'HorizontalAlignment', 'right', 'rotation', 270, 'color', [.6 .6 .6]);


ylabel('New Cases in Philadelphia');
plot([min(dates) max(dates)] , ones(1, 2) * target, '-b');
plot(dates, rollingSum, '.-r');

axis tight;
grid on;
hold off;
l = legend('14-day Target','14-day Total');

% bring axes to top
set(gca, 'Layer', 'top')

set(l, 'Location', 'northwest');

% save figure
print('imgs/14day','-dpng');



%% Figure 2
figure(2);
clf;
hold on;

% fill last 7 days where data is incomplete. 
fl = fill([
    max(dates) - days(7)
    max(dates) - days(7)
    max(dates)
    max(dates)
],[
    0
    max(count)
    max(count)
    0
], [.9 .9 .9], 'EdgeColor', 'none');
% do not display fill in legend
set(get(get(fl,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
text(max(dates) - days(3.5), max(count)/2, "Data May be Delayed", 'HorizontalAlignment', 'center', 'rotation', 270, 'color', [.6 .6 .6])

text(datetime(2020, 03, 23), 0, "Stay-at-Home Order",  'HorizontalAlignment', 'right', 'rotation', 270, 'color', [.6 .6 .6]);
text(datetime(2020, 03, 16), 0, "Schools Closed", 'HorizontalAlignment', 'right', 'rotation', 270, 'color', [.6 .6 .6]);


ylabel('New Cases in Philadelphia');
plot(dates, count, '.-r');

axis tight;
grid on;
hold off;
l = legend('Daily New Cases');

% bring axes to top
set(gca, 'Layer', 'top')

set(l, 'Location', 'northwest');

% save figure
print('imgs/newCases','-dpng');

%% Regression

figure(3);
clf;
hold on;

% fill last 7 days where data is incomplete. 
fl = fill(datenum([
    max(dates) - days(7)
    max(dates) - days(7)
    max(dates)
    max(dates)
] - datetime('now')),[
    0
    max(rollingSum)
    max(rollingSum)
    0
], [.9 .9 .9], 'EdgeColor', 'none');
% do not display fill in legend
set(get(get(fl,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%text(max(dates) - days(3.5), max(rollingSum)/2, "Data May be Delayed", 'HorizontalAlignment', 'center', 'rotation', 270, 'color', [.6 .6 .6])

%text(datetime(2020, 03, 23), 0, "Stay-at-Home Order",  'HorizontalAlignment', 'right', 'rotation', 270, 'color', [.6 .6 .6]);
%text(datetime(2020, 03, 16), 0, "Schools Closed", 'HorizontalAlignment', 'right', 'rotation', 270, 'color', [.6 .6 .6]);

% fancy curves
p1c14 = fit(dateI(end-14+1:end), rollingSum(end-14+1:end), 'poly1');
p1c7 = fit(dateI(end-7+1:end), rollingSum(end-7+1:end), 'poly1');
p2c = fit(dateI, rollingSum, 'poly2');
g3c = fit(dateI, rollingSum, 'gauss3');
g4c = fit(dateI, rollingSum, 'gauss4');

% Plot curves
ylabel('New Cases in Philadelphia');
plot([min(dateI) max(dateI)+60] , ones(1, 2) * target, '-k');
plot(dateI, rollingSum, '.-r');
axis tight;
axis manual;
set(plot(p1c14), 'Color', [0 1 0]);
set(plot(p1c7), 'Color', [0 .8 .2]);
set(plot(p2c), 'Color', [0 .6 .4]);
set(plot(g3c), 'Color', [0 .4 .6]);
set(plot(g4c), 'Color', [0 .2 .8]);

grid on;
hold off;
l = legend('14-day Target','14-day Total', 'Linear, 14 Days', 'Linear, 7 Days', 'Quadratic', 'Gauss-3', 'Gauss-4');

% bring axes to top
set(gca, 'Layer', 'top')

set(l, 'Location', 'northeast');
xlabel(['Days from Now ('  datestr(datetime('now'))  ')']);
ylabel('New cases in Philadelphia');


save figure
print('imgs/projections','-dpng');




