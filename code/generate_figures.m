function generate_figures()
    % =================================================================
    % Regenerates the MATLAB-generated figures of the thesis and writes
    % the PDF files to <repo_root>/figures/.
    %
    % This script is a wrapper. Each figure is drawn by a sub-function.
    % To add or remove a figure, add or remove a call at the bottom.
    % =================================================================

    repo_root = 'C:\Users\chris\Documents\GitHub\secure-dlsc-ugk-cyclic';
    fig_dir   = fullfile(repo_root, 'figures');

    if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end

    fprintf('Generating figures...\n');

    fig3_1_workflow(fig_dir);
    fig3_2_incidence(fig_dir);
    fig3_4_hypothesis(fig_dir);
    fig4_1_design(fig_dir);
    fig4_2_position(fig_dir);
    fig4_3_visible(fig_dir);
    fig4_4_complement(fig_dir);
    fig4_5_landscape(fig_dir);
    fig4_6_penalty_ratio(fig_dir);
    fig4_7_field_sensitivity(fig_dir);

    fprintf('All figures generated in %s\n', fig_dir);
end

% =====================================================================
% Figure 3.1 -- analytical workflow
% =====================================================================
function fig3_1_workflow(fig_dir)
    fig = figure('Units','centimeters','Position',[2 2 20 18], ...
                 'Color','w','Renderer','painters');
    ax = axes('Position',[0 0 1 1]); hold(ax,'on');
    axis(ax,'equal'); axis(ax,'off'); xlim(ax,[0 1]); ylim(ax,[0 1]);

    box_w = 0.55; box_x = 0.28; box_h = 0.085; gap = 0.030;
    y1 = 0.87;
    y_positions = y1 - (0:5) * (box_h + gap);

    steps = {
        {'Formalize system model', '$(N, K, N_r, K_c, S, q, L)$'};
        {'Count UGK availability', '$\Omega(T)$ for every $T$ in $[N]$'};
        {'Derive converse bounds', 'entropy and rank inequalities'};
        {'Construct masked encoder', 'linear over GF$(q)$, key-local'};
        {'Check recovery and secrecy', 'exact rank obligations'};
        {'Exact finite-field verification', 'enumerate small instances'};
    };

    for i = 1:6
        yc = y_positions(i);
        rectangle('Position',[box_x yc box_w box_h], ...
            'FaceColor',[0.90 0.94 0.98], 'EdgeColor',[0.20 0.30 0.50], ...
            'LineWidth', 1.2, 'Curvature', 0.03);
        rectangle('Position',[0.16 yc+box_h/2-0.020 0.06 0.040], ...
            'FaceColor',[0.20 0.30 0.50], 'EdgeColor','none', 'Curvature', 0.5);
        text(0.19, yc+box_h/2, sprintf('%d',i), 'FontSize',11,'FontWeight','bold', ...
            'HorizontalAlignment','center','VerticalAlignment','middle','Color','w');
        text(box_x+box_w/2, yc+box_h-0.030, steps{i}{1}, ...
            'FontSize',11,'FontWeight','bold','HorizontalAlignment','center', ...
            'Color',[0.10 0.15 0.30]);
        text(box_x+box_w/2, yc+0.025, steps{i}{2}, ...
            'FontSize',8.5,'Interpreter','latex','HorizontalAlignment','center', ...
            'Color',[0.25 0.25 0.25]);
    end

    text(0.50,0.98,'Analytical and computational workflow', ...
        'FontSize',12,'FontWeight','bold','HorizontalAlignment','center');

    print(fig, fullfile(fig_dir,'fig3-1-workflow.pdf'), '-dpdf', '-painters');
    close(fig);
end

% =====================================================================
% Figure 3.2 -- cyclic data assignment incidence
% =====================================================================
function fig3_2_incidence(fig_dir)
    N = 6; K = 6; r = 4;
    fig = figure('Units','centimeters','Position',[2 2 18 12], ...
                 'Color','w','Renderer','painters');
    ax = axes('Position',[0.16 0.16 0.58 0.78]); hold(ax,'on');
    axis(ax,'equal'); axis(ax,'off'); xlim(ax,[0 K]); ylim(ax,[0 N]);

    M = zeros(N,K);
    for k = 1:K
        for j = 0:r-1
            n = mod((k-1)+j, N)+1;
            M(n,k) = 1;
        end
    end

    for n = 1:N
        for k = 1:K
            row_disp = N - n + 1;
            if M(n,k) == 1
                fc = [0.10 0.20 0.40];
            else
                fc = [0.94 0.94 0.94];
            end
            rectangle('Position',[k-1, row_disp-1, 1, 1], ...
                'FaceColor', fc, 'EdgeColor',[0.70 0.70 0.70], 'LineWidth', 0.5);
        end
    end

    text(0.50, 0.98, 'Cyclic data-assignment incidence', ...
        'FontSize', 12, 'FontWeight','bold', 'HorizontalAlignment','center');

    print(fig, fullfile(fig_dir,'fig3-2-cyclic.pdf'), '-dpdf', '-painters');
    close(fig);
