
function output = dff_timing_amplitude(dff,freq);

%make sure that 1st column is roi1 and that the file finish with BoutType
%and MotionArt - use . for decimals, no comma.

close all;

output=struct('NumberBout', [],'MotionArt', [], 'BoutType',[], 'BoutStart',[],'BoutEnd',[],'rois', [],  'dff', [], 'dff_freq', [], 'baseline',[],  'noise', [],'noise_freq', [],'amplitude', [],'amplitude_freq', [], 'integral', [], 'time', [], 'timetopeak', [],'time_freq', [], 'timetopeak_freq', [], 'integral_freq', [], 'signal2noise', [], 'signal2noise_freq',[]);

% define dff, time and rois - plot them all together

output.dff=dff;

% define bout type and motion artefact

BoutType=dff(:,end-1);
output.BoutType=BoutType;

MotionArt=dff(:,end);
output.MotionArt=MotionArt;


% Identify timing of bout start and end in the data

BoutStart=find(diff(BoutType)>0);
output.BoutStart=BoutStart;

BoutEnd=find(diff(BoutType)<0);
output.BoutEnd=BoutEnd;

NumberBout=length(BoutEnd);
output.NumberBout=NumberBout;


% running average of the window freq+1

dff_freq=movingmean(dff,freq,1,1);

output.dff_freq=dff_freq;

time =[1:1:size(dff,1)]/freq;
output.time=time;

rois=[1:1:size(dff,2)-2];
output.rois=rois;

figure(1);plot(time,dff); hold on; plot(time,dff(:,end-1),'k','LineWidth',2); plot(time,dff(:,end),'r','LineWidth',2);

title('DFF with motion artifact in red and movement type in black','FontSize', 18);
saveas(gcf, 'DFFs','fig'); 
saveas(gcf, 'DFFs','png');

pause

figure(10);plot(time,dff_freq(:,1:end-2)); hold on; plot(time,dff(:,end-1),'k','LineWidth',2); plot(time,dff(:,end),'r','LineWidth',2);

title('DFF running average with motion artifact in red and movement type in black','FontSize', 18);
saveas(gcf, 'DFFs freq','fig'); 
saveas(gcf, 'DFFs freq','png');

% identify noise for each ROI

baseline = ginput;

for i=1:length(rois)
    noise(i)= std(dff(baseline(1,1):baseline(2,1),i));
    noise_freq(i)= std(dff_freq(baseline(1,1):baseline(2,1),i));
    
end;

output.baseline=baseline;
output.noise=noise;
output.noise=noise_freq;


% find max for all bout

for i=1:NumberBout;
    for j=1:length(rois);
        
        display(['integral max and time to peak of bout' num2str(i) ' from roi ' num2str(j)])
        
        m=[]; m=min(BoutStart(i)+freq,size(dff,1));
        
        integral(j,i)=sum(dff(BoutStart(i):m,j));
        
        [amplitude(j,i), timetopeak(j,i)]=max(dff(BoutStart(i):m,j));
        
        signal2noise(j,i) = amplitude(j,i)/noise(j);
        
        timetopeak(j,i)=timetopeak(j,i)-BoutStart(i);
        
    end;
end;

output.amplitude=amplitude;
output.integral=integral;
output.timetopeak=timetopeak;


% find max_freq for all bout

for i=1:NumberBout;
    for j=1:length(rois);
        
        display(['integral max running average and time to peak of bout' num2str(i) ' from roi ' num2str(j)])
        
        m=[]; m=min(BoutStart(i)+freq,size(dff,1));
        
        integral_freq(j,i)=sum(dff_freq(BoutStart(i):m,j));
        
        [amplitude_freq(j,i), timetopeak_freq(j,i)]=max(dff_freq(BoutStart(i):m,j));
        
        signal2noise_freq(j,i) = amplitude_freq(j,i)/noise_freq(j);
        
        timetopeak_freq(j,i)=timetopeak_freq(j,i)-BoutStart(i);
        
    end;
end;

output.amplitude=amplitude;
output.integral=integral;
output.timetopeak=timetopeak;




%%%%

figure(2); 
subplot(2,1,1),hist(noise,[-2:0.25:10]); 
hold on; 
subplot(2,1,2),hist(amplitude,[-2:0.25:10]); 
title('Distribution of Noise and Peak DFF during Swim bouts','FontSize', 18);
saveas(gcf, 'Noise and Peak DFF','fig'); 
saveas(gcf, 'Noise and Peak DFF','png');


%%%%

figure(12); 
subplot(2,1,1),hist(noise_freq,[-2:0.25:10]); 
hold on; 
subplot(2,1,2),hist(amplitude_freq,[-2:0.25:10]); 
title('Distribution of Noise and Peak DFF during Swim bouts after running avg','FontSize', 18);
saveas(gcf, 'Noise and Peak DFF after running avg','fig'); 
saveas(gcf, 'Noise and Peak DFF after running avg','png');


Yone=[0:0.01:round(max(noise))];

%%%%

figure(3);hold on;

for j=1:length(rois);
   for i=1:NumberBout;
       plot(Yone,Yone,'k');
       plot(Yone,2*Yone,'r');
       plot(Yone,3*Yone,'g');
       hold on
       plot(noise(j),amplitude(j,i),'o-');hold on;
   end;
end;
title('Peak DFF during Swim bouts as a function of noise','FontSize', 18);
saveas(gcf, 'Peak DFF during Swim bouts as a function of noise','fig'); 
saveas(gcf, 'Peak DFF during Swim bouts as a function of noise','png');

%%%%

figure(13);

hold on;

for j=1:length(rois);
   for i=1:NumberBout;
       plot(Yone,Yone,'k');
       plot(Yone,2*Yone,'r');
       plot(Yone,3*Yone,'g');
       hold on
       plot(noise(j),amplitude_freq(j,i),'o-');hold on;
   end;
end;
title('Peak DFF after running average during Swim bouts as a function of noise','FontSize', 18);
saveas(gcf, 'Peak DFF after running average during Swim bouts as a function of noise','fig'); 
saveas(gcf, 'Peak DFF after running average during Swim bouts as a function of noise','png');

%%%%

figure(5);

hold on;

for j=1:length(rois);
   for i=1:NumberBout;
       plot(Yone,10*Yone,'k');
       hold on
       plot(noise(j),integral(j,i),'o-');hold on;
   end;
end;
title('Peak integral during Swim bouts as a function of noise','FontSize', 18);
saveas(gcf, 'Peak integral during Swim bouts as a function of noise','fig'); 
saveas(gcf, 'Peak integral during Swim bouts as a function of noise','png');

figure(15);

hold on;

for j=1:length(rois);
   for i=1:NumberBout;
       plot(Yone,10*Yone,'k');
       hold on
       plot(noise(j),integral_freq(j,i),'o-');hold on;
   end;
end;
title('Integral DFF after running average during Swim bouts as a function of noise','FontSize', 18);
saveas(gcf, 'Integral DFF after running average during Swim bouts as a function of noise','fig'); 
saveas(gcf, 'Integral DFF after running average during Swim bouts as a function of noise','png');
