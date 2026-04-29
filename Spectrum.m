% TDLAS Methane Peak Extraction (White Mode)
clear; close all; clc;

% ==================== Setup ====================
filenames = {'CH4-0ppm-thomas.txt', 'CH4-2000ppm-thomas.txt', ...
             'CH4-4000ppm-thomas.txt', 'CH4-6000ppm-thomas.txt', ...
             'CH4-8000ppm-thomas.txt', 'CH4-10000ppm-thomas.txt'};
conc_labels = {'2000 ppm', '4000 ppm', '6000 ppm', '8000 ppm', '10000 ppm'};

fid = fopen(filenames{1}, 'r');
C0 = textscan(fid, '%f; %f', 'CommentStyle', '%');
fclose(fid);
time0 = C0{1}; I0 = C0{2};

num_points = length(time0);
freq = linspace(2000, 2250, num_points);
peak_range = [2190 2210];
idx_bubble = freq >= peak_range(1) & freq <= peak_range(2);
freq_bubble = freq(idx_bubble);

% --- WHITE MODE STYLING ---
fig = figure('Color', 'w', 'Position', [100 100 850 550]); 
hold on;

ax = gca;
ax.Color = 'w';          % Inner background WHITE
ax.XColor = 'k';         % X-axis line & numbers BLACK
ax.YColor = 'k';         % Y-axis line & numbers BLACK

% Grid Styling: Light gray lines for a clean look
ax.GridColor = [0.8 0.8 0.8];      
ax.GridAlpha = 0.6;     
ax.GridLineStyle = ':';

colors = jet(5); 

% ==================== Extraction Loop ====================
for k = 2:length(filenames)
    fid = fopen(filenames{k}, 'r');
    Ck = textscan(fid, '%f; %f', 'CommentStyle', '%');
    fclose(fid);
    
    I_sig = interp1(Ck{1}, Ck{2}, time0, 'linear', 'extrap');
    A_raw = -log(I_sig ./ I0);
    A_bubble = A_raw(idx_bubble);
    
    baseline_offset = (A_bubble(1) + A_bubble(end)) / 2;
    A_clean = A_bubble - baseline_offset;
    A_clean(A_clean < 0) = 0; 
    
    plot(freq_bubble, A_clean, 'Color', colors(k-1,:), 'LineWidth', 2, ...
         'DisplayName', conc_labels{k-1});
end

% ==================== Formatting ====================
xlabel('Frequency (cm^{-1})', 'FontWeight', 'bold', 'Color', 'k');
ylabel('Absorbance', 'FontWeight', 'bold', 'Color', 'k');
title('Extracted Methane Absorption Peak', 'FontSize', 12, 'Color', 'k');

% Legend: Standard white box
lgd = legend('Location', 'northeast');
lgd.TextColor = 'k';     
lgd.Color = 'w';         

grid on; box on;
