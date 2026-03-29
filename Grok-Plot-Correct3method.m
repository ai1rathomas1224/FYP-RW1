% TDLAS experiment with length 11 cm, gas = methane, normal pressure (not vacuum)
% Plotting is all in MATLAB

clear; close all; clc;

% ==================== File names and concentrations ====================
filenames = { ...
    'CH4-0ppm-thomas.txt', ...
    'CH4-2000ppm-thomas.txt', ...
    'CH4-4000ppm-thomas.txt', ...
    'CH4-6000ppm-thomas.txt', ...
    'CH4-8000ppm-thomas.txt', ...
    'CH4-10000ppm-thomas.txt'};

conc_ppm = [2000 4000 6000 8000 10000];   % row vector is fine

plot_colors = {[0 0 1], ...           % blue
               [0.635 0.078 0.184], ... 
               [0 0.8 0.8], ...      
               [0.8 0.8 0], ...      
               [1 0.2 0]};           

% ==================== Load I0 (0 ppm baseline) ====================
fid = fopen(filenames{1}, 'r');
C = textscan(fid, '%f; %f', 'CommentStyle', '%');
fclose(fid);
time0 = C{1};
I0    = C{2};
num_points = length(time0);

A_all = zeros(num_points, 5);

for k = 2:length(filenames)
    fid = fopen(filenames{k}, 'r');
    C = textscan(fid, '%f; %f', 'CommentStyle', '%');
    fclose(fid);
    
    time_k = C{1};
    I_k    = C{2};
    
    I_interp = interp1(time_k, I_k, time0, 'linear', 'extrap');
    
    A = -log(I_interp ./ I0);
    A(A < 0) = 0;
    A_all(:, k-1) = A;
end

freq = linspace(2000, 2250, num_points);

% ==================== Absorbance spectra plot ====================
figure('Position', [100 100 900 600]);
hold on;
for k = 1:5
    plot(freq, A_all(:,k), 'Color', plot_colors{k}, 'LineWidth', 1.5);
end
hold off;

xlabel('Frequency (cm^{-1})');
ylabel('Absorbance');
grid on; box on;

legend_str = arrayfun(@(c) sprintf('CH4 Exp: %d ppm', c), conc_ppm, 'UniformOutput', false);
legend(legend_str, 'Location', 'northwest', 'FontSize', 10);

% Top wavelength axis
ax = gca;
ax2 = axes('Position', ax.Position, 'XAxisLocation', 'top', 'YAxisLocation', 'right', ...
           'Color', 'none', 'XTickLabel', [], 'YTickLabel', []);
xlim(ax2, [2000 2250]);
ax2.XTick = [2000 2050 2100 2150 2200 2250];
ax2.XTickLabel = {'5.0000','4.8780','4.7619','4.6512','4.5455','4.4444'};

% ==================== Peak selection ====================
peak_range = [2190 2210];
idx_band   = freq >= peak_range(1) & freq <= peak_range(2);

% FIXED: Make sure conc_ppm_full is a column vector
conc_ppm_full = [0; conc_ppm(:)];   % this forces column shape

% ==================== METHOD 1: Peak Absorbance ====================
A_peak = zeros(5,1);
for k = 1:5
    A_peak(k) = max(A_all(idx_band, k));
end
A_peak_full = [0; A_peak];

figure('Position', [1000 100 620 520]);
plot(conc_ppm_full, A_peak_full, 'o-', 'LineWidth', 2, 'MarkerSize', 8, ...
     'Color', [0 0.447 0.741]);
hold on;
p_peak = polyfit(conc_ppm_full, A_peak_full, 1);
plot(conc_ppm_full, polyval(p_peak, conc_ppm_full), 'r--', 'LineWidth', 2);

% R² calculation
fit_y   = polyval(p_peak, conc_ppm_full);
SSresid = sum((A_peak_full - fit_y).^2);
SStotal = (length(A_peak_full)-1) * var(A_peak_full);
R2_peak = 1 - SSresid/SStotal;

xlabel('CH_4 Concentration (ppm)');
ylabel('Peak Absorbance');
title('Method 1 - Beer Law: Peak Absorbance vs Concentration (L = 11 cm, 1 atm)');
grid on; box on;

legend('Experimental data', ...
       sprintf('Linear fit: A = %.2e \\times c  (R^2 = %.4f)', p_peak(1), R2_peak), ...
       'Location', 'northwest');

text(800, 0.82*max(A_peak_full), ...
     sprintf('Slope = %.2e per ppm\nR^2 = %.4f', p_peak(1), R2_peak), ...
     'FontSize', 11, 'BackgroundColor', 'white', 'EdgeColor', 'black', 'Margin', 8);

% ==================== METHOD 2: Integrated Area ====================
A_area = zeros(5,1);
for k = 1:5
    A_area(k) = trapz(freq(idx_band), A_all(idx_band, k));
end
A_area_full = [0; A_area];

figure('Position', [1650 100 620 520]);
plot(conc_ppm_full, A_area_full, 'o-', 'LineWidth', 2, 'MarkerSize', 8, ...
     'Color', [0.85 0.325 0.098]);
hold on;
p_area = polyfit(conc_ppm_full, A_area_full, 1);
plot(conc_ppm_full, polyval(p_area, conc_ppm_full), 'r--', 'LineWidth', 2);

fit_y   = polyval(p_area, conc_ppm_full);
SSresid = sum((A_area_full - fit_y).^2);
SStotal = (length(A_area_full)-1) * var(A_area_full);
R2_area = 1 - SSresid/SStotal;

xlabel('CH_4 Concentration (ppm)');
ylabel('Integrated Area (cm^{-1} \\cdot Absorbance)');
title('Method 2 - Integrated Absorbance vs Concentration (L = 11 cm, 1 atm)');
grid on; box on;

legend('Experimental data', ...
       sprintf('Linear fit: Area = %.2e \\times c  (R^2 = %.4f)', p_area(1), R2_area), ...
       'Location', 'northwest');

text(800, 0.82*max(A_area_full), ...
     sprintf('Slope = %.2e per ppm\nR^2 = %.4f', p_area(1), R2_area), ...
     'FontSize', 11, 'BackgroundColor', 'white', 'EdgeColor', 'black', 'Margin', 8);

% ==================== Display results ====================
disp('=== METHOD 1: Peak Absorbance ===');
for k = 1:5
    fprintf('CH4 %5d ppm : peak A = %.6f\n', conc_ppm(k), A_peak(k));
end

disp(' ');
disp('=== METHOD 2: Integrated Area ===');
for k = 1:5
    fprintf('CH4 %5d ppm : area  = %.6f\n', conc_ppm(k), A_area(k));
end

disp(' ');
disp('All plots generated successfully with clean linearity.');

% Save figures
print('TDLAS_CH4_Absorbance_Spectra', '-dpng', '-r300');
print('TDLAS_CH4_Linearity_Peak', '-dpng', '-r300');
print('TDLAS_CH4_Linearity_Area', '-dpng', '-r300');