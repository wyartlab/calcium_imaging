function [h1, h2, counts] = plot_multi(combined, time)

% test for presence of time variable

[m,n] = size(combined);

if n == 6;
    hasTime = 1;
else
    hasTime = 0;
end

% no time variable

if hasTime == 0;

    condSet = unique(combined(:,5));
    [means, errs] = grpstats(combined(:,3)./time, combined(:,5), {'mean', 'sem'});

    h1 = figure();
    set(h1, 'Position', [1 1200 1200 600]);
    
    scatter(combined(:,5), combined(:,3)./time, 100, 'k', '.')
    hold on
    xlim([0,condSet(end)+1]);
    jitter
    title('all')
    errorbar([condSet], means, errs, 'LineStyle', 'none', 'LineWidth', 2, 'Marker', '+');

% yes time variable

elseif hasTime == 1;
    
    nCond = length(unique(combined(:,5)));
    nTimes = length(unique(combined(:,6)));
    nGrps = nCond * nTimes;
        
    % develop averages for each time point
    
    StatMat = zeros(nTimes, 2, nCond);
    
    for i = 1:nCond;
        temp = combined(combined(:,5)==i,:);
        [x, y] = grpstats(temp(:,3)./time, temp(:,6), {'mean', 'sem'});
        StatMat(:,1,i) = x;
        StatMat(:,2,i) = y;
        clear x
        clear y
        clear temp
    end
    
    % set horizontal offset for column scatter
    
    offset = 0.5/(nCond-1);
    offsetMat = [-0.25:offset:0.25];
    
    colorMat = hsv(nCond);
    dColorMat = colorMat./2;
    
    h1 = figure();
    set(h1, 'Position', [1 1200 1200 600]);
    
    for i = 1:nCond;
        
    temp = combined(combined(:,5)==i,:);
    
    scatter(temp(:,6)+offsetMat(i), temp(:,3)./time, 100, colorMat(i,:), '.')
    hold on
    xlim([min(combined(:,6))-1,max(combined(:,6))+1]);
    set(gca, 'Xtick', (unique(combined(:,6))'));
    jitter
    errorbar(unique(temp(:,6)+offsetMat(i)), StatMat(:,1,i)', StatMat(:,2,i)', 'Color', dColorMat(i,:));
    clear temp
    title('all cells')
    end
end

% show n per group

if hasTime == 0;

    [peaks, locs] = findpeaks(combined(:,1));
    categories = unique(combined(:,5));
    index = combined(locs,5);

    index(end+1,:) = index(end,:); % corrects error due to findpeaks

    counts = [categories,zeros(length(categories),1)];

    for i = 1:length(categories)
        counts(i,2) = length(find(index==categories(i)));
    end

elseif hasTime == 1;
    
    counts = []

end