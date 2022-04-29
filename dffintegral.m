close all
disp ('Choose image acquisition file')
[image folder] = uigetfile('*.*');
imagefile = strcat(folder, image);

% If you want to manually select image to choose ROIs from, uncomment below
% 
disp ('Choose image to select ROIs')
[file2, folder2]= uigetfile('*.*');
StanDev = strcat(folder2, file2);

% StanDev = strcat(folder, 'AVG_', image);
nframes = input('How many frames is the image file? ');
freq = input('What is the frequency of acquisition in Hz? ');
% nframes = 1000;
% freq = 5;

M=multitiff2M(imagefile,1:nframes);
% Mr = registerfilm_ROI(M(:,:,1:nframes),1);
% flattenM = mean(M,3); 
x_dim = length(M(1,:,1));
y_dim = length(M(:,1,1));

figure;I=imread(StanDev);imshow(I);
disp('Choose first set of ROIs')
rois_v = getROIcell;
close all
    
% Ventral: generate mask from rois, calculate dff, find and threshold
% minima, fit poly to minima, subtract dff trace from poly function,
% calculate integral normalized per roi per minute

if isempty(rois_v);
    dff_v = []
    raw_v = []
    Mask_v = []
    int_v = [];
else;

for i=1:size(rois_v,2); 
    Mask_v{i} = roipoly(imread(imagefile),rois_v{i}(:,1),rois_v{i}(:,2));
end;

[dff_v, raw_v] = calc_dff(M, Mask_v, size(rois_v,2));
 
for i=1:size(rois_v,2); 
    
    [min_v, ind_v] = lmin(dff_v(:,i),100);
    [fit_v, gof_v, out_v] = fit(ind_v', min_v', 'poly2', 'Normalize', 'on');
    base_v (:,i) = feval(fit_v, [1:nframes])';
    adj_v(:,i) = dff_v(:,i)-base_v(:,i);
    int_v(:,i) = trapz(adj_v(:,i));
    int_v(:,i) = int_v(:,i)/nframes*freq*60;
    
end;
    int_v = int_v';
end

% Dorsal: generate mask from rois, calculate dff, find and threshold
% minima, fit poly to minima, subtract dff trace from poly function,
% calculate integral normalized per roi per minute

figure;I=imread(StanDev);imshow(I);
disp('Choose second set of ROIs')
rois_d = getROIcell;

close all

% Choose stimulus location
% 
% 
% disp ('Choose file to identify stimulus location')
% [image folder] = uigetfile('*.*');
% stimimage = strcat(folder, image);
% 
% figure;I=imread(stimimage);imshow(I);
% disp('Choose ROI for stimulation')
% roi_stim = getROIcell;
% 
% centroid_stim = [mean(roi_stim{1}(:,1))];
% 
% close all


% Generate mask with ventral and dorsal rois

% figure; imshow(StanDev); hold on;
% for i = 1:size(rois_v,2);
%     rois_temp = [];
%     rois_temp = rois_v{1,i}
%     plot (rois_temp, 'r'); 
%     clear rois_temp;
% end

if isempty(rois_d);
    dff_d = [];
    raw_d = [];
    Mask_d = [];
    int_d = [];
else;
    
for i=1:size(rois_d,2); 
    Mask_d{i} = roipoly(imread(imagefile),rois_d{i}(:,1),rois_d{i}(:,2));
end;

   [dff_d, raw_d] = calc_dff(M, Mask_d, size(rois_d,2));

for i=1:size(rois_d,2); 
  
    [min_d, ind_d] = lmin(dff_d(:,i),100);
    [fit_d, gof_d, out_d] = fit(ind_d', min_d', 'poly2', 'Normalize', 'on');
    base_d (:,i) = feval(fit_d, [1:nframes])';
    adj_d(:,i) = dff_d(:,i)-base_d(:,i);
    int_d(:,i) = trapz(adj_d(:,i));
    int_d(:,i) = int_d(:,i)/nframes*freq*60;

   end;

    int_d = int_d';
    
end

% Centroid for each ROI

for i=1:length(rois_v);
    centroid_x_v(i) = [mean(rois_v{i}(:,1))];
end
centroid_x_v = centroid_x_v';
for i=1:length(rois_d);
    centroid_x_d(i) = [mean(rois_d{i}(:,1))];
end
centroid_x_d = centroid_x_d';
% Generate png/fig for mask of rois

figure; imshow(StanDev);
for i=1:length(rois_v);
    patch(rois_v{1,i}(:,1),rois_v{1,i}(:,2),'m','FaceAlpha',0.55);
    text(rois_v{1,i}(1,1),rois_v{1,i}(1,2),num2str(i),'Color','b');
    hold on;
end
for i=1:length(rois_d);
    patch(rois_d{1,i}(:,1),rois_d{1,i}(:,2),'g','FaceAlpha',0.55);
    text(rois_d{1,i}(1,1),rois_d{1,i}(1,2),num2str(i),'Color','b');
    hold on;
end
title('ROIs','FontSize', 18);
rois = strcat(folder, 'ROIs');
saveas(gcf, rois,'fig'); 
saveas(gcf, rois,'png');
close all

% mod 20150918
% peak detection for analyzing 1020GC5 at 24hpf

