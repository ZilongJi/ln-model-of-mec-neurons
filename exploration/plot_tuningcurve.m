%exploring the data
clear all; close all; clc

load('data_for_cell77.mat');

%% plot trajectory with spike
f = figure('visible','on','Position', [100 100 500 500]);
%%% Font type and size setting %%%
% Using Arial as default because all journals normally require the font to
% be either Arial or Helvetica
set(0,'DefaultAxesFontName','Arial')
set(0,'DefaultTextFontName','Arial')
set(0,'DefaultAxesFontSize',12)
set(0,'DefaultTextFontSize',12)   

plot(posx_c, posy_c, color='k');
hold on;
index = spiketrain~=0;
spikeX = posx_c(index);
spikeY = posy_c(index);
scatter(spikeX, spikeY, 10,'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r')
xlabel('Position X');ylabel('Position Y');


% compute a filter, which will be used to smooth the firing rate
filter = gaussmf(-4:4,[2 0]); filter = filter/sum(filter); 
dt = post(3)-post(2); fr = spiketrain/dt;
smooth_fr = conv(fr,filter,'same'); % returns only the central part of the convolution, the same size as fr

%% plot grid tuning curve
% initialize the number of bins that position will be divided into
n_pos_bins = 20;

[pos_curve] = compute_2d_tuning_curve(posx_c,posy_c,smooth_fr,n_pos_bins,0,boxSize);
figure; imagesc(pos_curve); colorbar
axis off
title('Position')

%% plot head direction tuning curve
% initialize the number of bins that head direction will be divided into
n_dir_bins = 18;

% compute head direction matrix
[hdgrid,hdVec,direction] = hd_map(posx,posx2,posy,posy2,n_dir_bins);

[hd_curve] = compute_1d_tuning_curve(direction,smooth_fr,n_dir_bins,0,2*pi);

% create x-axis vectors
hd_vector = 2*pi/n_dir_bins/2:2*pi/n_dir_bins:2*pi - 2*pi/n_dir_bins/2; %the median value of each interval
figure;plot(hd_vector,hd_curve,'k','linewidth',3)
box off
axis([0 2*pi -inf inf])
xlabel('direction angle')
title('Head direction')

%% plot speed tuning curve
% initialize the number of bins that speed will be divided into
n_speed_bins = 10;

%compute running speed
[speedgrid,speedVec,speed] = speed_map(posx_c,posy_c,n_speed_bins);

[speed_curve] = compute_1d_tuning_curve(speed,smooth_fr,n_speed_bins,0,50);

speed_vector = 2.5:50/n_speed_bins:47.5;

figure;plot(speed_vector,speed_curve,'k','linewidth',3)
box off
xlabel('Running speed')
axis([0 50 -inf inf])
title('Speed')

%% plot theta tuning curve
% initialize the number of bins that theta will be divided into
n_theta_bins = 18;

%compute theta phase
[thetagrid,thetaVec,phase] = theta_map(filt_eeg,post,eeg_sample_rate,n_theta_bins);

[theta_curve] = compute_1d_tuning_curve(phase,fr,n_theta_bins,0,2*pi);

theta_vector = hd_vector;

figure;plot(theta_vector,theta_curve,'k','linewidth',3)
xlabel('Theta phase')
axis([0 2*pi -inf inf])
box off
title('Theta')