end

% =====================================================================
% Figure 3.4 -- working threshold hypothesis
% =====================================================================
function fig3_4_hypothesis(fig_dir)
    N = 6; Nr = 3; r = N - Nr + 1;
    S_vals = 1:N;
    eta = zeros(1,N);
    for i = 1:N
        if S_vals(i) >= r
            eta(i) = Nr - 1;
        else
            eta(i) = Nr - 1 + ceil((Nr-1)/S_vals(i));
        end
    end

    fig = figure('Units','centimeters','Position',[2 2 16 11], ...
                 'Color','w','Renderer','painters');
    ax = axes('Position',[0.13 0.16 0.82 0.76]); hold(ax,'on'); box(ax,'on');

    patch([0.5 r r 0.5], [0 0 6 6], [1 0.94 0.94], ...
        'EdgeColor','none', 'FaceAlpha', 0.6);
    patch([r N+0.5 N+0.5 r], [0 0 6 6], [0.90 0.96 0.92], ...
        'EdgeColor','none', 'FaceAlpha', 0.6);

    for y = 1:6
        plot([0.5 N+0.5],[y y],'-','Color',[0.85 0.85 0.85],'LineWidth',0.5);
    end

    yline(Nr-1, '--', 'Color',[0.20 0.50 0.30], 'LineWidth', 1.5);
    xline(r, '--', 'Color',[0.70 0.20 0.20], 'LineWidth', 1.5);
    stairs(S_vals, eta, '-', 'Color',[0.10 0.30 0.60], 'LineWidth', 2.0);
    plot(S_vals, eta, 'o', 'MarkerFaceColor',[0.10 0.30 0.60], ...
        'MarkerEdgeColor','w','MarkerSize',6);

    xlim([0.5 N+0.5]); ylim([0 6]);
    set(ax,'XTick',1:N,'YTick',1:6);
    xlabel('UGK sharing size $S$','Interpreter','latex','FontSize',11);
    ylabel('Candidate $\eta^*(S)$','Interpreter','latex','FontSize',11);

    print(fig, fullfile(fig_dir,'fig3-4-hypothesis.pdf'), '-dpdf', '-painters');
    close(fig);
end

% =====================================================================
% Figure 4.1 -- layered design
% =====================================================================
function fig4_1_design(fig_dir)
    fig = figure('Units','centimeters','Position',[2 2 18 12], ...
                 'Color','w','Renderer','painters');
    ax = axes('Position',[0 0 1 1]); hold(ax,'on');
    axis(ax,'equal'); axis(ax,'off'); xlim(ax,[0 1]); ylim(ax,[0 1]);

    rectangle('Position',[0.05 0.60 0.90 0.32], ...
        'FaceColor',[0.94 0.96 0.99], 'EdgeColor',[0.20 0.40 0.70], ...
        'LineWidth', 1.8, 'Curvature', 0.03);
    text(0.50,0.90,'Outer layer: structural variables', ...
        'FontSize',11,'FontWeight','bold','HorizontalAlignment','center', ...
        'Color',[0.10 0.20 0.45]);

    rectangle('Position',[0.15 0.05 0.70 0.32], ...
        'FaceColor',[0.94 0.99 0.95], 'EdgeColor',[0.20 0.55 0.30], ...
        'LineWidth', 1.8, 'Curvature', 0.03);
    text(0.50,0.35,'Inner layer: algebraic variables', ...
        'FontSize',11,'FontWeight','bold','HorizontalAlignment','center', ...
        'Color',[0.10 0.40 0.20]);

    quiver(0.50,0.595,0,-0.20,0,'Color',[0.35 0.35 0.35], ...
        'LineWidth',1.5,'MaxHeadSize',0.8,'AutoScale','off');

    text(0.50,0.98,'Structure of the exhaustive analytical design', ...
        'FontSize',12,'FontWeight','bold','HorizontalAlignment','center');

    print(fig, fullfile(fig_dir,'fig4-1-design.pdf'), '-dpdf', '-painters');
    close(fig);
