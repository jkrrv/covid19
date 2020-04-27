clear;

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

last14data = count(numel(data)-14:numel(data)-1);


figure(1);
clf;
hold on;
ylabel('New Cases in Phila');
% plot(dates, count, '.-');
plot([min(dates) max(dates)] , ones(1, 2) * 16 * 50);
% plot(dates, rollingAvg, '-');
plot(dates, rollingSum, '.-');
axis tight
hold off;
legend('14-day Target','14-day Total');

print('imgs/14day','-dpng')
