cla
clear 
close all

[file, folder] = uigetfile('*.*','MultiSelect','on');
dir = folder;
nTrials = length(file);

for i = 1:nTrials
    fileData = load(fullfile(folder, file{i}));
    limit = strfind(file{i}, '_');
    fileIndex = file{i}(1:limit-1);
    newName{i} = strcat(fileIndex, '_data');
    allData(i) = fileData.data;
    nCells(i) = length(allData(i).name);
end

for i = 1:nTrials
    [testX, testY] = size(allData(i).int);
    if testY > testX
        allData(i).int = allData(i).int';
    else
    end
    clear testX
    clear testY
    [testX, testY] = size(allData(i).nPeaks);
    if testY > testX
        allData(i).nPeaks = allData(i).nPeaks';
    else
    end
    clear testX
    clear testY
end

bigArray = [vertcat(allData.name), vertcat(allData.group), vertcat(allData.int), vertcat(allData.nPeaks), vertcat(allData.dff)];

% sort

bigArray = sortrows(bigArray,3);

[x, y] = size(bigArray);
nAll = x;

% set start point

nShow = nAll; % 30 is default! =nAll if showing all

[m, n] = size(unique(bigArray(:,2)));

% colorMap = hsv(m);
colorMap = [1, 0, 0; 0, 0, 0];

% start = 1; % beginning

 %start = nAll-nShow; % top 30, if showing all
 start = 1 % < if showing all

% plotting

h1 = figure();
set(h1, 'Position', [1 1200 800 800]);

for i = start:nAll
    plot(bigArray(i,5:end)-(100*i), 'Color', colorMap(bigArray(i,2),:))
    hold on
end

if start > 1
    ylim([(-100*nAll),(-100*(start-5))])
else
end

axis square