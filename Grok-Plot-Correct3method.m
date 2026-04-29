% TDLAS experiment with length 11 cm, the gas use is methane
% Normal pressure situation (1 atm)
clear; close all; clc;

% ==================== File names and concentrations ====================
filenames = { ...
    'CH4-0ppm-thomas.txt', ...
    'CH4-2000ppm-thomas.txt', ...
    'CH4-4000ppm-thomas.txt', ...
    'CH4-6000ppm-thomas.txt', ...
    'CH4-8000ppm-thomas.txt', ...
    'CH4-10000ppm-thomas.txt'};

conc_ppm = [2000 4000 6000 8000 10000];   % row vector
plot_colors = {[0 0 1], ...           % blue
               [0.635 0.078 0.184], ... 
               [0 0.8 0.8], ...      
               [0 0.8 0], ...      
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
    
    % Interpolate to ensure same time/frequency axis
    I_interp = interp1(time_k, I_k, time0, 'linear', 'extrap');
    
    % BEER-LAMBERT LAW: A = -ln(I/I0)
    A = -log(I_interp ./ I0);
    A(A < 0) = 0; % Physical floor
    A_all(:, k-1) = A;
end

freq = linspace(2000, 2250, num_points);

% ==================== FIGURE 1: Absorbance Spectra ====================
figure(1);
set(gcf, 'Position', [100 100 800 500]);
hold on;
for k = 1:5
    plot(freq, A_all(:,k), 'Color', plot_colors{k}, 'LineWidth', 1.5);
end
hold off;
xlabel('Frequency (cm^{-1})');
ylabel('Absorbance');
title('CH_4 Absorbance Spectra (L = 11 cm, P = 1 atm)');
grid on; box on;
legend_str = arrayfun(@(c) sprintf('CH4: %d ppm', c), conc_ppm, 'UniformOutput', false);
legend(legend_str, 'Location', 'northwest');

% ==================== Peak & Area Calculation ====================
peak_range = [2190 2210];
idx_band   = freq >= peak_range(1) & freq <= peak_range(2);

conc_ppm_full = conc_ppm(:);
A_peak = zeros(5,1);
A_area = zeros(5,1);

for k = 1:5
    A_peak(k) = max(A_all(idx_band, k));
    A_area(k) = trapz(freq(idx_band), A_all(idx_band, k));
end

% ==================== FIGURE 2: Method 1 (Peak Absorbance) ====================
figure(2);
set(gcf, 'Position', [500 100 600 500]);
plot(conc_ppm_full, A_peak, 'o', 'LineWidth', 2, 'MarkerSize', 8, 'Color', [0 0.447 0.741]);
hold on;
p_peak = polyfit(conc_ppm_full, A_peak, 1);
fit_y_peak = polyval(p_peak, conc_ppm_full);
plot(conc_ppm_full, fit_y_peak, 'r--', 'LineWidth', 2);

% R^2 Calculation
R2_peak = 1 - sum((A_peak - fit_y_peak).^2) / ((length(A_peak)-1) * var(A_peak));

xlabel('Concentration (ppm)');
ylabel('Peak Absorbance');
title('Method 1: Peak Absorbance Linearity');
legend('Experimental', sprintf('Fit R^2 = %.4f', R2_peak), 'Location', 'northwest');
grid on;

% ==================== FIGURE 3: Method 2 (Integrated Area) ====================
figure(3);
set(gcf, 'Position', [900 100 600 500]);
plot(conc_ppm_full, A_area, 's', 'LineWidth', 2, 'MarkerSize', 8, 'Color', [0.85 0.325 0.098]);
hold on;
p_area = polyfit(conc_ppm_full, A_area, 1);
fit_y_area = polyval(p_area, conc_ppm_full);
plot(conc_ppm_full, fit_y_area, 'b--', 'LineWidth', 2);

% R^2 Calculation
R2_area = 1 - sum((A_area - fit_y_area).^2) / ((length(A_area)-1) * var(A_area));

xlabel('Concentration (ppm)');
ylabel('Integrated Area (cm^{-1})');
title('Method 2: Integrated Area Linearity');
legend('Experimental', sprintf('Fit R^2 = %.4f', R2_area), 'Location', 'northwest');
grid on;

% ==================== SAVE IMAGES (3 PNG files) ====================
print(figure(1), 'Output_Spectra.png', '-dpng', '-r300');
print(figure(2), 'Output_Method1_Peak.png', '-dpng', '-r300');
print(figure(3), 'Output_Method2_Area.png', '-dpng', '-r300');

% ==================== EXPORT DATA (2 Excel files) ====================
T1 = table(conc_ppm_full, A_peak, 'VariableNames', {'Conc_ppm', 'Peak_Absorbance'});
T1_stats = table(R2_peak, p_peak(1), 'VariableNames', {'R2', 'Slope'});
writetable(T1, 'Method1_Results.xlsx', 'Sheet', 'Data');
writetable(T1_stats, 'Method1_Results.xlsx', 'Sheet', 'Stats');

T2 = table(conc_ppm_full, A_area, 'VariableNames', {'Conc_ppm', 'Integrated_Area'});
T2_stats = table(R2_area, p_area(1), 'VariableNames', {'R2', 'Slope'});
writetable(T2, 'Method2_Results.xlsx', 'Sheet', 'Data');
writetable(T2_stats, 'Method2_Results.xlsx', 'Sheet', 'Stats');

disp('Success: 3 PNGs and 2 Excel files generated.');
