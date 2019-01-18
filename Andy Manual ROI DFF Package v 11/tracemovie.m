mkdir('video_output')

[m,n] = size(data.dff);

h1 = figure('Position', [100, 100, 1200, 1200]);
set(h1, 'DefaultAxesColor', 'none');
%axis off

xlim([1,n]);
% ylim([0 3000]); % <- need to set this manually if there is going to be a rescaling of data!

% method one (scatter, bad)
% for i = 1:n;
%     scatter(ones(m,1).*i, data.dff(:,i)+[1:100:100*m]', '.', 'k')
%     pause(0.01);
% end

% method two (line, good)
hold on

cmap = lines(m);

for i = 1:n-1 % can manually set frame count here, usually n-1
    for j = 1:m
        line([i, i+1], [data.dff(j,i)+(100*j), data.dff(j,i+1)+(100*j)], 'Color', cmap(j,:), 'LineWidth', 1)
    end
    
    frameName = strcat('frame_', num2str(i));
    
    %saveas(h1, fullfile('video_output',frameName), 'png')
    %pause(0.01);
end

% now generate final scale frame

%frameName = 'scale_frame';

axis on
%saveas(h1, fullfile('video_output', frameName), 'png')