end

% =====================================================================
% Figure 4.2 -- position-dependent coverage
% =====================================================================
function fig4_2_position(fig_dir)
    fig = figure('Units','centimeters','Position',[2 2 20 16], ...
                 'Color','w','Renderer','painters');
    ax = axes('Position',[0.15 0.10 0.70 0.32]); hold(ax,'on'); box(ax,'on');
    bar(ax, [1 2 3], [4 5 6], 0.55, ...
        'FaceColor',[0.30 0.55 0.80], 'EdgeColor',[0.15 0.35 0.60], ...
        'LineWidth', 1.0);
    xlim(ax,[0.4 3.6]); ylim(ax,[0 7.5]);
    set(ax,'XTick',[1 2 3],'YTick',0:7,'FontSize',10);
    xlabel(ax,'cyclic separation $\delta$','Interpreter','latex','FontSize',10);
    ylabel(ax,'$|D(T)|$','Interpreter','latex','FontSize',10);
    title(ax,'Position dependence at fixed subset cardinality', ...
        'FontSize',10,'FontWeight','bold');

    print(fig, fullfile(fig_dir,'fig4-2-position.pdf'), '-dpdf', '-painters');
    close(fig);
end

% =====================================================================
% Figure 4.3 -- visible fraction
% =====================================================================
function fig4_3_visible(fig_dir)
    N = 6; S_vals = 1:N;
    r_list = [2 3 4 5];
    colors = [0.10 0.30 0.60; 0.85 0.50 0.10; 0.20 0.55 0.30; 0.65 0.20 0.25];
    markers = {'o','s','d','^'};

    fig = figure('Units','centimeters','Position',[2 2 18 11], ...
                 'Color','w','Renderer','painters');
    ax = axes('Position',[0.11 0.15 0.85 0.78]); hold(ax,'on'); box(ax,'on');

    for j = 1:length(r_list)
        r = r_list(j);
        frac = zeros(1,N);
        for i = 1:N
            S = S_vals(i);
            if S >= r
                frac(i) = 1;
            else
                frac(i) = 1 - nchoosek(r-1,S)/nchoosek(N,S);
            end
        end
        plot(ax, S_vals, frac, ['-' markers{j}], ...
            'Color', colors(j,:), 'LineWidth', 1.8, ...
            'MarkerFaceColor', colors(j,:), 'MarkerSize', 6);
    end

    xlim([0.5 N+0.5]); ylim([0 1.05]);
    set(ax,'XTick',1:N,'YTick',0:0.2:1,'FontSize',10);
    xlabel('UGK sharing size $S$','Interpreter','latex','FontSize',11);
    ylabel('visible fraction','Interpreter','latex','FontSize',11);

    print(fig, fullfile(fig_dir,'fig4-3-visible-fraction.pdf'), '-dpdf', '-painters');
    close(fig);
end

% =====================================================================
% Figure 4.4 -- complement-only groups
% =====================================================================
function fig4_4_complement(fig_dir)
    N = 6; S_vals = 1:N;
    r_list = [2 3 4 5];
    colors = [0.10 0.30 0.60; 0.85 0.50 0.10; 0.20 0.55 0.30; 0.65 0.20 0.25];
    markers = {'o','s','d','^'};

    fig = figure('Units','centimeters','Position',[2 2 18 11], ...
                 'Color','w','Renderer','painters');
    ax = axes('Position',[0.11 0.15 0.85 0.78]); hold(ax,'on'); box(ax,'on');

    for j = 1:length(r_list)
        r = r_list(j);
        c = zeros(1,N);
        for i = 1:N
            S = S_vals(i);
            if S <= r-1
                c(i) = nchoosek(r-1,S);
            end
        end
        plot(ax, S_vals, c, ['-' markers{j}], ...
            'Color', colors(j,:), 'LineWidth', 1.8, ...
            'MarkerFaceColor', colors(j,:), 'MarkerSize', 6);
    end

    xlim([0.5 N+0.5]); ylim([0 7]);
    set(ax,'XTick',1:N,'YTick',0:7,'FontSize',10);
    xlabel('UGK sharing size $S$','Interpreter','latex','FontSize',11);
    ylabel('complement-only groups $C(r-1,S)$','Interpreter','latex','FontSize',11);

    print(fig, fullfile(fig_dir,'fig4-4-complement.pdf'), '-dpdf', '-painters');
    close(fig);
end

% =====================================================================
% Figure 4.5 -- candidate landscape (single-panel example)
% =