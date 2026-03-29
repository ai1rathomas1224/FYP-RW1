% https://spectraplot.com/absorption
% website for standard absorption

% Clear workspace and close all figures
clear all; close all; clc;

% Get all text files in the current directory
txt_files = dir('*.txt');

% Create a figure
figure;
hold on;

% Define colors for different concentrations (using jet colormap)
colors = jet(length(txt_files));

% Initialize legend entries
legend_entries = {};

% Loop through each text file
for i = 1:length(txt_files)
    % Get filename
    filename = txt_files(i).name;

    % Read the data
    try
        % Try readmatrix first (for modern MATLAB)
        data = readmatrix(filename);
    catch
        % If readmatrix fails, try importdata
        data = importdata(filename);
        if isstruct(data)
            data = data.data;
        end
    end

    % Check if data is valid
    if ~isempty(data) && size(data,2) >= 2
        % Extract x and y data (assuming first column is x, second is y)
        x = data(:,1);
        y = data(:,2);

        % Plot the data
        plot(x, y, 'Color', colors(i,:), 'LineWidth', 1.5);

        % Create legend entry from filename
        % Extract concentration from filename
        [~, name, ~] = fileparts(filename);
        % Clean up the name for legend
        name = strrep(name, '-thomas', '');
        name = strrep(name, '.txt', '');
        name = strrep(name, 'CH4-', '');
        name = strrep(name, 'ppm', ' ppm');
        legend_entries{i} = name;
    else
        warning('File %s does not contain valid data', filename);
    end
end

% Customize the plot
xlabel('X Data', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Y Data', 'FontSize', 12, 'FontWeight', 'bold');
title('Methane Concentration Data', 'FontSize', 14, 'FontWeight', 'bold');
legend(legend_entries, 'Location', 'best', 'FontSize', 10);
hold off;