% for i=length(adj_v(:,1));
%     vpeaks = findpeaks([1:nframes], adj_v(i,:), 0.02, 0.1, 3, 3, 2); % adjust params here for peak detection
% end
% 
% for i=length(adj_d(:,1));
%     dpeaks = findpeaks([1:nframes], adj_d(i,:), 0.02, 0.1, 3, 3, 2); % adjust params here for peak detection
% end

% Following section detects peaks from baseline-subtracted dff(KA(i).dffsub, 
%    thresholds peaks above 10 ; currently empirically chosen here, can use standard deviation 
%    instead andgenerates matrix with indeces in first row, peak values in 2nd row
%    

lmax_v = NaN(50);
lmax_d = NaN(50);
indmax_v = NaN(50);
indmax_d = NaN(50);
prethresh_v = NaN(50);
prethresh_d =NaN(50);

% for i=1:size(adj_v(1,:),2);
%     [lmax_v indmax_v] = lmax(adj_v(:,i),150);figure(i);plot(adj_v(:,i));hold on; plot(indmax_v, lmax_v, 'ro');
%     allfreq_v(i,1)=size(indmax_v,2)/(nframes/freq);
%     freq_v = mean(allfreq_v);
% %     prethresh_v(:,i) = [lmax_v(:,i); indmax_v(:,i)] %create matrix with max values and their index together
% end

% for i=size(adj_v(1,:),2);
%     subplot((round(size(rois_v,2)/2)),3,i);hold on; plot(lmax_v(:,i), indmax_v(:,1),'ro'); hold off;
% end

% 
% for i=1:size(adj_d(1,:),2);
%      [lmax_d indmax_d] = lmax(adj_d(:,i),150);figure(i+size(adj_v(1,:),2));plot(adj_d(:,i));hold on; plot(indmax_d, lmax_d, 'ro');
%     allfreq_d(i,1)=size(indmax_d,2)/(nframes/freq);
%     freq_d = mean(allfreq_d);
% %     [lmax_d(i,:) indmax_d(i,:)] = lmax(adj_d(:,i),20);figure(i);plot(adj_d(:,i));hold on; plot(indmax_d(i,:), lmax_d(i,:), 'ro');
    %create matrix with max values and their index together
% end
% % 
% figure;plot(adj_d(:,i)); hold on; plot(indmax_d(:,i), lmax_d(:,i),'ro');hold off;

% for i=size(adj_d(1,:),2);
%    subplot((round(size(rois_d,2)/2)), 3, i); hold on; plot(lmax_d(:,i), indmax_d(:,1),'ro'); hold off;
% end

    
% figure; for i=1:size(raw,2); plot(i,KA(i).dffsubIntegral,'o');hold on; end;



% Generate avi for pixel by pixel dff
% 
% [MthA,MdfA,dbgfA] = M2DFdifferentialAdded(M, 1, nframes);
% M2avi(MdfA,'added_dff.avi');

% find cross correlation between ROIs
% 
% [R_d,p_d]=corrcoef(dff_d);
% [R_v,p_v]=corrcoef(dff_v);
% close all; figure;imshow(R_v,'colormap',jet,'DisplayRange',[0 1],'InitialMagnification','fit'),colorbar;
% figure;imshow(R_d,'colormap',jet,'DisplayRange',[0 1],'InitialMagnification','fit'),colorbar;
% 
% plot raw trace in black, dff before adjustment in blue, dff after
% adjustment in red

figure; 
for i=1:size(rois_v,2); 
    subplot((round(size(rois_v,2)/2)),3,i);plot(raw_v(:,i),'k'); hold on; 
    plot(dff_v(:,i),'b'); plot(adj_v(:,i),'r'); 
    title(['ROI', num2str(i)]);
    hold off; 
end;
title('Vental dff','FontSize', 18);
vccd = strcat(folder, 'ventralcells_correctedDFF');
saveas(gcf,vccd,'fig');
saveas(gcf,vccd,'png');

figure;
for i=1:size(rois_d,2); 
    subplot((round(size(rois_d,2)/2)), 3, i);plot(raw_d(:,i),'k'); hold on; 
    plot(dff_d(:,i),'b'); plot(adj_d(:,i),'r');
    title(['ROI', num2str(i)])
    hold off; 
   end;
title('Dorsal dff','FontSize', 18);
dccd = strcat(folder, 'dorsalcells_correctedDFF');
saveas(gcf,dccd,'fig');
saveas(gcf,dccd,'png');

figure; 
for i=1:size(int_v); plot(1,int_v,'ko','LineWidth',3); end; hold on; 
for i=1:size(int_d), plot(2,int_d,'bo','LineWidth',4); end; hold on;
axis ([0 3 0 max(int_v(:,1)*2)]);
set(gca,'XTick',0:3,'XTickLabel', {'0', 'ventral cells', 'dorsal cells', ''},'FontSize',18)
title('Normalized integrals per ROI')
hold off
integral = strcat(folder, 'integral');
saveas (gcf, integral,'fig');
saveas (gcf, integral,'png');

allrois = [rois_v rois_d];
output = zeros(length(allrois), 3);
for i = 1:length(rois_v);
    output(i,1) = i;
    output(i,2) = 1;
    output(i,3) = int_v(i);
end

for i = 1:length(rois_d);
    output(i+length(rois_v),1) = i;
    output(i+length(rois_v),2) = 0;
    output(i+length(rois_v),3) = int_d(i);
end


% output: column 1 is roi number, column 2 is 1 for ventral, 2 for dorsal,
% column 3 is integral normalized to one minute

save analysis






