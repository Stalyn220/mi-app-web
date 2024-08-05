function newton_interpolation_gui
    % Create the figure
    fig = uifigure('Name', 'Interpolación de Newton', 'Position', [100 100 800 600]);

    % Create the table for input
    uit = uitable(fig, 'Data', cell(5, 2), 'ColumnName', {'x', 'f(x)'}, ...
        'ColumnEditable', [true true], 'Position', [20 300 760 200]);

    % Create the plot button
    plotBtn = uibutton(fig, 'Text', 'Realizar Interpolación', 'Position', [20 250 200 40], ...
        'ButtonPushedFcn', @(btn, event) plot_graph(uit, fig));

    % Create the clear button
    clearBtn = uibutton(fig, 'Text', 'Borrar Datos', 'Position', [250 250 200 40], ...
        'ButtonPushedFcn', @(btn, event) clear_data(uit));

    % Create the exit button
    exitBtn = uibutton(fig, 'Text', 'Salir', 'Position', [480 250 200 40], ...
        'ButtonPushedFcn', @(btn, event) close(fig));

    % Create the polynomial label
    polyLabel = uilabel(fig, 'Text', 'Polinomio: ', 'Position', [20 200 760 40]);

    % Create axes for plotting
    ax = uiaxes(fig, 'Position', [20 20 760 160]);
end

function plot_graph(uit, fig)
    data = uit.Data;
    x = str2double(data(:, 1));
    y = str2double(data(:, 2));

    if any(isnan(x)) || any(isnan(y))
        uialert(fig, 'Por favor ingrese números válidos.', 'Error');
        return;
    end

    x_values = linspace(min(x), max(x), 100);
    [y_values, coefficients] = newton_interpolation(x, y, x_values);
    poly_str = polynomial_to_string(coefficients, x);

    ax = findobj(fig, 'Type', 'axes');
    cla(ax);
    plot(ax, x_values, y_values, 'DisplayName', 'Polinomio de Newton');
    hold(ax, 'on');
    scatter(ax, x, y, 'red', 'DisplayName', 'Puntos dados');
    hold(ax, 'off');
    legend(ax, 'show');
    title(ax, 'Interpolación de Newton');

    polyLabel = findobj(fig, 'Type', 'uilabel');
    polyLabel.Text = ['Polinomio: ', poly_str];
end

function clear_data(uit)
    uit.Data = cell(5, 2);
    ax = findobj(gcf, 'Type', 'axes');
    cla(ax);
    polyLabel = findobj(gcf, 'Type', 'uilabel');
    polyLabel.Text = 'Polinomio: ';
end

function [y_values, coefficients] = newton_interpolation(x, y, x_values)
    n = length(x);
    coefficients = zeros(n, n);
    coefficients(:, 1) = y(:);

    for j = 2:n
        for i = 1:n-j+1
            coefficients(i, j) = (coefficients(i+1, j-1) - coefficients(i, j-1)) / (x(i+j-1) - x(i));
        end
    end

    y_values = coefficients(1, 1) * ones(size(x_values));
    for i = 2:n
        term = coefficients(1, i) * ones(size(x_values));
        for j = 1:i-1
            term = term .* (x_values - x(j));
        end
        y_values = y_values + term;
    end
end

function poly_str = polynomial_to_string(coefficients, x)
    n = length(coefficients);
    terms = {sprintf('%.2f', coefficients(1, 1))};
    for i = 2:n
        term = sprintf('%+.2f', coefficients(1, i));
        for j = 1:i-1
            term = [term, sprintf('(x - %.2f)', x(j))];
        end
        terms{end+1} = term;
    end
    poly_str = strjoin(terms, ' ');
end
