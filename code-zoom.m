% ==========================================
% TDLAS experiment with length 11 cm, gas = methane, normal pressure (not vacuum)
% Plotting is all in MATLAB
% Plot 3: Raw Data Verification - BLACK BACKGROUND, WHITE TEXT
% ==========================================

clear; close all; clc;

% ==================== File names and concentrations ====================
filenames = { ...
    'CH4-0ppm-thomas.txt', ...
    'CH4-2000ppm-thomas.txt', ...
    'CH4-4000ppm-thomas.txt', ...
    'CH4-6000ppm-thomas.txt', ...
    'CH4-8000ppm-thomas.txt', ...
    'CH4-10000ppm-thomas.txt'};

conc_ppm = [0 2000 4000 6000 8000 10000];

% ==================== Load all data ====================
data = cell(length(filenames), 1);
time_all = cell(length(filenames), 1);
volt_all = cell(length(filenames), 1);

for i = 1:length(filenames)
    fid = fopen(filenames{i}, 'r');
    C = textscan(fid, '%f; %f', 'CommentStyle', '%');
    fclose(fid);
    time_all{i} = C{1};
    volt_all{i} = C{2};
end

% Use 0 ppm as reference time
time0 = time_all{1};
I0    = volt_all{1};

% ==================== Integration window for one absorption bubble ====================
x_start = -0.495;
x_end   = -0.405;
idx = time0 >= x_start & time0 <= x_end;

time_window = time0(idx);
I0_window   = I0(idx);

% ==================== Plot 3: Raw Voltage Data - Black Background, White Text ====================
figure('Name', 'Plot 3 - Raw Voltage Data inside Integration Window', ...
       'Position', [100 100 950 620], 'Color', 'k');

hold on;

% 0 ppm Baseline - thick white line
plot(time_window, I0_window, 'w-', 'LineWidth', 3, ...
     'DisplayName', '0 ppm Baseline (I_0)');

% Sample curves with nice contrasting colors
colors = [0.8 0.8 1; ...      % light blue
          1 0.6 0.6; ...      % light red
          0.6 1 0.6; ...      % light green
          1 1 0.4; ...        % light yellow
          1 0.7 1];           % light magenta

for k = 2:length(filenames)
    I_k = volt_all{k};
    I_interp = interp1(time_all{k}, I_k, time0, 'linear', 'extrap');
    I_window = I_interp(idx);
    
    plot(time_window, I_window, '-', 'LineWidth', 1.8, ...
         'Color', colors(k-1,:), ...
         'DisplayName', sprintf('%d ppm CH_4', conc_ppm(k)));
end

hold off;

% ====================== Black background + White text styling ======================
set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w', 'GridColor', 'w', ...
         'MinorGridColor', [0.3 0.3 0.3]);

grid on; box on;

xlabel('Time (s)', 'FontSize', 13, 'Color', 'w', 'FontWeight', 'bold');
ylabel('Voltage (V)', 'FontSize', 13, 'Color', 'w', 'FontWeight', 'bold');
title('Plot 3: Raw Voltage Signals inside Integration Window (One Absorption Bubble)', ...
      'FontSize', 15, 'Color', 'w', 'FontWeight', 'bold');

legend('Location', 'best', 'FontSize', 11, 'TextColor', 'w', ...
       'Color', 'k', 'EdgeColor', 'w');

set(gca, 'FontSize', 12);

% ====================== Save high-resolution figure ======================
print('TDLAS_Plot3_RawData_BlackBackground', '-dpng', '-r400');

disp('Plot 3 (Black background, white text) has been generated and saved as:');
disp('TDLAS_Plot3_RawData_BlackBackground.png');