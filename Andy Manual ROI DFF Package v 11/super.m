% supertransient detector

% load mat files and concatenate data

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

% bigArray = sortrows(bigArray,3);

[x, y] = size(bigArray);
nAll = x;

% set start point

nShow = nAll; % 30 is default! change to nAll if showing all

[m, n] = size(unique(bigArray(:,2)));

% colorMap = hsv(m);
colorMap = [1, 0, 0; 0, 0, 0];

% start = 1; % beginning

% start = nAll-nShow; % top 30
start = 1; % < if showing all

% take differential of bigArray

diffArray = diff(bigArray(:,5:end),1,2);

% plotting

threshold = 100; % 100 is default
diffThreshold = 30; % 30 is default
spacer = 100;
diffSpacer = 100;

AthreshMap = bigArray(:,5:end)>threshold;
DthreshMap = diffArray>diffThreshold;

for i = 1:x
    Apeaks{i,:}=find(AthreshMap(i,:)==1);
    Dpeaks{i,:}=find(DthreshMap(i,:)==1);
end

% use structural element to fill gaps in amplitude threshold map

for i = 1:nAll
    movingFill(i,:) = imclose(AthreshMap(i,:), strel(ones(10)));    
    DMarks{i,:}=find(diff(DthreshMap(i,:))==1);    
end

productMat = bigArray(:,5:end).*movingFill;
helpMat = [zeros(nAll,1), movingFill];
boundaries = diff(helpMat,1,2);

nFrames = length(boundaries);

for i = 1:nAll
    p{i,:} = find(boundaries(i,:)==1);
    q{i,:} = find(boundaries(i,:)==-1);
end

for i = 1:nAll
    if numel(q{i})<numel(p{i});
        q{i}(numel(q{i})+1)=nFrames;
    else
    end
end

proxThresh = 10;

for i = 1:nAll
    if isempty(p{i})==0;
        for k=1:numel(p{i})
            testVect(k,:) = abs(p{i}(k)-DMarks{i});
        end

        testVect(find(testVect(:,:)>proxThresh))=0;
        delIdx = find(sum(testVect,2)==0);

        p{i}(delIdx)=[];
        q{i}(delIdx)=[]; %?
    else
    end
    clear testVect
end

h1 = figure();
set(h1, 'Position', [1 1200 800 800]);

for i = start:nAll
    
    AyDistance = spacer*i-threshold;
    DyDistance = diffSpacer*i-diffThreshold;
    
    plot(bigArray(i,5:end)-(spacer*i), 'Color', colorMap(bigArray(i,2),:))
    hold on
%     line([0, y], -[spacer*i-threshold, spacer*i-threshold]);
    
%     if isempty(Apeaks{i})==0,
%         scatter(Apeaks{i}, ones(1,length(Apeaks{i})).*-AyDistance, 20, 'r');
%     else
%     end

%     plot(movingFill(i,:).*threshold-AyDistance, 'r')
    
    [xx, yy] = size(p{i});
    [aa, bb] = size(q{i});
        
    if isempty(p{i})==0 && isequal(yy, bb)==1;
        for j = 1:yy
            line([p{i}(j), q{i}(j)], [-AyDistance, -AyDistance], 'Color', 'r', 'LineWidth', 5)
        end       
    else
    end
    
%     if isempty(Dpeaks{i})==0,
%         scatter(Dpeaks{i}, ones(1,length(Dpeaks{i})).*-AyDistance, 20, 'g');
%     else
%     end
    
end

if start > 1
    ylim([(-spacer*nAll),(-spacer*(start-5))])
else
end

axis square

% h2 = figure();
% set(h2, 'Position', [1 1200 800 800]);
% 
% for i = start:nAll
%     plot(productMat(i,:)-(spacer*i))
%     hold on
% end

% calculate transient lengths (in frames)

for i = 1:nAll
   
    for j = 1:numel(p{i})
        transLengths{i}(j) = q{i}(j)-p{i}(j);
    end
   
end

% calculate transient integral

cutArray = bigArray(:, 5:end);

for i = 1:nAll
    
    for j = 1:numel(p{i})
        transInts{i}(j) = trapz(cutArray(i, p{i}(j):q{i}(j)));
    end
   
end


grpLengths = cell2mat(transLengths);
grpInts = cell2mat(transInts);