%% ============================================================
%  CONTROLO - RELATÓRIO 2
%  3 - Projeto e análise do controlo de velocidade
%  4 - Projeto e análise do controlo de posição
%
%  Modelo identificado no Relatório 1:
%
%       G(s) = k0*a/(s+a)
%
%  com:<
%       k0 = 0.0911
%       a  = 2.1119 s^-1
% =============================================================

%% ============================================================
%  0 - INICIALIZAÇÃO GERAL
% =============================================================

clear; clc; close all;

% -------------------------------------------------------------
% Pasta base do projeto
% -------------------------------------------------------------
% Resolve the project directory from this script so the project is portable.
projectDir = fileparts(mfilename('fullpath'));

if ~isfolder(projectDir)
    error('A pasta projectDir não existe. Corrige o caminho no início do script.');
end

cd(projectDir);
fprintf('\nPasta do projeto:\n%s\n', pwd);


% Parâmetros identificados no Relatório 1
k0 = 0.0911;
a  = 2.1119;

% Planta identificada
G = tf(k0*a,[1 a]);

% Pasta de saída das figuras
outDir = fullfile(pwd,'Image');

if ~exist(outDir,'dir')
    mkdir(outDir);
end

fprintf('\n============================================\n');
fprintf('RELATÓRIO 2 - MODELO IDENTIFICADO\n');
fprintf('============================================\n');
fprintf('k0 = %.4f\n', k0);
fprintf('a  = %.4f s^-1\n', a);
fprintf('G(s) = %.4f/(s + %.4f)\n', k0*a, a);


% =============================================================
%  3.1 - CONTROLO PROPORCIONAL DA VELOCIDADE
%
%  Controlador:
%       K(s) = k_w
%
%  Objetivo:
%       Determinar k_w > 0 tal que o tempo de estabelecimento
%       a 20%% seja inferior a 0.3 s.
% =============================================================

% Garantir que o modelo existe, mesmo que o bloco seja corrido isoladamente
if ~exist('G','var')
    k0 = 0.0911;
    a  = 2.1119;
    G = tf(k0*a,[1 a]);
end

if ~exist('outDir','var')
    outDir = fullfile(pwd,'Image');
    if ~exist(outDir,'dir')
        mkdir(outDir);
    end
end

% ===============================
% Especificação da questão 3.1
% ===============================

Ts_req_31 = 0.3;      % [s]
tol_31    = 0.20;     % critério de 20%

% Para sistema de 1ª ordem:
%
%       Ts_20 = -ln(0.2)/|p|
%
p_min_31 = -log(tol_31)/Ts_req_31;

% Com controlo proporcional:
%
%       polo = -(a + k0*a*k_w)
%
% Impor:
%
%       a + k0*a*k_w > p_min
%
kw_min_31 = (p_min_31 - a)/(k0*a);

fprintf('\n============================================\n');
fprintf('3.1 - CONTROLO PROPORCIONAL\n');
fprintf('============================================\n');
fprintf('Critério: Ts_20 < %.2f s\n', Ts_req_31);
fprintf('p_min = %.4f\n', p_min_31);
fprintf('k_w > %.4f\n', kw_min_31);

% Ganhos para comparação gráfica
kw_31 = [5, kw_min_31, 20, 30];

bg    = [0 0 0];
fg    = [1 1 1];
gridc = [0.45 0.45 0.45];

% Cores em fundo preto
c_blue   = [0.20 0.60 1.00];
c_orange = [1.00 0.55 0.10];
c_green  = [0.20 0.90 0.35];
c_yellow = [1.00 0.85 0.10];
c_red    = [1.00 0.25 0.25];
c_gray   = [0.70 0.70 0.70];

colors_31 = {c_blue, c_orange, c_green, c_yellow};
styles_31 = {'-','-','-','-'};
widths_31 = [1.8 1.8 1.8 2.0];


% =============================================================
% Figura 31 - Lugar das raízes usando rlocus() para obter dados
% =============================================================

figure(31); clf;
set(gcf,'Color',bg,'InvertHardcopy','off');
hold on;

% Ganhos usados para gerar o lugar das raízes
k_rl = linspace(0,80,500);

% Obter polos de malha fechada através da função rlocus()
r_rl = rlocus(G,k_rl);

% Como o sistema é de 1ª ordem, há apenas um ramo
plot(real(r_rl), imag(r_rl), ...
    'Color', c_blue, ...
    'LineWidth', 2.0);

% Polo inicial da planta
plot(-a,0,'o', ...
    'MarkerEdgeColor', c_yellow, ...
    'MarkerFaceColor', bg, ...
    'MarkerSize', 7, ...
    'LineWidth',1.6);

% Limite associado ao critério Ts20 < 0.3 s
xline(-p_min_31,'--', ...
    'Color', c_red, ...
    'LineWidth',1.6);

grid on;

ax = gca;
ax.Color = bg;
ax.XColor = fg;
ax.YColor = fg;
ax.GridColor = gridc;
ax.GridAlpha = 0.35;
ax.FontSize = 10;

title('Lugar das raízes com controlo proporcional', ...
    'Color', fg, ...
    'FontWeight','bold');

xlabel('Eixo real', ...
    'Color', fg);

ylabel('Eixo imaginário', ...
    'Color', fg);

legend('Lugar das raízes', ...
       'Polo da planta', ...
       'Limite T_s^{20\%}=0.3 s', ...
       'TextColor', fg, ...
       'Color', bg, ...
       'EdgeColor', fg, ...
       'Location','northeast');

xlim([-20 1]);
ylim([-0.3 0.3]);

exportgraphics(gcf, ...
    fullfile(outDir,'Fig31_RootLocus_P.png'), ...
    'BackgroundColor', bg, ...
    'Resolution', 300);


% =============================================================
% Figura 32 - Resposta ao degrau com valores finais discretos
% =============================================================

figure(32); clf;
set(gcf,'Color',bg,'InvertHardcopy','off');

hold on;

t = linspace(0,1.2,1000);

fprintf('\nResultados das respostas ao degrau:\n');

y_final_31 = zeros(size(kw_31));

for i = 1:length(kw_31)

    kw = kw_31(i);
    T_31 = feedback(kw*G,1);

    [y,tout] = step(T_31,t);

    plot(tout,y, ...
        'LineStyle', styles_31{i}, ...
        'Color', colors_31{i}, ...
        'LineWidth', widths_31(i));

    y_final_31(i) = dcgain(T_31);

    % Marcador discreto no valor final
    plot(t(end), y_final_31(i), 'o', ...
        'MarkerSize', 4, ...
        'MarkerFaceColor', colors_31{i}, ...
        'MarkerEdgeColor', colors_31{i}, ...
        'HandleVisibility','off');

    info_31 = stepinfo(T_31, ...
        'SettlingTimeThreshold', tol_31);

    fprintf('\n k_w = %.4f\n', kw);
    fprintf('  Ts_20       = %.4f s\n', info_31.SettlingTime);
    fprintf('  Overshoot   = %.2f %%\n', info_31.Overshoot);
    fprintf('  Valor final = %.4f\n', y_final_31(i));

end

% Referência unitária
yline(1,'-', ...
    'Color', c_gray, ...
    'LineWidth',1.2);

% Limite temporal da especificação
xline(Ts_req_31,'--', ...
    'Color', c_red, ...
    'LineWidth',1.4);

grid on;

ax = gca;
ax.Color = bg;
ax.XColor = fg;
ax.YColor = fg;
ax.GridColor = gridc;
ax.GridAlpha = 0.35;
ax.FontSize = 10;

title('Resposta ao degrau em malha fechada para diferentes valores de k_\omega', ...
    'Color', fg);

xlabel('Tempo [s]', ...
    'Color', fg);

ylabel('\delta\omega / \delta\omega_r', ...
    'Color', fg);

legend('k_\omega = 5', ...
       sprintf('k_\\omega = k_{\\omega,min} = %.2f', kw_min_31), ...
       'k_\omega = 20', ...
       'k_\omega = 30', ...
       'Referência', ...
       'Limite T_s^{20\%}=0.3 s', ...
       'TextColor', fg, ...
       'Color', bg, ...
       'EdgeColor', fg, ...
       'Location', 'southeast');

xlim([0 1.2]);
ylim([0 1.05]);

exportgraphics(gcf, ...
    fullfile(outDir,'Fig32_Step_P.png'), ...
    'BackgroundColor', bg, ...
    'Resolution', 300);


% =============================================================
% Guardar resultados da questão 3.1
% =============================================================

save('Lab2_resultados_31.mat', ...
     'k0', 'a', 'G', ...
     'Ts_req_31', 'tol_31', ...
     'p_min_31', 'kw_min_31', 'kw_31');

fprintf('\n============================================\n');
fprintf('FIGURAS EXPORTADAS\n');
fprintf('============================================\n');
fprintf('Fig31_RootLocus_P.png\n');
fprintf('Fig32_Step_P.png\n');

fprintf('\nResultados guardados em:\n');
fprintf('Lab2_resultados_31.mat\n');


%% ============================================================
%  3.2 - CONTROLO INTEGRAL DA VELOCIDADE
%
%  Controlador:
%       K(s) = k_i/s
%
%  Objetivo:
%       Determinar o valor máximo de k_i tal que a resposta
%       ao degrau em malha fechada não apresenta overshoot.
%
%       Verificar se é possível cumprir o requisito da 3.1:
%           Ts_20 < 0.3 s
% =============================================================

% Garantir que o modelo existe
if ~exist('G','var')
    k0 = 0.0911;
    a  = 2.1119;
    G = tf(k0*a,[1 a]);
end

if ~exist('outDir','var')
    outDir = fullfile(pwd,'Image');
    if ~exist(outDir,'dir')
        mkdir(outDir);
    end
end

if ~exist('bg','var')
    bg    = [0 0 0];
    fg    = [1 1 1];
    gridc = [0.45 0.45 0.45];

    c_blue   = [0.20 0.60 1.00];
    c_orange = [1.00 0.55 0.10];
    c_green  = [0.20 0.90 0.35];
    c_yellow = [1.00 0.85 0.10];
    c_red    = [1.00 0.25 0.25];
    c_gray   = [0.70 0.70 0.70];
end

% ===============================
% Controlador integral
% ===============================

s = tf('s');

% Malha aberta sem o ganho k_i:
%       L_i(s) = G(s)/s
L_i = G/s;

% Coeficiente do numerador da planta
b = k0*a;

% Condição de não haver overshoot:
%       s^2 + a s + b k_i
%
% No limite criticamente amortecido:
%       a^2 - 4 b k_i = 0
%
ki_max_32 = a^2/(4*b);

fprintf('\n============================================\n');
fprintf('3.2 - CONTROLO INTEGRAL\n');
fprintf('============================================\n');
fprintf('k_i,max sem overshoot = %.4f\n', ki_max_32);

% Ganhos para comparação
ki_32 = [1, ki_max_32, 8, 12];

% =============================================================
% Figura 33 - Lugar das raízes para controlo integral
% =============================================================

figure(33); clf;
set(gcf,'Color',bg,'InvertHardcopy','off');
hold on;

% Obter polos pelo rlocus()
ki_rl = linspace(0,20,800);
r_rl = rlocus(L_i,ki_rl);

% Dois ramos do lugar das raízes
plot(real(r_rl(1,:)), imag(r_rl(1,:)), ...
    'Color', c_blue, ...
    'LineWidth', 2.0);

plot(real(r_rl(2,:)), imag(r_rl(2,:)), ...
    'Color', c_orange, ...
    'LineWidth', 2.0);

% Polos iniciais: s = 0 e s = -a
plot([0 -a],[0 0],'x', ...
    'Color', c_yellow, ...
    'MarkerSize', 8, ...
    'LineWidth',1.8);

% Limite sem overshoot: polos reais coincidentes em s = -a/2
p_crit_32 = -a/2;

plot(p_crit_32,0,'o', ...
    'MarkerEdgeColor', c_red, ...
    'MarkerFaceColor', bg, ...
    'MarkerSize', 9, ...
    'LineWidth',2.0);

grid on;

ax = gca;
ax.Color = bg;
ax.XColor = fg;
ax.YColor = fg;
ax.GridColor = gridc;
ax.GridAlpha = 0.35;
ax.FontSize = 10;

title('Lugar das raízes com controlo integral', ...
    'Color', fg, ...
    'FontWeight','bold');

xlabel('Eixo real', ...
    'Color', fg);

ylabel('Eixo imaginário', ...
    'Color', fg);

legend('Ramo 1', ...
       'Ramo 2', ...
       'Polos iniciais', ...
       'Limite sem overshoot', ...
       'TextColor', fg, ...
       'Color', bg, ...
       'EdgeColor', fg, ...
       'Location','northeast');

xlim([-3 1]);
ylim([-2 2]);

disableDefaultInteractivity(gca)

exportgraphics(gcf, ...
    fullfile(outDir,'Fig33_RootLocus_I.png'), ...
    'BackgroundColor', bg, ...
    'Resolution', 300);


% ============================================================
% Figura 34 - Resposta ao degrau para diferentes k_i
% ============================================================

figure(34); clf;
set(gcf,'Color',bg,'InvertHardcopy','off');
hold on;

t = linspace(0,8,2000);

colors_32 = {c_blue, c_orange, c_green, c_red};
widths_32 = [1.8 2.0 1.8 1.8];

fprintf('\nResultados das respostas ao degrau:\n');

for i = 1:length(ki_32)

    ki = ki_32(i);

    T_32 = feedback(ki*L_i,1);

    [y,tout] = step(T_32,t);

    plot(tout,y, ...
        'Color', colors_32{i}, ...
        'LineWidth', widths_32(i));

    info_32 = stepinfo(T_32, ...
        'SettlingTimeThreshold', 0.20);

    fprintf('\n k_i = %.4f\n', ki);
    fprintf('  Ts_20       = %.4f s\n', info_32.SettlingTime);
    fprintf('  Overshoot   = %.2f %%\n', info_32.Overshoot);
    fprintf('  Valor final = %.4f\n', dcgain(T_32));

end

% Referência unitária
yline(1,'-', ...
    'Color', c_gray, ...
    'LineWidth',1.2);

% Requisito temporal da 3.1
xline(0.3,'--', ...
    'Color', c_red, ...
    'LineWidth',1.4);

grid on;

ax = gca;
ax.Color = bg;
ax.XColor = fg;
ax.YColor = fg;
ax.GridColor = gridc;
ax.GridAlpha = 0.35;
ax.FontSize = 10;

title('Resposta ao degrau em malha fechada com controlo integral', ...
    'Color', fg, ...
    'FontWeight','bold');

xlabel('Tempo [s]', ...
    'Color', fg);

ylabel('\delta\omega / \delta\omega_r', ...
    'Color', fg);

legend('k_i = 1', ...
       sprintf('k_i = k_{i,max} = %.2f', ki_max_32), ...
       'k_i = 8', ...
       'k_i = 12', ...
       'Referência', ...
       'Limite T_s^{20\%}=0.3 s', ...
       'TextColor', fg, ...
       'Color', bg, ...
       'EdgeColor', fg, ...
       'Location','southeast');

xlim([0 8]);
ylim([0 1.8]);

disableDefaultInteractivity(gca)

exportgraphics(gcf, ...
    fullfile(outDir,'Fig34_Step_I.png'), ...
    'BackgroundColor', bg, ...
    'Resolution', 300);


% ============================================================
% Guardar resultados da questão 3.2
% ============================================================

save('Lab2_resultados_32.mat', ...
     'k0', 'a', 'G', 'L_i', ...
     'ki_max_32', 'ki_32');

fprintf('\n============================================\n');
fprintf('FIGURAS EXPORTADAS\n');
fprintf('============================================\n');
fprintf('Fig33_RootLocus_I.png\n');
fprintf('Fig34_Step_I.png\n');

fprintf('\nResultados guardados em:\n');
fprintf('Lab2_resultados_32.mat\n');


%% =============================================================
%  3.3 - CONTROLO PI DA VELOCIDADE
%
%  Controlador:
%       K(s) = k_w + k_i/s
%            = k_w*(s+z)/s
%
%  com:
%       z = k_i/k_w
%
%  Objetivo:
%       Usar o lugar das raízes para escolher um controlador PI
%       que satisfaça o requisito:
%
%           Ts_20 < 0.3 s
%
%       tendo em conta a presença do zero introduzido pelo PI.
% ============================================================

% Garantir que o modelo existe
if ~exist('G','var')
    k0 = 0.0911;
    a  = 2.1119;
    G = tf(k0*a,[1 a]);
end

if ~exist('outDir','var')
    outDir = fullfile(pwd,'Image');
    if ~exist(outDir,'dir')
        mkdir(outDir);
    end
end

if ~exist('bg','var')
    bg    = [0 0 0];
    fg    = [1 1 1];
    gridc = [0.45 0.45 0.45];

    c_blue   = [0.20 0.60 1.00];
    c_orange = [1.00 0.55 0.10];
    c_green  = [0.20 0.90 0.35];
    c_yellow = [1.00 0.85 0.10];
    c_red    = [1.00 0.25 0.25];
    c_gray   = [0.70 0.70 0.70];
end

s = tf('s');

% Parâmetro escolhido para o zero do PI
z_33 = 2;

% Controlador PI escrito como:
%       K(s) = k_w*(s+z)/s
%
% Para o root locus, varia-se k_w.
L_PI_base = ((s + z_33)/s)*G;

% Ganho escolhido
kw_PI_33 = 30;
ki_PI_33 = kw_PI_33*z_33;

K_PI_33 = kw_PI_33 + ki_PI_33/s;
T_PI_33 = feedback(K_PI_33*G,1);

info_PI_33 = stepinfo(T_PI_33, ...
    'SettlingTimeThreshold',0.20);

fprintf('\n============================================\n');
fprintf('3.3 - CONTROLO PI\n');
fprintf('============================================\n');
fprintf('Zero escolhido: z = %.4f\n', z_33);
fprintf('k_w escolhido  = %.4f\n', kw_PI_33);
fprintf('k_i escolhido  = %.4f\n', ki_PI_33);
fprintf('Ts_20          = %.4f s\n', info_PI_33.SettlingTime);
fprintf('Overshoot      = %.2f %%\n', info_PI_33.Overshoot);
fprintf('Valor final    = %.4f\n', dcgain(T_PI_33));

% ============================================================
% Figura 35 - Lugar das raízes para controlo PI
% ============================================================

figure(35); clf;
set(gcf,'Color',bg,'InvertHardcopy','off');
hold on;

% Lugar das raízes variando k_w
kw_rl = linspace(0,80,800);
r_rl = rlocus(L_PI_base,kw_rl);

% Ramos do lugar das raízes
plot(real(r_rl(1,:)), imag(r_rl(1,:)), ...
    'Color', c_blue, ...
    'LineWidth', 2.0);

plot(real(r_rl(2,:)), imag(r_rl(2,:)), ...
    'Color', c_orange, ...
    'LineWidth', 2.0);

% Polos iniciais: s = 0 e s = -a
plot([0 -a],[0 0],'x', ...
    'Color', c_yellow, ...
    'MarkerSize', 9, ...
    'LineWidth',2.0);

% Zero do PI: s = -z
plot(-z_33,0,'o', ...
    'MarkerEdgeColor', c_green, ...
    'MarkerFaceColor', bg, ...
    'MarkerSize', 9, ...
    'LineWidth',2.0);

% Polos de malha fechada para o ganho escolhido
p_PI_33 = pole(T_PI_33);

plot(real(p_PI_33), imag(p_PI_33),'o', ...
    'MarkerEdgeColor', c_red, ...
    'MarkerFaceColor', bg, ...
    'MarkerSize', 9, ...
    'LineWidth',2.2);

% Linha auxiliar: requisito temporal Ts20 < 0.3 s
p_min_31 = -log(0.2)/0.3;
xline(-p_min_31,'--', ...
    'Color', c_red, ...
    'LineWidth',1.4);

grid on;

ax = gca;
ax.Color = bg;
ax.XColor = fg;
ax.YColor = fg;
ax.GridColor = gridc;
ax.GridAlpha = 0.35;
ax.FontSize = 10;

% Remover toolbar da exportação
disableDefaultInteractivity(ax);
ax.Toolbar.Visible = 'off';

title('Lugar das raízes com controlo PI', ...
    'Color', fg, ...
    'FontWeight','bold');

xlabel('Eixo real', ...
    'Color', fg);

ylabel('Eixo imaginário', ...
    'Color', fg);

legend('Ramo 1', ...
       'Ramo 2', ...
       'Polos iniciais', ...
       'Zero do PI', ...
       'Polos escolhidos', ...
       'Limite T_s^{20\%}=0.3 s', ...
       'TextColor', fg, ...
       'Color', bg, ...
       'EdgeColor', fg, ...
       'Location','northwest');

% Zoom na zona relevante
xlim([-7 0.5]);
ylim([-0.8 0.8]);

exportgraphics(gcf, ...
    fullfile(outDir,'Fig35_RootLocus_PI.png'), ...
    'BackgroundColor', bg, ...
    'Resolution', 300);


% ============================================================
% Figura 36 - Comparação P, I e PI
% ============================================================

figure(36); clf;
set(gcf,'Color',bg,'InvertHardcopy','off');
hold on;

t = linspace(0,4,2000);

% Controladores para comparação
K_P_36  = 30;
K_I_36  = ki_max_32/s;
K_PI_36 = kw_PI_33 + ki_PI_33/s;

T_P_36  = feedback(K_P_36*G,1);
T_I_36  = feedback(K_I_36*G,1);
T_PI_36 = feedback(K_PI_36*G,1);

[yP,tP]   = step(T_P_36,t);
[yI,tI]   = step(T_I_36,t);
[yPI,tPI] = step(T_PI_36,t);

plot(tP,yP, ...
    'Color', c_blue, ...
    'LineWidth',1.8);

plot(tI,yI, ...
    'Color', c_orange, ...
    'LineWidth',1.8);

plot(tPI,yPI, ...
    'Color', c_green, ...
    'LineWidth',2.0);

% Referência unitária
yline(1,'-', ...
    'Color', c_gray, ...
    'LineWidth',1.2);

% Limite temporal
xline(0.3,'--', ...
    'Color', c_red, ...
    'LineWidth',1.4);

grid on;

ax = gca;
ax.Color = bg;
ax.XColor = fg;
ax.YColor = fg;
ax.GridColor = gridc;
ax.GridAlpha = 0.35;
ax.FontSize = 10;

title('Comparação das respostas em malha fechada', ...
    'Color', fg, ...
    'FontWeight','bold');

xlabel('Tempo [s]', ...
    'Color', fg);

ylabel('\delta\omega / \delta\omega_r', ...
    'Color', fg);

legend('P: k_\omega=30', ...
       sprintf('I: k_i=%.2f', ki_max_32), ...
       sprintf('PI: k_\\omega=%.0f, k_i=%.0f', kw_PI_33, ki_PI_33), ...
       'Referência', ...
       'Limite T_s^{20\%}=0.3 s', ...
       'TextColor', fg, ...
       'Color', bg, ...
       'EdgeColor', fg, ...
       'Location','southeast');

xlim([0 4]);
ylim([0 1.25]);

disableDefaultInteractivity(gca)

exportgraphics(gcf, ...
    fullfile(outDir,'Fig36_Comparacao_P_I_PI.png'), ...
    'BackgroundColor', bg, ...
    'Resolution', 300);


% ============================================================
% Guardar resultados da questão 3.3
% ============================================================

save('Lab2_resultados_33.mat', ...
     'k0', 'a', 'G', ...
     'z_33', 'kw_PI_33', 'ki_PI_33', ...
     'K_PI_33', 'T_PI_33', 'info_PI_33');

fprintf('\n============================================\n');
fprintf('FIGURAS EXPORTADAS\n');
fprintf('============================================\n');
fprintf('Fig35_RootLocus_PI.png\n');
fprintf('Fig36_Comparacao_P_I_PI.png\n');

fprintf('\nResultados guardados em:\n');
fprintf('Lab2_resultados_33.mat\n');

%% ============================================================
%  3.4 - AQUISIÇÃO EXPERIMENTAL SEGURA
%
%  Velocity Control - implementação experimental dos controladores
%  P, I e PI projetados nas Secções 3.1, 3.2 e 3.3
%
%  O guia pede correr experiências com os parâmetros k_w e k_i
%  desenhados em 3.1, 3.2 e 3.3:
%
%       data = run_experiment(4,k_w,k_i)
%
%  Neste trabalho usa-se:
%
%       run_experiment_Matlab2023(4,k_w,k_i)
%
%  Regras deste bloco:
%       - faz checkup do sistema
%       - pergunta ensaio a ensaio
%       - nunca sobrescreve dados sem confirmação
%       - guarda um ficheiro .mat por ensaio
%       - cria ficheiro geral no fim
%       - prepara os dados para a análise da 3.5 e 3.6
% =============================================================

fprintf('\n============================================\n');
fprintf('3.4 - CHECKUP E AQUISIÇÃO EXPERIMENTAL\n');
fprintf('============================================\n');


% ------------------------------------------------------------

% Resolve the project directory from this script so the project is portable.
projectDir = fileparts(mfilename('fullpath'));

if ~isfolder(projectDir)
    error('A pasta projectDir não existe. Corrige o caminho no início do bloco 3.4.');
end

cd(projectDir);
fprintf('\nPasta atual definida para:\n%s\n', pwd);

% ------------------------------------------------------------
% Pastas de saída
% ------------------------------------------------------------

outDir  = fullfile(pwd,'Image');
dataDir = fullfile(pwd,'Data');

if ~exist(outDir,'dir')
    mkdir(outDir);
end

if ~exist(dataDir,'dir')
    mkdir(dataDir);
end

fprintf('\nPasta de figuras: %s\n', outDir);
fprintf('Pasta de dados:   %s\n', dataDir);

% ------------------------------------------------------------
% Configuração da saturação do atuador
% ------------------------------------------------------------
%
% NOTA PARA O LABORATÓRIO!!!!!!!
% Se o professor indicar um valor diferente para a saturação
% do sinal de atuação u(t), alterar aqui.
%
% Exemplo, se for confirmado que u(t) está limitado a [-250,250]:
%
%       sat_known = true;
%       u_sat = 250;
%
% Se o limite não for confirmado, manter sat_known = false.
% Nesse caso, a análise usa apenas os extremos observados
% experimentalmente.
% ------------------------------------------------------------

sat_known = false;
u_sat = NaN;

% ------------------------------------------------------------
% Checkup de funções necessárias
% ------------------------------------------------------------

fprintf('\n--- Checkup de ficheiros/funções ---\n');

if exist('run_experiment_Matlab2023','file') == 2
    fprintf('[OK] run_experiment_Matlab2023 encontrado:\n%s\n', ...
        which('run_experiment_Matlab2023'));
else
    error(['run_experiment_Matlab2023.m não foi encontrado. ', ...
           'Coloca o ficheiro na pasta atual ou no path do MATLAB.']);
end

if exist('plot_experiment_results','file') == 2
    fprintf('[OK] plot_experiment_results encontrado:\n%s\n', ...
        which('plot_experiment_results'));
else
    error(['plot_experiment_results.m não foi encontrado. ', ...
           'Coloca o ficheiro na pasta atual ou no path do MATLAB.']);
end

if exist('tf','file') == 2 && exist('stepinfo','file') == 2
    fprintf('[OK] Funções da Control System Toolbox disponíveis.\n');
else
    warning('Control System Toolbox pode não estar disponível.');
end

try
    portas = serialportlist("available");
    fprintf('\nPortas série disponíveis:\n');
    disp(portas(:));
catch
    warning('Não foi possível listar portas série. Confirmar ligação USB no laboratório.');
end

% ------------------------------------------------------------
% Garantir modelo identificado
% ------------------------------------------------------------

if ~exist('G','var')
    k0 = 0.0911;
    a  = 2.1119;
    G = tf(k0*a,[1 a]);
end

s = tf('s');

% ------------------------------------------------------------
% Ensaios a realizar/carregar
% ------------------------------------------------------------

ensaios = struct([]);

ensaios(1).label     = 'P';
ensaios(1).desc      = 'Controlo proporcional';
ensaios(1).kw        = 30;
ensaios(1).ki        = 0;
ensaios(1).varName   = 'data_P_kw30_ki0';
ensaios(1).fileName  = 'Lab2_data_P_kw30_ki0.mat';
ensaios(1).mandatory = true;

ensaios(2).label     = 'I';
ensaios(2).desc      = 'Controlo integral';
ensaios(2).kw        = 0;
ensaios(2).ki        = 5.7956;
ensaios(2).varName   = 'data_I_kw0_ki57956';
ensaios(2).fileName  = 'Lab2_data_I_kw0_ki57956.mat';
ensaios(2).mandatory = true;

ensaios(3).label     = 'PI';
ensaios(3).desc      = 'Controlo PI principal';
ensaios(3).kw        = 30;
ensaios(3).ki        = 60;
ensaios(3).varName   = 'data_PI_kw30_ki60';
ensaios(3).fileName  = 'Lab2_data_PI_kw30_ki60.mat';
ensaios(3).mandatory = true;

ensaios(4).label     = 'PI_cons';
ensaios(4).desc      = 'Controlo PI conservador';
ensaios(4).kw        = 20;
ensaios(4).ki        = 40;
ensaios(4).varName   = 'data_PI_kw20_ki40';
ensaios(4).fileName  = 'Lab2_data_PI_kw20_ki40.mat';
ensaios(4).mandatory = false;

fprintf('\n--- Ensaios definidos ---\n');
for i = 1:numel(ensaios)
    if ensaios(i).mandatory
        tipo = 'obrigatório';
    else
        tipo = 'opcional';
    end

    fprintf('%s: %s | k_w = %.4f | k_i = %.4f | %s\n', ...
        ensaios(i).label, ensaios(i).desc, ...
        ensaios(i).kw, ensaios(i).ki, tipo);
end

% Estrutura agregadora
dataAll = struct();
ensaios_disponiveis = {};

% ------------------------------------------------------------
% Loop ensaio a ensaio
% ------------------------------------------------------------

for i = 1:numel(ensaios)

    fprintf('\n============================================\n');
    fprintf('ENSAIO %s - %s\n', ensaios(i).label, ensaios(i).desc);
    fprintf('k_w = %.4f | k_i = %.4f\n', ensaios(i).kw, ensaios(i).ki);
    fprintf('============================================\n');

    ficheiro_individual = fullfile(dataDir, ensaios(i).fileName);

    if exist(ficheiro_individual,'file')
        fprintf('Já existe ficheiro para este ensaio:\n%s\n', ficheiro_individual);
    else
        fprintf('Ainda não existe ficheiro guardado para este ensaio.\n');
    end

    resposta = input('Queres correr este ensaio experimental agora? (s/n): ','s');
    resposta = lower(strtrim(resposta));

    correrAgora = strcmp(resposta,'s') || strcmp(resposta,'sim') || ...
                  strcmp(resposta,'y') || strcmp(resposta,'yes');

    if correrAgora

        podeCorrer = true;

        if exist(ficheiro_individual,'file')
            respOverwrite = input('O ficheiro já existe. Queres sobrescrever? (s/n): ','s');
            respOverwrite = lower(strtrim(respOverwrite));

            overwriteOK = strcmp(respOverwrite,'s') || strcmp(respOverwrite,'sim') || ...
                          strcmp(respOverwrite,'y') || strcmp(respOverwrite,'yes');

            if ~overwriteOK
                podeCorrer = false;
                fprintf('Não vai ser sobrescrito. Vou tentar carregar os dados existentes.\n');
            end
        end

        if podeCorrer
            fprintf('\nA correr experiência real...\n');
            fprintf('run_experiment_Matlab2023(4, %.4f, %.4f)\n', ...
                ensaios(i).kw, ensaios(i).ki);

            try
                data_exp = run_experiment_Matlab2023(4, ensaios(i).kw, ensaios(i).ki);

                try
                    data_exp = plot_experiment_results(data_exp);
                catch MEplot
                    warning('plot_experiment_results falhou: %s', MEplot.message);
                    warning('Os dados brutos serão guardados na mesma.');
                end

                ensaio_info = ensaios(i);

                save(ficheiro_individual, 'data_exp', 'ensaio_info');

                fprintf('[OK] Dados guardados em:\n%s\n', ficheiro_individual);

                dataAll.(ensaios(i).varName) = data_exp;
                ensaios_disponiveis{end+1} = ensaios(i).varName;

            catch MEexp
                warning('Falha ao correr o ensaio %s: %s', ...
                    ensaios(i).label, MEexp.message);

                if exist(ficheiro_individual,'file')
                    fprintf('Vou tentar carregar os dados antigos deste ensaio.\n');

                    S = load(ficheiro_individual);
                    if isfield(S,'data_exp')
                        dataAll.(ensaios(i).varName) = S.data_exp;
                        ensaios_disponiveis{end+1} = ensaios(i).varName;
                        fprintf('[OK] Dados antigos carregados.\n');
                    else
                        warning('O ficheiro existe, mas não contém data_exp.');
                    end
                else
                    warning('Não existem dados antigos para carregar.');
                end
            end
        end
    end

    % Se não correu agora, tentar carregar dados existentes
    if ~isfield(dataAll, ensaios(i).varName)

        if exist(ficheiro_individual,'file')
            fprintf('A carregar dados guardados para %s...\n', ensaios(i).label);

            S = load(ficheiro_individual);

            if isfield(S,'data_exp')
                dataAll.(ensaios(i).varName) = S.data_exp;
                ensaios_disponiveis{end+1} = ensaios(i).varName;
                fprintf('[OK] Dados carregados.\n');
            else
                warning('Ficheiro encontrado, mas não contém variável data_exp.');
            end

        else
            warning('Não existem dados guardados para o ensaio %s.', ensaios(i).label);
        end
    end
end

% ------------------------------------------------------------
% Guardar ficheiro geral
% ------------------------------------------------------------

ficheiro_geral_34 = fullfile(dataDir,'Lab2_dados_34_todos.mat');

if ~isempty(fieldnames(dataAll))
    save(ficheiro_geral_34, ...
        'dataAll', 'ensaios', 'ensaios_disponiveis', ...
        'sat_known', 'u_sat');

    fprintf('\n============================================\n');
    fprintf('FICHEIRO GERAL GUARDADO\n');
    fprintf('============================================\n');
    fprintf('%s\n', ficheiro_geral_34);
else
    warning('Nenhum dado experimental disponível. Ficheiro geral não foi criado.');
end


%% ============================================================
%  3.5 - ANÁLISE DOS DADOS EXPERIMENTAIS
%
%  Este bloco usa os dados disponíveis da 3.4 para:
%       - calcular métricas experimentais
%       - analisar sinal de atuação
%       - comparar respostas reais entre controladores
%       - comparar PI real com PI simulado
% =============================================================

fprintf('\n============================================\n');
fprintf('3.5 - ANÁLISE EXPERIMENTAL\n');
fprintf('============================================\n');

if isempty(fieldnames(dataAll))
    warning('Não há dados experimentais disponíveis. A análise 3.5 não será realizada.');
else

    % --------------------------------------------------------
    % Calcular métricas
    % --------------------------------------------------------

    metrics = struct([]);

    for i = 1:numel(ensaios)

        varName = ensaios(i).varName;

        if ~isfield(dataAll,varName)
            continue;
        end

        data_exp = dataAll.(varName);

        m = struct();

        m.Ensaio = string(ensaios(i).label);
        m.Descricao = string(ensaios(i).desc);
        m.k_w = ensaios(i).kw;
        m.k_i = ensaios(i).ki;

        % Valores por defeito
        m.Ts20 = NaN;
        m.Overshoot = NaN;
        m.PeakTime = NaN;
        m.ValorFinal = NaN;
        m.ErroEstacionario = NaN;

        m.u_min = NaN;
        m.u_max = NaN;
        m.u_pp = NaN;
        m.u_std = NaN;

        m.frac_sat_pos = NaN;
        m.frac_sat_neg = NaN;
        m.possivel_limitacao = false;

        % Métricas da resposta normalizada
        if isfield(data_exp,'t_unit_step') && isfield(data_exp,'y_unit_step')

            t_unit = data_exp.t_unit_step(:);
            y_unit = data_exp.y_unit_step(:);

            idxValid = isfinite(t_unit) & isfinite(y_unit);
            t_unit = t_unit(idxValid);
            y_unit = y_unit(idxValid);

            if numel(t_unit) > 10

                nTail = max(5, round(0.10*numel(y_unit)));
                yFinal = mean(y_unit(end-nTail+1:end));

                try
                    info_exp = stepinfo(y_unit, t_unit, yFinal, ...
                        'SettlingTimeThreshold', 0.20);

                    m.Ts20 = info_exp.SettlingTime;
                    m.Overshoot = info_exp.Overshoot;
                    m.PeakTime = info_exp.PeakTime;
                catch MEinfo
                    warning('stepinfo falhou no ensaio %s: %s', ...
                        ensaios(i).label, MEinfo.message);
                end

                m.ValorFinal = yFinal;
                m.ErroEstacionario = 1 - yFinal;
            else
                warning('Dados t_unit_step/y_unit_step insuficientes no ensaio %s.', ...
                    ensaios(i).label);
            end

        else
            warning(['O ensaio %s não contém t_unit_step/y_unit_step. ', ...
                     'Corre plot_experiment_results(data) para gerar estes campos.'], ...
                     ensaios(i).label);
        end

        % Métricas do sinal de atuação
        if isfield(data_exp,'u')

            u = data_exp.u(:);
            u = u(isfinite(u));

            if ~isempty(u)

                m.u_min = min(u);
                m.u_max = max(u);
                m.u_pp  = m.u_max - m.u_min;
                m.u_std = std(u);

                if sat_known && isfinite(u_sat)

                    m.frac_sat_pos = mean(u >= 0.98*u_sat);
                    m.frac_sat_neg = mean(u <= -0.98*u_sat);

                    m.possivel_limitacao = ...
                        (m.frac_sat_pos > 0.05) || ...
                        (m.frac_sat_neg > 0.05);

                else

                    if m.u_pp > eps
                        tol_ext = 0.02; % 2% da gama observada

                        m.frac_sat_pos = mean(u > m.u_max - tol_ext*m.u_pp);
                        m.frac_sat_neg = mean(u < m.u_min + tol_ext*m.u_pp);

                        m.possivel_limitacao = ...
                            (m.frac_sat_pos > 0.05) || ...
                            (m.frac_sat_neg > 0.05);
                    end
                end
            end
        else
            warning('O ensaio %s não contém campo data.u.', ensaios(i).label);
        end

        % Guardar métricas, garantindo compatibilidade entre estruturas
if isempty(metrics)
    metrics = m;
else
    % Garantir que m tem os mesmos campos de metrics
    campos_metrics = fieldnames(metrics);
    campos_m = fieldnames(m);

    % Campos que existem em metrics mas não existem em m
    campos_faltam_m = setdiff(campos_metrics, campos_m);
    for kk = 1:numel(campos_faltam_m)
        m.(campos_faltam_m{kk}) = NaN;
    end

    % Campos que existem em m mas ainda não existem em metrics
    campos_novos = setdiff(campos_m, campos_metrics);
    for kk = 1:numel(campos_novos)
        [metrics.(campos_novos{kk})] = deal(NaN);
    end

    % Reordenar campos para ficarem iguais
    m = orderfields(m, metrics);

    % Adicionar nova linha de métricas
    metrics(end+1) = m; 
end
    end

    if ~isempty(metrics)
        metricsTable = struct2table(metrics);

        fprintf('\n--- Métricas experimentais ---\n');
        disp(metricsTable);

        ficheiro_metricas_34 = fullfile(dataDir,'Lab2_metricas_34.mat');
        save(ficheiro_metricas_34, ...
            'metrics', 'metricsTable', ...
            'sat_known', 'u_sat');

        fprintf('\nMétricas guardadas em:\n%s\n', ficheiro_metricas_34);
    else
        warning('Não foram calculadas métricas experimentais.');
    end

    % --------------------------------------------------------
    % Estilo gráfico
    % --------------------------------------------------------

    if ~exist('bg','var')
        bg    = [0 0 0];
        fg    = [1 1 1];
        gridc = [0.45 0.45 0.45];

        c_blue   = [0.20 0.60 1.00];
        c_orange = [1.00 0.55 0.10];
        c_green  = [0.20 0.90 0.35];
        c_yellow = [1.00 0.85 0.10];
        c_red    = [1.00 0.25 0.25];
        c_gray   = [0.70 0.70 0.70];
    end

    colors_exp = {c_blue, c_orange, c_green, c_yellow};

    % --------------------------------------------------------
    % Figura 37 - Comparação experimental das respostas
    % --------------------------------------------------------

    figure(37); clf;
    set(gcf,'Color',bg,'InvertHardcopy','off');
    hold on;

    legendEntries = {};
    plottedAny = false;

    for i = 1:numel(ensaios)

        varName = ensaios(i).varName;

        if ~isfield(dataAll,varName)
            continue;
        end

        data_exp = dataAll.(varName);

        if isfield(data_exp,'t_unit_step') && isfield(data_exp,'y_unit_step')

            t_unit = data_exp.t_unit_step(:);
            y_unit = data_exp.y_unit_step(:);

            idxValid = isfinite(t_unit) & isfinite(y_unit);
            t_unit = t_unit(idxValid);
            y_unit = y_unit(idxValid);

            if numel(t_unit) > 10
                plot(t_unit, y_unit, ...
                    'Color', colors_exp{min(i,numel(colors_exp))}, ...
                    'LineWidth', 1.9);

                legendEntries{end+1} = sprintf('%s: k_\\omega=%.2g, k_i=%.2g', ...
                    ensaios(i).label, ensaios(i).kw, ensaios(i).ki);

                plottedAny = true;
            end
        end
    end

    if plottedAny

        yline(1,'-', ...
            'Color', c_gray, ...
            'LineWidth',1.2);

        xline(0.3,'--', ...
            'Color', c_red, ...
            'LineWidth',1.4);

        legendEntries{end+1} = 'Referência';
        legendEntries{end+1} = 'Limite T_s^{20\%}=0.3 s';

        grid on;

        ax = gca;
        ax.Color = bg;
        ax.XColor = fg;
        ax.YColor = fg;
        ax.GridColor = gridc;
        ax.GridAlpha = 0.35;
        ax.FontSize = 10;

        disableDefaultInteractivity(ax);
        ax.Toolbar.Visible = 'off';

        title('Respostas experimentais em malha fechada', ...
            'Color', fg, ...
            'FontWeight','bold');

        xlabel('Tempo [s]', ...
            'Color', fg);

        ylabel('\delta\omega / \delta\omega_r', ...
            'Color', fg);

        legend(legendEntries, ...
            'TextColor', fg, ...
            'Color', bg, ...
            'EdgeColor', fg, ...
            'Location', 'southeast');

        xlim([0 8]);
        ylim([0 1.4]);

        exportgraphics(gcf, ...
            fullfile(outDir,'Fig37_Exp_Comparacao_Step_P_I_PI.png'), ...
            'BackgroundColor', bg, ...
            'Resolution', 300);

        fprintf('\nFigura exportada: Fig37_Exp_Comparacao_Step_P_I_PI.png\n');
    else
        warning('Não foi possível gerar a Figura 37: sem respostas unitárias experimentais.');
    end

    % --------------------------------------------------------
    % Figura 38 - Comparação do sinal de atuação
    % --------------------------------------------------------

    figure(38); clf;
    set(gcf,'Color',bg,'InvertHardcopy','off');
    hold on;

    legendEntries = {};
    plottedAny = false;

    for i = 1:numel(ensaios)

        varName = ensaios(i).varName;

        if ~isfield(dataAll,varName)
            continue;
        end

        data_exp = dataAll.(varName);

        if isfield(data_exp,'u')

            u = data_exp.u(:);

        
            if isfield(data_exp,'time')
                t_u = data_exp.time(:);
            elseif isfield(data_exp,'t')
                t_u = data_exp.t(:);
            else
                t_u = (0:numel(u)-1).';
            end

            n = min(numel(t_u), numel(u));
            t_u = t_u(1:n);
            u = u(1:n);

            idxValid = isfinite(t_u) & isfinite(u);
            t_u = t_u(idxValid);
            u = u(idxValid);

            if numel(t_u) > 10
                plot(t_u, u, ...
                    'Color', colors_exp{min(i,numel(colors_exp))}, ...
                    'LineWidth', 1.5);

                legendEntries{end+1} = sprintf('%s: k_\\omega=%.2g, k_i=%.2g', ...
                    ensaios(i).label, ensaios(i).kw, ensaios(i).ki);

                plottedAny = true;
            end
        end
    end

    if plottedAny

        if sat_known && isfinite(u_sat)
            yline(u_sat,'--', ...
                'Color', c_red, ...
                'LineWidth',1.2);

            yline(-u_sat,'--', ...
                'Color', c_red, ...
                'LineWidth',1.2);

            legendEntries{end+1} = '+u_{sat}';
            legendEntries{end+1} = '-u_{sat}';
        end

        grid on;

        ax = gca;
        ax.Color = bg;
        ax.XColor = fg;
        ax.YColor = fg;
        ax.GridColor = gridc;
        ax.GridAlpha = 0.35;
        ax.FontSize = 10;

        disableDefaultInteractivity(ax);
        ax.Toolbar.Visible = 'off';

        title('Sinal de atuação nos ensaios experimentais', ...
            'Color', fg, ...
            'FontWeight','bold');

        xlabel('Tempo [s]', ...
            'Color', fg);

        ylabel('u(t)', ...
            'Color', fg);

        legend(legendEntries, ...
            'TextColor', fg, ...
            'Color', bg, ...
            'EdgeColor', fg, ...
            'Location', 'best');

        exportgraphics(gcf, ...
            fullfile(outDir,'Fig38_Exp_Atuacao_P_I_PI.png'), ...
            'BackgroundColor', bg, ...
            'Resolution', 300);

        fprintf('Figura exportada: Fig38_Exp_Atuacao_P_I_PI.png\n');
    else
        warning('Não foi possível gerar a Figura 38: sem sinal de atuação data.u.');
    end

    % --------------------------------------------------------
    % Figura 39 - PI real vs PI simulado
    % --------------------------------------------------------

    if isfield(dataAll,'data_PI_kw30_ki60')

        data_PI_exp = dataAll.data_PI_kw30_ki60;

        if isfield(data_PI_exp,'t_unit_step') && isfield(data_PI_exp,'y_unit_step')

            t_exp = data_PI_exp.t_unit_step(:);
            y_exp = data_PI_exp.y_unit_step(:);

            idxValid = isfinite(t_exp) & isfinite(y_exp);
            t_exp = t_exp(idxValid);
            y_exp = y_exp(idxValid);

            if numel(t_exp) > 10

                K_PI_sim = 30 + 60/s;
                T_PI_sim = feedback(K_PI_sim*G,1);

                t_sim = linspace(0, max(t_exp), 2000);
                [y_sim,t_sim] = step(T_PI_sim,t_sim);

                figure(39); clf;
                set(gcf,'Color',bg,'InvertHardcopy','off');
                hold on;

                plot(t_exp,y_exp, ...
                    'Color', c_green, ...
                    'LineWidth', 1.9);

                plot(t_sim,y_sim, ...
                    '--', ...
                    'Color', c_yellow, ...
                    'LineWidth', 1.7);

                yline(1,'-', ...
                    'Color', c_gray, ...
                    'LineWidth',1.2);

                xline(0.3,'--', ...
                    'Color', c_red, ...
                    'LineWidth',1.4);

                grid on;

                ax = gca;
                ax.Color = bg;
                ax.XColor = fg;
                ax.YColor = fg;
                ax.GridColor = gridc;
                ax.GridAlpha = 0.35;
                ax.FontSize = 10;

                disableDefaultInteractivity(ax);
                ax.Toolbar.Visible = 'off';

                title('Comparação entre PI experimental e simulado', ...
                    'Color', fg, ...
                    'FontWeight','bold');

                xlabel('Tempo [s]', ...
                    'Color', fg);

                ylabel('\delta\omega / \delta\omega_r', ...
                    'Color', fg);

                legend('PI experimental: k_\omega=30, k_i=60', ...
                       'PI simulado', ...
                       'Referência', ...
                       'Limite T_s^{20\%}=0.3 s', ...
                       'TextColor', fg, ...
                       'Color', bg, ...
                       'EdgeColor', fg, ...
                       'Location', 'southeast');

                xlim([0 max(t_exp)]);
                ylim([0 1.4]);

                exportgraphics(gcf, ...
                    fullfile(outDir,'Fig39_Exp_vs_Sim_PI.png'), ...
                    'BackgroundColor', bg, ...
                    'Resolution', 300);

                fprintf('Figura exportada: Fig39_Exp_vs_Sim_PI.png\n');
            end
        else
            warning('Dados PI não têm t_unit_step/y_unit_step. Figura 39 não gerada.');
        end
    else
        warning('PI principal não disponível. Figura 39 não gerada.');
    end
end


%% ============================================================
%  3.6 - Figura efeito dos ganhos no PI
%
% =============================================================


%clearvars -except dataFolder imageFolder
%close all

if ~exist('dataFolder','var') || isempty(dataFolder)
    dataFolder = 'Data';
end
if ~exist('imageFolder','var') || isempty(imageFolder)
    imageFolder = 'Image';
end

filePI     = fullfile(dataFolder,'Lab2_data_PI_kw30_ki60.mat');
filePIred  = fullfile(dataFolder,'Lab2_data_PI_kw20_ki40.mat');

S1 = load(filePI);
S2 = load(filePIred);

fn1 = fieldnames(S1);
fn2 = fieldnames(S2);

D1 = S1.(fn1{1});
D2 = S2.(fn2{1});

if isfield(D1,'time')
    t1 = D1.time(:);
elseif isfield(D1,'t')
    t1 = D1.t(:);
else
    error('O ficheiro PI principal não tem campo de tempo time nem t.');
end
u1 = D1.u(:);
w1 = D1.vel(:);

if isfield(D2,'time')
    t2 = D2.time(:);
elseif isfield(D2,'t')
    t2 = D2.t(:);
else
    error('O ficheiro PI reduzido não tem campo de tempo time nem t.');
end
u2 = D2.u(:);
w2 = D2.vel(:);

tStep = 10;

idx01 = find(t1 < tStep, 1, 'last');
idx02 = find(t2 < tStep, 1, 'last');

w01 = mean(w1(max(1,idx01-200):idx01));
w02 = mean(w2(max(1,idx02-200):idx02));

wref1 = 15;
wref2 = 15;

dwref1 = wref1 - w01;
dwref2 = wref2 - w02;

y1 = (w1 - w01) / dwref1;
y2 = (w2 - w02) / dwref2;

idxStart1 = find(t1 >= tStep, 1, 'first');
idxStart2 = find(t2 >= tStep, 1, 'first');

t1n = t1(idxStart1:end) - tStep;
t2n = t2(idxStart2:end) - tStep;
y1n = y1(idxStart1:end);
y2n = y2(idxStart2:end);

Ts1 = 0.2314;
Ts2 = 0.3759;

umax1 = max(u1(idxStart1:end));
umax2 = max(u2(idxStart2:end));

cPI      = [0 0.4470 0.7410];
cPIred   = [1 0 0];
cRef     = [0.75 0.75 0.75];
cLimit   = [1 0.85 0];

fig = figure('Color','k','Position',[100 100 1400 900]);

sgtitle('Efeito da redução dos ganhos no controlador PI', ...
    'Color','w','FontWeight','bold','FontSize',22);

subplot(2,1,1)
hold on
plot(t1n, y1n, 'LineWidth', 2.5, 'Color', cPI)
plot(t2n, y2n, 'LineWidth', 2.5, 'Color', cPIred)
yline(1, '--', 'LineWidth', 1.8, 'Color', cRef)
xline(0.3, '--', 'LineWidth', 1.8, 'Color', cLimit)

title('Resposta experimental normalizada', ...
    'Color','w','FontWeight','bold','FontSize',18)
xlabel('Tempo após o degrau [s]', 'Color','w','FontSize',16)
ylabel('\delta\omega / \delta\omega_r', 'Color','w','FontSize',16)

legend({ ...
    sprintf('PI: k_\\omega=30, k_i=60, T_s^{20%%}=%.4f s', Ts1), ...
    sprintf('PI red.: k_\\omega=20, k_i=40, T_s^{20%%}=%.4f s', Ts2), ...
    'Referência', ...
    'Limite 0.3 s'}, ...
    'TextColor','w', 'Color','k', 'EdgeColor','w', ...
    'FontSize',14, 'Location','southeast')

set(gca, 'Color','k', 'XColor','w', 'YColor','w', 'FontSize',14, 'LineWidth',1.2)
grid on
xlim([0 2])

subplot(2,1,2)
hold on
plot(t1(idxStart1:end)-tStep, u1(idxStart1:end), 'LineWidth', 2.2, 'Color', cPI)
plot(t2(idxStart2:end)-tStep, u2(idxStart2:end), 'LineWidth', 2.2, 'Color', cPIred)
xline(0, '--', 'LineWidth', 1.8, 'Color', cRef)

title('Sinal de atuação experimental', ...
    'Color','w','FontWeight','bold','FontSize',18)
xlabel('Tempo após o degrau [s]', 'Color','w','FontSize',16)
ylabel('u(t)', 'Color','w','FontSize',16)

legend({ ...
    sprintf('PI: u_{max}=%.2f', umax1), ...
    sprintf('PI red.: u_{max}=%.2f', umax2), ...
    'Instante do degrau'}, ...
    'TextColor','w', 'Color','k', 'EdgeColor','w', ...
    'FontSize',14, 'Location','northeast')

set(gca, 'Color','k', 'XColor','w', 'YColor','w', 'FontSize',14, 'LineWidth',1.2)
grid on
xlim([0 6])

outFile = fullfile(imageFolder,'Fig40_Efeito_Ganhos_PI.png');
exportgraphics(fig, outFile, 'Resolution', 300);

fprintf('Figura exportada: %s\n', outFile);

%% ============================================================
%  4.1 - CONTROLO PD DA POSIÇÃO
%
%  Planta de posição:
%
%       G_theta(s) = G_omega(s)/s
%                  = k0*a / [s(s+a)]
%
%  Controlador PD:
%
%       K_PD(s) = k1 + k2*s
%               = k2*(s + k1/k2)
%
%  Objetivo:
%       Escolher k1 e k2 positivos, com k3 = 0,
%       tal que o tempo de estabelecimento a 30%% da resposta
%       ao degrau em malha fechada seja inferior a 0.2 s.
%
%  Nota:
%       Esta estrutura é equivalente ao PI da Secção 3.3,
%       com a troca:
%
%           k_w  -> k2
%           k_i  -> k1
%
% ============================================================

% Garantir modelo identificado
if ~exist('k0','var')
    k0 = 0.0911;
end

if ~exist('a','var')
    a = 2.1119;
end

if ~exist('outDir','var')
    outDir = fullfile(pwd,'Image');
    if ~exist(outDir,'dir')
        mkdir(outDir);
    end
end

if ~exist('bg','var')
    bg    = [0 0 0];
    fg    = [1 1 1];
    gridc = [0.45 0.45 0.45];

    c_blue   = [0.20 0.60 1.00];
    c_orange = [1.00 0.55 0.10];
    c_green  = [0.20 0.90 0.35];
    c_yellow = [1.00 0.85 0.10];
    c_red    = [1.00 0.25 0.25];
    c_gray   = [0.70 0.70 0.70];
end

s = tf('s');

% Coeficiente do numerador identificado
b = k0*a;

% Planta de velocidade identificada
G = b/(s+a);

% Planta de posição
Gtheta = G/s;

fprintf('\n============================================\n');
fprintf('4.1 - CONTROLO PD DA POSIÇÃO\n');
fprintf('============================================\n');
fprintf('k0 = %.4f\n', k0);
fprintf('a  = %.4f s^-1\n', a);
fprintf('b  = k0*a = %.4f\n', b);
fprintf('Gtheta(s) = %.4f/[s(s + %.4f)]\n', b, a);

% ============================================================
% Especificação da questão 4.1
% ============================================================

Ts_req_41 = 0.2;      % [s]
tol_41    = 0.30;     % critério de 30%

% Aproximação para localização mínima dos polos dominantes:
%
%       Ts_30 ≈ -ln(0.3)/sigma
%
sigma_min_41 = -log(tol_41)/Ts_req_41;

fprintf('\nEspecificação:\n');
fprintf('Ts_30 < %.3f s\n', Ts_req_41);
fprintf('sigma_min = %.4f\n', sigma_min_41);

% ============================================================
% Escolha do zero do PD
% ============================================================
%
% Pela equivalência com o PI da Secção 3.3:
%
%       K_PI(s) = k_w*(s + k_i/k_w)/s
%       K_PD(s) = k2*(s + k1/k2)
%
% Mantém-se o zero em s = -2:
%
%       k1/k2 = 2
%
% ============================================================

z_41 = 2;

% Malha aberta base para o lugar das raízes:
%
%
% O ganho variável do root locus é k2.
L_PD_base = (s + z_41)*Gtheta;

fprintf('\nZero escolhido:\n');
fprintf('z = k1/k2 = %.4f\n', z_41);
fprintf('Zero do controlador em s = -%.4f\n', z_41);

% ============================================================
% Ganhos candidatos
% ============================================================

k2_41 = [30 35 40 50];
k1_41 = z_41*k2_41;
k3_41 = zeros(size(k2_41));

% Vetores para resultados
Ts30_41      = zeros(size(k2_41));
Overshoot_41 = zeros(size(k2_41));
Final_41     = zeros(size(k2_41));
Poles_41     = cell(size(k2_41));

fprintf('\nResultados das respostas ao degrau:\n');

for i = 1:length(k2_41)

    k1 = k1_41(i);
    k2 = k2_41(i);

    K_PD = k1 + k2*s;
    T_PD = feedback(K_PD*Gtheta,1);

    info = stepinfo(T_PD, ...
        'SettlingTimeThreshold', tol_41);

    Ts30_41(i)       = info.SettlingTime;
    Overshoot_41(i)  = info.Overshoot;
    Final_41(i)      = dcgain(T_PD);
    Poles_41{i}      = pole(T_PD);

    fprintf('\n PD candidato %d\n', i);
    fprintf('  k1 = %.4f\n', k1);
    fprintf('  k2 = %.4f\n', k2);
    fprintf('  k3 = %.4f\n', 0);
    fprintf('  zero = %.4f\n', -k1/k2);
    fprintf('  Ts_30       = %.4f s\n', Ts30_41(i));
    fprintf('  Overshoot   = %.2f %%\n', Overshoot_41(i));
    fprintf('  Valor final = %.4f\n', Final_41(i));
    fprintf('  Polos:\n');
    disp(Poles_41{i});

end

% Escolher primeiro ganho que cumpre o requisito
idx_ok_41 = find(Ts30_41 < Ts_req_41, 1, 'first');

if isempty(idx_ok_41)
    warning('Nenhum dos ganhos candidatos cumpre Ts_30 < 0.2 s.');
    idx_sel_41 = length(k2_41);
else
    idx_sel_41 = idx_ok_41;
end

k1_PD_41 = k1_41(idx_sel_41);
k2_PD_41 = k2_41(idx_sel_41);
k3_PD_41 = 0;

K_PD_41 = k1_PD_41 + k2_PD_41*s;
T_PD_41 = feedback(K_PD_41*Gtheta,1);

info_PD_41 = stepinfo(T_PD_41, ...
    'SettlingTimeThreshold', tol_41);

fprintf('\nControlador PD selecionado:\n');
fprintf('k1 = %.4f\n', k1_PD_41);
fprintf('k2 = %.4f\n', k2_PD_41);
fprintf('k3 = %.4f\n', k3_PD_41);
fprintf('Ts_30 = %.4f s\n', info_PD_41.SettlingTime);
fprintf('Overshoot = %.2f %%\n', info_PD_41.Overshoot);
fprintf('Valor final = %.4f\n', dcgain(T_PD_41));

% ============================================================
% Figura 41 - Lugar das raízes do PD
% ============================================================

figure(41); clf;
set(gcf,'Color',bg,'InvertHardcopy','off');
hold on;

k_rl = linspace(0,80,1000);
r_rl = rlocus(L_PD_base,k_rl);

for r = 1:size(r_rl,1)
    plot(real(r_rl(r,:)), imag(r_rl(r,:)), ...
        'Color', c_blue, ...
        'LineWidth', 2.0);
end

% Polos iniciais da planta de posição: s = 0 e s = -a
plot([0 -a],[0 0],'x', ...
    'Color', c_yellow, ...
    'MarkerSize', 9, ...
    'LineWidth',2.0);

% Zero do PD
plot(-z_41,0,'o', ...
    'MarkerEdgeColor', c_green, ...
    'MarkerFaceColor', bg, ...
    'MarkerSize', 9, ...
    'LineWidth',2.0);

% Polos escolhidos
p_PD_41 = pole(T_PD_41);

plot(real(p_PD_41), imag(p_PD_41),'o', ...
    'MarkerEdgeColor', c_red, ...
    'MarkerFaceColor', bg, ...
    'MarkerSize', 9, ...
    'LineWidth',2.2);

% Linha do requisito temporal aproximado
xline(-sigma_min_41,'--', ...
    'Color', c_red, ...
    'LineWidth',1.4);

grid on;

ax = gca;
ax.Color = bg;
ax.XColor = fg;
ax.YColor = fg;
ax.GridColor = gridc;
ax.GridAlpha = 0.35;
ax.FontSize = 10;

disableDefaultInteractivity(ax);
ax.Toolbar.Visible = 'off';

title('Lugar das raízes com controlo PD da posição', ...
    'Color', fg, ...
    'FontWeight','bold');

xlabel('Eixo real', ...
    'Color', fg);

ylabel('Eixo imaginário', ...
    'Color', fg);

legend('Lugar das raízes', ...
       'Polos iniciais', ...
       'Zero do PD', ...
       'Polos escolhidos', ...
       'Limite T_s^{30\%}=0.2 s', ...
       'TextColor', fg, ...
       'Color', bg, ...
       'EdgeColor', fg, ...
       'Location','northwest');

xlim([-10 1]);
ylim([-4 4]);

exportgraphics(gcf, ...
    fullfile(outDir,'Fig41_RootLocus_PD_Posicao.png'), ...
    'BackgroundColor', bg, ...
    'Resolution', 300);

% ============================================================
% Figura 42 - Resposta ao degrau para ganhos candidatos
% ============================================================

figure(42); clf;
set(gcf,'Color',bg,'InvertHardcopy','off');
hold on;

t = linspace(0,1.2,2000);

colors_41 = {c_blue, c_orange, c_green, c_yellow};

for i = 1:length(k2_41)

    k1 = k1_41(i);
    k2 = k2_41(i);

    K_PD = k1 + k2*s;
    T_PD = feedback(K_PD*Gtheta,1);

    [y,tout] = step(T_PD,t);

    plot(tout,y, ...
        'Color', colors_41{i}, ...
        'LineWidth', 1.8);

end

yline(1,'-', ...
    'Color', c_gray, ...
    'LineWidth',1.2);

xline(Ts_req_41,'--', ...
    'Color', c_red, ...
    'LineWidth',1.4);

grid on;

ax = gca;
ax.Color = bg;
ax.XColor = fg;
ax.YColor = fg;
ax.GridColor = gridc;
ax.GridAlpha = 0.35;
ax.FontSize = 10;

disableDefaultInteractivity(ax);
ax.Toolbar.Visible = 'off';

title('Resposta ao degrau em malha fechada com controlo PD da posição', ...
    'Color', fg, ...
    'FontWeight','bold');

xlabel('Tempo [s]', ...
    'Color', fg);

ylabel('\theta / \theta_r', ...
    'Color', fg);

legend('k_1=60, k_2=30', ...
       'k_1=70, k_2=35', ...
       'k_1=80, k_2=40', ...
       'k_1=100, k_2=50', ...
       'Referência', ...
       'Limite T_s^{30\%}=0.2 s', ...
       'TextColor', fg, ...
       'Color', bg, ...
       'EdgeColor', fg, ...
       'Location','southeast');

xlim([0 1.2]);
ylim([0 1.3]);

exportgraphics(gcf, ...
    fullfile(outDir,'Fig42_Step_PD_Posicao.png'), ...
    'BackgroundColor', bg, ...
    'Resolution', 300);

% ============================================================
% Guardar resultados da questão 4.1
% ============================================================

save(fullfile('Data','Lab2_resultados_41.mat'), ...
     'k0', 'a', 'b', 'G', 'Gtheta', ...
     'Ts_req_41', 'tol_41', 'sigma_min_41', ...
     'z_41', 'L_PD_base', ...
     'k1_41', 'k2_41', 'k3_41', ...
     'Ts30_41', 'Overshoot_41', 'Final_41', 'Poles_41', ...
     'k1_PD_41', 'k2_PD_41', 'k3_PD_41', ...
     'K_PD_41', 'T_PD_41', 'info_PD_41');

fprintf('\n============================================\n');
fprintf('FIGURAS EXPORTADAS - 4.1\n');
fprintf('============================================\n');
fprintf('Fig41_RootLocus_PD_Posicao.png\n');
fprintf('Fig42_Step_PD_Posicao.png\n');

fprintf('\nResultados guardados em:\n');
fprintf('Data/Lab2_resultados_41.mat\n');


%% ============================================================
%  4.2 - CONTROLO PID DA POSIÇÃO
%
%
%  Objetivo:
%       Complementar o controlador PD da 4.1 com ação integral,
%       de modo a permitir seguimento de referência em rampa
%       com erro estacionário nulo.
%
%  Estratégia:
%       - manter k1 e k2 do PD escolhido na 4.1;
%       - testar valores de k3;
%       - escolher k3 suficientemente pequeno para não alterar
%         demasiado os polos principais da 4.1;
%       - verificar resposta à rampa por simulação.
%
% ============================================================

% Garantir variáveis da 4.1
if ~exist('k0','var')
    k0 = 0.0911;
end

if ~exist('a','var')
    a = 2.1119;
end

if ~exist('outDir','var')
    outDir = fullfile(pwd,'Image');
end

if ~exist('dataDir','var')
    dataDir = fullfile(pwd,'Data');
end

if ~exist(dataDir,'dir')
    mkdir(dataDir);
end

if ~exist('bg','var')
    bg    = [0 0 0];
    fg    = [1 1 1];
    gridc = [0.45 0.45 0.45];

    c_blue   = [0.20 0.60 1.00];
    c_orange = [1.00 0.55 0.10];
    c_green  = [0.20 0.90 0.35];
    c_yellow = [1.00 0.85 0.10];
    c_red    = [1.00 0.25 0.25];
    c_gray   = [0.70 0.70 0.70];
end

s = tf('s');

b = k0*a;
G = b/(s+a);
Gtheta = G/s;

fprintf('\n============================================\n');
fprintf('4.2 - CONTROLO PID DA POSIÇÃO\n');
fprintf('============================================\n');

% ============================================================
% Controlador PD de partida vindo da 4.1
% ============================================================

if ~exist('k1_PD_41','var')
    k1_PD_41 = 70;
end

if ~exist('k2_PD_41','var')
    k2_PD_41 = 35;
end

k1_PID_42 = k1_PD_41;
k2_PID_42 = k2_PD_41;

fprintf('\nControlador PD de partida:\n');
fprintf('k1 = %.4f\n', k1_PID_42);
fprintf('k2 = %.4f\n', k2_PID_42);

% ============================================================
% Ganhos integrais candidatos
% ============================================================
%
% A ação integral introduz mais um polo na origem.
% Por isso k3 deve ser escolhido com cuidado!
% demasiado pequeno -> erro de rampa desaparece lentamente;
% demasiado grande  -> altera demasiado a dinâmica e pode oscilar.
% ============================================================

k3_42 = [20 40 60 80 100 150 200];

Ts30_PID_42       = zeros(size(k3_42));
Overshoot_PID_42  = zeros(size(k3_42));
Final_PID_42      = zeros(size(k3_42));
Poles_PID_42      = cell(size(k3_42));

% Métricas para resposta à rampa
RampErrFinal_42 = zeros(size(k3_42));
RampErrMean_42  = zeros(size(k3_42));
RampErrMax_42   = zeros(size(k3_42));

% Simulação de rampa de posição
t_ramp = linspace(0,60,6000);
omega_r_sim = 1;                  % rad/s, valor genérico para simulação
theta_ref = omega_r_sim*t_ramp;   % rampa de posição

fprintf('\nTeste de candidatos para k3:\n');

for i = 1:length(k3_42)

    k3 = k3_42(i);

    K_PID = k1_PID_42 + k2_PID_42*s + k3/s;
    T_PID = feedback(K_PID*Gtheta,1);

    info = stepinfo(T_PID, ...
        'SettlingTimeThreshold',0.30);

    Ts30_PID_42(i)      = info.SettlingTime;
    Overshoot_PID_42(i) = info.Overshoot;
    Final_PID_42(i)     = dcgain(T_PID);
    Poles_PID_42{i}     = pole(T_PID);

    % Resposta à rampa
    y_ramp = lsim(T_PID, theta_ref, t_ramp);
    e_ramp = theta_ref(:) - y_ramp(:);

    idx_ss = t_ramp > 45;

    RampErrFinal_42(i) = e_ramp(end);
    RampErrMean_42(i)  = mean(abs(e_ramp(idx_ss)));
    RampErrMax_42(i)   = max(abs(e_ramp(idx_ss)));

    fprintf('\n PID candidato %d\n', i);
    fprintf('  k1 = %.4f\n', k1_PID_42);
    fprintf('  k2 = %.4f\n', k2_PID_42);
    fprintf('  k3 = %.4f\n', k3);
    fprintf('  Ts_30 step  = %.4f s\n', Ts30_PID_42(i));
    fprintf('  Overshoot   = %.2f %%\n', Overshoot_PID_42(i));
    fprintf('  Valor final = %.4f\n', Final_PID_42(i));
    fprintf('  Erro final à rampa = %.6f rad\n', RampErrFinal_42(i));
    fprintf('  Erro médio |e|, t>45s = %.6f rad\n', RampErrMean_42(i));
    fprintf('  Erro máx.  |e|, t>45s = %.6f rad\n', RampErrMax_42(i));
    fprintf('  Polos:\n');
    disp(Poles_PID_42{i});

end

% ============================================================
% Escolha automática de k3
% ============================================================
%
% Critério usado:
%   escolher o menor k3 que reduza claramente o erro de rampa
%   sem introduzir overshoot significativo.
%
% Para já, critério conservador:
%   Overshoot < 5%
%   Ts30 da resposta ao degrau continua < 0.2 s
% ============================================================

erro_limite_42 = 0.02;   % rad, erro médio admissível em regime

idx_ok_42 = find( ...
    RampErrMean_42 < erro_limite_42 & ...
    Overshoot_PID_42 < 10, ...
    1, 'first');

if isempty(idx_ok_42)
    warning('Nenhum k3 candidato cumpriu o critério de erro de rampa.');
    [~,idx_sel_42] = min(RampErrMean_42);
else
    idx_sel_42 = idx_ok_42;
end

k3_PID_42 = k3_42(idx_sel_42);

K_PID_42 = k1_PID_42 + k2_PID_42*s + k3_PID_42/s;
T_PID_42 = feedback(K_PID_42*Gtheta,1);

info_PID_42 = stepinfo(T_PID_42, ...
    'SettlingTimeThreshold',0.30);

p_PID_42 = pole(T_PID_42);

fprintf('\nControlador PID selecionado:\n');
fprintf('k1 = %.4f\n', k1_PID_42);
fprintf('k2 = %.4f\n', k2_PID_42);
fprintf('k3 = %.4f\n', k3_PID_42);
fprintf('Ts_30 step = %.4f s\n', info_PID_42.SettlingTime);
fprintf('Overshoot = %.2f %%\n', info_PID_42.Overshoot);
fprintf('Valor final = %.4f\n', dcgain(T_PID_42));
fprintf('Polos selecionados:\n');
disp(p_PID_42);

% ============================================================
% Figura 43 - Lugar das raízes com PID
% ============================================================

figure(43); clf;
set(gcf,'Color',bg,'InvertHardcopy','off');
hold on;

z_PID_42     = k1_PID_42/k2_PID_42;
alpha_PID_42 = k3_PID_42/k2_PID_42;

L_PID_base = (s + z_PID_42 + alpha_PID_42/s)*Gtheta;

k_rl = linspace(0,80,1000);
r_rl = rlocus(L_PID_base,k_rl);

for r = 1:size(r_rl,1)
    plot(real(r_rl(r,:)), imag(r_rl(r,:)), ...
        'Color', c_blue, ...
        'LineWidth', 1.8);
end

% Polos iniciais: planta de posição + polo integral do controlador
plot([0 0 -a],[0 0 0],'x', ...
    'Color', c_yellow, ...
    'MarkerSize', 9, ...
    'LineWidth',2.0);

% Zeros do PID
z_PID_roots_42 = zero(k1_PID_42 + k2_PID_42*s + k3_PID_42/s);

plot(real(z_PID_roots_42), imag(z_PID_roots_42),'o', ...
    'MarkerEdgeColor', c_green, ...
    'MarkerFaceColor', bg, ...
    'MarkerSize', 9, ...
    'LineWidth',2.0);

% Polos escolhidos
plot(real(p_PID_42), imag(p_PID_42),'o', ...
    'MarkerEdgeColor', c_red, ...
    'MarkerFaceColor', bg, ...
    'MarkerSize', 9, ...
    'LineWidth',2.2);

grid on;

ax = gca;
ax.Color = bg;
ax.XColor = fg;
ax.YColor = fg;
ax.GridColor = gridc;
ax.GridAlpha = 0.35;
ax.FontSize = 10;

disableDefaultInteractivity(ax);
ax.Toolbar.Visible = 'off';

title('Lugar das raízes com controlo PID da posição', ...
    'Color', fg, ...
    'FontWeight','bold');

xlabel('Eixo real', ...
    'Color', fg);

ylabel('Eixo imaginário', ...
    'Color', fg);

legend('Lugar das raízes', ...
       'Polos iniciais', ...
       'Zeros do PID', ...
       'Polos escolhidos', ...
       'TextColor', fg, ...
       'Color', bg, ...
       'EdgeColor', fg, ...
       'Location','northwest');

xlim([-10 1]);
ylim([-5 5]);

exportgraphics(gcf, ...
    fullfile(outDir,'Fig43_RootLocus_PID_Posicao.png'), ...
    'BackgroundColor', bg, ...
    'Resolution', 300);

% ============================================================
% Figura 44 - Comparação PD vs PID em resposta à rampa
% ============================================================

K_PD_42 = k1_PID_42 + k2_PID_42*s;
T_PD_42 = feedback(K_PD_42*Gtheta,1);

theta_PD  = lsim(T_PD_42, theta_ref, t_ramp);
theta_PID = lsim(T_PID_42, theta_ref, t_ramp);

e_PD  = theta_ref(:) - theta_PD(:);
e_PID = theta_ref(:) - theta_PID(:);

figure(44); clf;
set(gcf,'Color',bg,'InvertHardcopy','off');

subplot(2,1,1)
hold on;

plot(t_ramp, theta_ref, ...
    'Color', c_gray, ...
    'LineWidth',1.5);

plot(t_ramp, theta_PD, ...
    'Color', c_blue, ...
    'LineWidth',1.8);

plot(t_ramp, theta_PID, ...
    'Color', c_green, ...
    'LineWidth',1.8);

grid on;

ax = gca;
ax.Color = bg;
ax.XColor = fg;
ax.YColor = fg;
ax.GridColor = gridc;
ax.GridAlpha = 0.35;
ax.FontSize = 10;

title('Seguimento de referência em rampa', ...
    'Color', fg, ...
    'FontWeight','bold');

xlabel('Tempo [s]', ...
    'Color', fg);

ylabel('\theta [rad]', ...
    'Color', fg);

legend('\theta_r', ...
       'PD', ...
       'PID', ...
       'TextColor', fg, ...
       'Color', bg, ...
       'EdgeColor', fg, ...
       'Location','northwest');

subplot(2,1,2)
hold on;

plot(t_ramp, e_PD, ...
    'Color', c_blue, ...
    'LineWidth',1.8);

plot(t_ramp, e_PID, ...
    'Color', c_green, ...
    'LineWidth',1.8);

yline(0,'-', ...
    'Color', c_gray, ...
    'LineWidth',1.2);

grid on;

ax = gca;
ax.Color = bg;
ax.XColor = fg;
ax.YColor = fg;
ax.GridColor = gridc;
ax.GridAlpha = 0.35;
ax.FontSize = 10;

title('Erro de posição na resposta à rampa', ...
    'Color', fg, ...
    'FontWeight','bold');

xlabel('Tempo [s]', ...
    'Color', fg);

ylabel('e_\theta [rad]', ...
    'Color', fg);

legend('Erro PD', ...
       'Erro PID', ...
       'Erro nulo', ...
       'TextColor', fg, ...
       'Color', bg, ...
       'EdgeColor', fg, ...
       'Location','northeast');

exportgraphics(gcf, ...
    fullfile(outDir,'Fig44_Rampa_PD_PID_Posicao.png'), ...
    'BackgroundColor', bg, ...
    'Resolution', 300);

% ============================================================
% Guardar resultados da questão 4.2
% ============================================================

save(fullfile(dataDir,'Lab2_resultados_42.mat'), ...
     'k0', 'a', 'b', 'G', 'Gtheta', ...
     'k1_PID_42', 'k2_PID_42', 'k3_42', 'k3_PID_42', ...
     'K_PID_42', 'T_PID_42', 'info_PID_42', ...
     'Ts30_PID_42', 'Overshoot_PID_42', 'Final_PID_42', ...
     'Poles_PID_42', 'p_PID_42', ...
     'RampErrFinal_42', 'RampErrMean_42', 'RampErrMax_42', ...
     't_ramp', 'omega_r_sim', 'theta_ref', ...
     'theta_PD', 'theta_PID', 'e_PD', 'e_PID', ...
     'z_PID_42', 'alpha_PID_42');

fprintf('\n============================================\n');
fprintf('FIGURAS EXPORTADAS - 4.2\n');
fprintf('============================================\n');
fprintf('Fig43_RootLocus_PID_Posicao.png\n');
fprintf('Fig44_Rampa_PD_PID_Posicao.png\n');

fprintf('\nResultados guardados em:\n');
fprintf('Data/Lab2_resultados_42.mat\n');

%% ============================================================
%  4.3 - AQUISIÇÃO EXPERIMENTAL SEGURA - POSIÇÃO
%
%  Ensaios base:
%       PD    : k1 = 70, k2 = 35, k3 = 0
%       PID20 : k1 = 70, k2 = 35, k3 = 20
%       PID40 : k1 = 70, k2 = 35, k3 = 40
%
%  Ensaio opcional:
%       PID custom, com k3 escolhido por mim
%
%  Guarda em Data:
%       Lab2_43_PD_expN.mat
%       Lab2_43_PID20_expN.mat
%       Lab2_43_PID40_expN.mat
%       Lab2_43_PIDcustom_expN.mat
%       Lab2_43_expN_geral.mat
%       Lab2_43_todas_experiencias.mat
%
%  Guarda em Image:
%       Fig431_PD_expN_posicao.png
%       Fig432_PID20_expN_posicao.png
%       Fig433_PID40_expN_posicao.png
%       Fig434_PIDcustom_expN_posicao.png
% ============================================================

fprintf('\n============================================\n');
fprintf('4.3 - AQUISIÇÃO EXPERIMENTAL SEGURA - POSIÇÃO\n');
fprintf('============================================\n');

% ------------------------------------------------------------
% Pastas
% ------------------------------------------------------------

if ~exist('dataDir','var') || isempty(dataDir)
    dataDir = fullfile(pwd,'Data');
end

if ~exist('outDir','var') || isempty(outDir)
    outDir = fullfile(pwd,'Image');
end

if ~exist(dataDir,'dir')
    mkdir(dataDir);
end

if ~exist(outDir,'dir')
    mkdir(outDir);
end

fprintf('\nPasta de dados:   %s\n', dataDir);
fprintf('Pasta de figuras: %s\n', outDir);

% ------------------------------------------------------------
% Checkup de funções
% ------------------------------------------------------------

if exist('run_experiment_Matlab2023','file') ~= 2
    error('run_experiment_Matlab2023.m não foi encontrado no path.');
end

if exist('plot_experiment_results','file') ~= 2
    error('plot_experiment_results.m não foi encontrado no path.');
end

fprintf('\n[OK] run_experiment_Matlab2023 encontrado.\n');
fprintf('[OK] plot_experiment_results encontrado.\n');

% ------------------------------------------------------------
% Controladores base
% ------------------------------------------------------------

controladores = struct([]);

controladores(1).label = 'PD';
controladores(1).desc  = 'Controlo PD de posição';
controladores(1).k1    = 70;
controladores(1).k2    = 35;
controladores(1).k3    = 0;

controladores(2).label = 'PID20';
controladores(2).desc  = 'Controlo PID de posição, k3=20';
controladores(2).k1    = 70;
controladores(2).k2    = 35;
controladores(2).k3    = 20;

controladores(3).label = 'PID40';
controladores(3).desc  = 'Controlo PID de posição, k3=40';
controladores(3).k1    = 70;
controladores(3).k2    = 35;
controladores(3).k3    = 40;

% ------------------------------------------------------------
% PID custom opcional
% ------------------------------------------------------------

respCustom = input('\nQueres adicionar um PID custom? [s/n]: ', 's');

if strcmpi(strtrim(respCustom),'s')

    k3_custom = input('Indica o valor de k3 para o PID custom: ');

    if isempty(k3_custom) || ~isnumeric(k3_custom) || k3_custom <= 0
        error('Valor de k3_custom inválido. Tem de ser positivo.');
    end

    idx = length(controladores) + 1;

    % Label sem casas decimais se for inteiro, com p se tiver decimal
    if abs(k3_custom - round(k3_custom)) < 1e-9
        labelCustom = sprintf('PID%d', round(k3_custom));
    else
        labelCustom = sprintf('PID%.2f', k3_custom);
        labelCustom = strrep(labelCustom,'.','p');
    end

    controladores(idx).label = labelCustom;
    controladores(idx).desc  = sprintf('Controlo PID de posição, k3=%.4f', k3_custom);
    controladores(idx).k1    = 70;
    controladores(idx).k2    = 35;
    controladores(idx).k3    = k3_custom;

    fprintf('\n[OK] PID custom adicionado: %s, k3 = %.4f\n', labelCustom, k3_custom);
end

% ------------------------------------------------------------
% Número da experiência/ronda
% ------------------------------------------------------------

expNum = input(['\nIndica o número da experiência/ronda a gravar ', ...
                '(ex.: 1 para primeira ronda, 2 para segunda, etc.): ']);

if isempty(expNum) || expNum < 1 || floor(expNum) ~= expNum
    error('Número de experiência inválido.');
end

% ------------------------------------------------------------
% Estrutura geral da ronda
% ------------------------------------------------------------

EXP = struct();
EXP.expNum = expNum;
EXP.date   = datestr(now);
EXP.notes  = 'Experiência de controlo de posição - Secção 4.3 - modo 5';

for i = 1:length(controladores)

    label = controladores(i).label;
    k1 = controladores(i).k1;
    k2 = controladores(i).k2;
    k3 = controladores(i).k3;

    fprintf('\n--------------------------------------------\n');
    fprintf('%s - %s\n', label, controladores(i).desc);
    fprintf('k1 = %.4f, k2 = %.4f, k3 = %.4f\n', k1, k2, k3);
    fprintf('--------------------------------------------\n');

    % Inicializar campo como vazio
    EXP.(label).label  = label;
    EXP.(label).k1     = k1;
    EXP.(label).k2     = k2;
    EXP.(label).k3     = k3;
    EXP.(label).status = 'not_run';
    EXP.(label).data   = [];
    EXP.(label).file   = '';
    EXP.(label).figure = '';

    resposta = input(sprintf('Executar %s exp%d? [s/n]: ', label, expNum), 's');

    if ~strcmpi(strtrim(resposta),'s')
        fprintf('%s exp%d não executado. Fica registado como vazio.\n', label, expNum);
        continue;
    end

    % --------------------------------------------------------
    % Nomes dos ficheiros
    % --------------------------------------------------------

    fileIndividual = fullfile(dataDir, ...
        sprintf('Lab2_43_%s_exp%d.mat', label, expNum));

    fileFig = fullfile(outDir, ...
        sprintf('Fig43%d_%s_exp%d_posicao.png', i, label, expNum));

    % --------------------------------------------------------
    % Proteção contra overwrite
    % --------------------------------------------------------

    if exist(fileIndividual,'file')
        fprintf('\nATENÇÃO: o ficheiro já existe:\n%s\n', fileIndividual);
        overwrite = input('Queres sobrescrever este ficheiro? [s/n]: ', 's');

        if ~strcmpi(strtrim(overwrite),'s')
            fprintf('Ficheiro não sobrescrito. %s exp%d não executado.\n', label, expNum);
            EXP.(label).status = 'skipped_existing_file';
            EXP.(label).file   = fileIndividual;
            continue;
        end
    end

    % --------------------------------------------------------
    % Executar experiência
    % --------------------------------------------------------

    fprintf('\nA executar %s exp%d...\n', label, expNum);

    try
        data = run_experiment_Matlab2023(5,k1,k2,k3);
        data = plot_experiment_results(data);

        % Metadados
        data.expNum = expNum;
        data.controllerLabel = label;
        data.k1 = k1;
        data.k2 = k2;
        data.k3 = k3;
        data.date = datestr(now);

        % Guardar figura do plot_experiment_results
        figHandle = figure(11*data.mode);
        exportgraphics(figHandle, fileFig, ...
            'Resolution',300);

        % Guardar ficheiro individual
        save(fileIndividual,'data');

        % Atualizar estrutura da ronda
        EXP.(label).status = 'completed';
        EXP.(label).data   = data;
        EXP.(label).file   = fileIndividual;
        EXP.(label).figure = fileFig;

        fprintf('[OK] Dados guardados em:\n%s\n', fileIndividual);
        fprintf('[OK] Figura guardada em:\n%s\n', fileFig);

    catch ME
        warning('Erro ao executar %s exp%d: %s', label, expNum, ME.message);

        EXP.(label).status = 'error';
        EXP.(label).errorMessage = ME.message;
    end
end

% ------------------------------------------------------------
% Guardar ficheiro geral da ronda
% ------------------------------------------------------------

fileGeralRonda = fullfile(dataDir, ...
    sprintf('Lab2_43_exp%d_geral.mat', expNum));

if exist(fileGeralRonda,'file')
    fprintf('\nATENÇÃO: o ficheiro geral da ronda já existe:\n%s\n', fileGeralRonda);
    overwriteGeral = input('Queres sobrescrever o ficheiro geral desta ronda? [s/n]: ', 's');

    if ~strcmpi(strtrim(overwriteGeral),'s')
        warning('Ficheiro geral da ronda não foi sobrescrito.');
    else
        save(fileGeralRonda,'EXP');
    end
else
    save(fileGeralRonda,'EXP');
end

fprintf('\n============================================\n');
fprintf('FICHEIRO GERAL DA RONDA\n');
fprintf('============================================\n');
fprintf('%s\n', fileGeralRonda);

% ------------------------------------------------------------
% Atualizar ficheiro total acumulado
% ------------------------------------------------------------

fileTotal = fullfile(dataDir,'Lab2_43_todas_experiencias.mat');

if exist(fileTotal,'file')
    S = load(fileTotal);

    if isfield(S,'TODAS')
        TODAS = S.TODAS;
    else
        TODAS = struct([]);
    end
else
    TODAS = struct([]);
end

TODAS(expNum).EXP = EXP;

save(fileTotal,'TODAS');

fprintf('\n============================================\n');
fprintf('FICHEIRO TOTAL ATUALIZADO\n');
fprintf('============================================\n');
fprintf('%s\n', fileTotal);

% ------------------------------------------------------------
% Resumo
% ------------------------------------------------------------

fprintf('\nResumo da ronda exp%d:\n', expNum);

for i = 1:length(controladores)
    label = controladores(i).label;
    fprintf('%s: %s\n', label, EXP.(label).status);
end



%% ============================================================
%  4.3 - COMPARACAO DIRETA DO ERRO DE POSICAO
%  Apenas durante a fase de seguimento da rampa: t >= 10 s
%
%  Guarda:
%       Image/Fig434_ErroComparacao_exp2.png
% ============================================================

fprintf('\n============================================\n');
fprintf('4.3 - COMPARACAO DIRETA DO ERRO DE POSICAO\n');
fprintf('============================================\n');

if ~exist('dataDir','var') || isempty(dataDir)
    dataDir = fullfile(pwd,'Data');
end

if ~exist('outDir','var') || isempty(outDir)
    outDir = fullfile(pwd,'Image');
end

if ~exist(outDir,'dir')
    mkdir(outDir);
end

expNum = 2;

controladores = {'PD','PID20','PID40'};
legendas = {'PD', 'PID, k_3 = 20', 'PID, k_3 = 40'};

cores = [
    0.0000 0.4470 0.7410;   % azul MATLAB
    0.8500 0.3250 0.0980;   % laranja MATLAB
    0.4660 0.6740 0.1880    % verde MATLAB
];

figure(434); clf;
set(gcf,'Color','k','InvertHardcopy','off');
set(gcf,'Position',[100 100 1800 900]);

hold on;

for i = 1:length(controladores)

    nome = controladores{i};
    fileData = fullfile(dataDir, sprintf('Lab2_43_%s_exp%d.mat', nome, expNum));

    if ~exist(fileData,'file')
        warning('Ficheiro nao encontrado: %s', fileData);
        continue;
    end

    S = load(fileData);

    if ~isfield(S,'data')
        error('O ficheiro %s nao contem a variavel data.', fileData);
    end

    data = S.data;

    t = data.time(:);
    theta = data.angle(:);
    theta_ref = data.angle_ref(:);

    % Apenas fase de seguimento da rampa, apos t = 10 s
    idx = t >= 10;

    t_plot = t(idx) - 10;
    theta_plot = theta(idx);
    theta_ref_plot = theta_ref(idx);

    e_theta = theta_ref_plot - theta_plot;

    plot(t_plot, e_theta, ...
        'Color', cores(i,:), ...
        'LineWidth', 2.8);
end

yline(0,'-', ...
    'Color',[0.75 0.75 0.75], ...
    'LineWidth',1.8);

grid on;

ax = gca;
ax.Color = 'k';
ax.XColor = 'w';
ax.YColor = 'w';
ax.GridColor = [0.35 0.35 0.35];
ax.GridAlpha = 0.45;
ax.LineWidth = 1.2;
ax.FontSize = 16;
ax.FontWeight = 'bold';

title('Erro de posicao durante o seguimento da rampa', ...
    'Color','w', ...
    'FontSize',22, ...
    'FontWeight','bold');

xlabel('Tempo apos inicio da rampa [s]', ...
    'Color','w', ...
    'FontSize',18, ...
    'FontWeight','bold');

ylabel('e_\theta(t) [rad]', ...
    'Color','w', ...
    'FontSize',18, ...
    'FontWeight','bold');

legend(legendas, ...
    'TextColor','w', ...
    'Color','k', ...
    'EdgeColor','w', ...
    'FontSize',15, ...
    'Location','northeast');

xlim([0 10]);

yl = ylim;
margem = 0.05*(yl(2)-yl(1));
ylim([yl(1)-margem, yl(2)+margem]);

fileFig = fullfile(outDir,'Fig434_ErroComparacao_exp2.png');

exportgraphics(gcf, fileFig, ...
    'BackgroundColor','k', ...
    'Resolution',300);

fprintf('[OK] Figura guardada em:\n%s\n', fileFig);

%% ============================================================
%  4.3 - FIGURAS COMPARATIVAS POSICAO E ATUACAO
%  Ensaio representativo: exp2
%
%  Guarda:
%   Image/Fig435_PosicaoComparacao_exp2.png
%   Image/Fig436_AtuacaoComparacao_exp2.png
% ============================================================

fprintf('\n============================================\n');
fprintf('4.3 - FIGURAS COMPARATIVAS POSICAO E ATUACAO\n');
fprintf('============================================\n');

if ~exist('dataDir','var') || isempty(dataDir)
    dataDir = fullfile(pwd,'Data');
end

if ~exist('outDir','var') || isempty(outDir)
    outDir = fullfile(pwd,'Image');
end

if ~exist(outDir,'dir')
    mkdir(outDir);
end

expNum = 2;

controladores = {'PD','PID20','PID40'};
legendas_pos = {'\theta_r(t)', 'PD', 'PID, k_3 = 20', 'PID, k_3 = 40'};
legendas_u   = {'PD', 'PID, k_3 = 20', 'PID, k_3 = 40'};

cores = [
    0.75 0.75 0.75;       % referencia - cinzento
    0.0000 0.4470 0.7410; % PD - azul
    0.8500 0.3250 0.0980; % PID20 - laranja
    0.4660 0.6740 0.1880  % PID40 - verde
];

dados = struct();

for i = 1:length(controladores)

    nome = controladores{i};
    fileData = fullfile(dataDir, sprintf('Lab2_43_%s_exp%d.mat', nome, expNum));

    if ~exist(fileData,'file')
        error('Ficheiro nao encontrado: %s', fileData);
    end

    S = load(fileData);

    if ~isfield(S,'data')
        error('O ficheiro %s nao contem a variavel data.', fileData);
    end

    data = S.data;

    dados(i).nome = nome;
    dados(i).t = data.time(:);
    dados(i).theta = data.angle(:);
    dados(i).theta_ref = data.angle_ref(:);

    % Campo do sinal de atuacao u(t)
    if isfield(data,'input')
        dados(i).u = data.input(:);
    elseif isfield(data,'u')
        dados(i).u = data.u(:);
    elseif isfield(data,'PWM')
        dados(i).u = data.PWM(:);
    elseif isfield(data,'pwm')
        dados(i).u = data.pwm(:);
    elseif isfield(data,'voltage')
        dados(i).u = data.voltage(:);
    elseif isfield(data,'control')
        dados(i).u = data.control(:);
    else
        disp('Campos disponiveis em data:');
        disp(fieldnames(data));
        error('Nao encontrei o campo do sinal de atuacao u(t).');
    end
end

figure(435); clf;
set(gcf,'Color','k','InvertHardcopy','off');
set(gcf,'Position',[100 100 1800 900]);
hold on;

plot(dados(1).t, dados(1).theta_ref, ...
    'Color', cores(1,:), ...
    'LineWidth', 2.8);

for i = 1:length(controladores)
    plot(dados(i).t, dados(i).theta, ...
        'Color', cores(i+1,:), ...
        'LineWidth', 2.8);
end

grid on;
ax = gca;
ax.Color = 'k';
ax.XColor = 'w';
ax.YColor = 'w';
ax.GridColor = [0.35 0.35 0.35];
ax.GridAlpha = 0.45;
ax.LineWidth = 1.2;
ax.FontSize = 16;
ax.FontWeight = 'bold';

title('Comparacao experimental da posicao angular', ...
    'Color','w','FontSize',22,'FontWeight','bold');

xlabel('Tempo [s]', ...
    'Color','w','FontSize',18,'FontWeight','bold');

ylabel('\theta(t) [rad]', ...
    'Color','w','FontSize',18,'FontWeight','bold');

legend(legendas_pos, ...
    'TextColor','w', ...
    'Color','k', ...
    'EdgeColor','w', ...
    'FontSize',15, ...
    'Location','northwest');

xlim([0 20]);

fileFig = fullfile(outDir,'Fig435_PosicaoComparacao_exp2.png');
exportgraphics(gcf, fileFig, 'BackgroundColor','k', 'Resolution',300);
fprintf('[OK] Figura guardada em:\n%s\n', fileFig);


figure(436); clf;
set(gcf,'Color','k','InvertHardcopy','off');
set(gcf,'Position',[100 100 1800 900]);
hold on;

for i = 1:length(controladores)
    plot(dados(i).t, dados(i).u, ...
        'Color', cores(i+1,:), ...
        'LineWidth', 2.4);
end

grid on;
ax = gca;
ax.Color = 'k';
ax.XColor = 'w';
ax.YColor = 'w';
ax.GridColor = [0.35 0.35 0.35];
ax.GridAlpha = 0.45;
ax.LineWidth = 1.2;
ax.FontSize = 16;
ax.FontWeight = 'bold';

title('Comparacao experimental do sinal de atuacao', ...
    'Color','w','FontSize',22,'FontWeight','bold');

xlabel('Tempo [s]', ...
    'Color','w','FontSize',18,'FontWeight','bold');

ylabel('u(t) [PWM]', ...
    'Color','w','FontSize',18,'FontWeight','bold');

legend(legendas_u, ...
    'TextColor','w', ...
    'Color','k', ...
    'EdgeColor','w', ...
    'FontSize',15, ...
    'Location','northeast');

xlim([0 20]);

fileFig = fullfile(outDir,'Fig436_AtuacaoComparacao_exp2.png');
exportgraphics(gcf, fileFig, 'BackgroundColor','k', 'Resolution',300);
fprintf('[OK] Figura guardada em:\n%s\n', fileFig);



%% ============================================================
%  4.3 - METRICAS EXPERIMENTAIS PARA VALIDACAO
%
%  Objetivo:
%       Calcular metricas quantitativas dos 3 ensaios
%       para PD, PID20 e PID40.
%
%  Analise apenas durante a fase da rampa:
%       t >= 10 s
%
%  Guarda:
%       Data/Lab2_43_metricas_rampa.mat
% ============================================================

fprintf('\n============================================\n');
fprintf('4.3 - METRICAS EXPERIMENTAIS PARA VALIDACAO\n');
fprintf('============================================\n');

% ------------------------------------------------------------
% Pasta de dados
% ------------------------------------------------------------

if ~exist('dataDir','var') || isempty(dataDir)
    dataDir = fullfile(pwd,'Data');
end

if ~exist(dataDir,'dir')
    mkdir(dataDir);
end

% ------------------------------------------------------------
% Configuracao
% ------------------------------------------------------------

expNums = [1 2 3];

controladores = {'PD','PID20','PID40'};
nomesTabela   = {'PD','PID k3=20','PID k3=40'};

t_inicio_rampa = 10;     % [s]
janela_final   = 1.0;    % [s] media do ultimo segundo da rampa

metricas = struct([]);

fprintf('\nFase analisada: t >= %.2f s\n', t_inicio_rampa);
fprintf('Erro final: media dos ultimos %.2f s da rampa.\n', janela_final);

% ------------------------------------------------------------
% Calculo das metricas
% ------------------------------------------------------------

for c = 1:length(controladores)

    ctrl = controladores{c};
    nomeCtrl = nomesTabela{c};

    fprintf('\n--------------------------------------------\n');
    fprintf('%s\n', nomeCtrl);
    fprintf('--------------------------------------------\n');

    for e = 1:length(expNums)

        expNum = expNums(e);

        fileData = fullfile(dataDir, ...
            sprintf('Lab2_43_%s_exp%d.mat', ctrl, expNum));

        if ~exist(fileData,'file')
            warning('Ficheiro nao encontrado: %s', fileData);
            continue;
        end

        S = load(fileData);

        if ~isfield(S,'data')
            warning('O ficheiro %s nao contem a variavel data.', fileData);
            continue;
        end

        data = S.data;

        % Campos obrigatorios
        if ~isfield(data,'time') || ~isfield(data,'angle') || ~isfield(data,'angle_ref')
            warning('O ficheiro %s nao tem time/angle/angle_ref.', fileData);
            disp(fieldnames(data));
            continue;
        end

        t = data.time(:);
        theta = data.angle(:);
        theta_ref = data.angle_ref(:);

        % Campo da atuacao u(t)
        if isfield(data,'input')
            u = data.input(:);
        elseif isfield(data,'u')
            u = data.u(:);
        elseif isfield(data,'PWM')
            u = data.PWM(:);
        elseif isfield(data,'pwm')
            u = data.pwm(:);
        elseif isfield(data,'voltage')
            u = data.voltage(:);
        elseif isfield(data,'control')
            u = data.control(:);
        else
            warning('Nao encontrei campo de atuacao em %s.', fileData);
            disp(fieldnames(data));
            u = NaN(size(t));
        end

        % Vetores com o mesmo tamanho
        N = min([length(t), length(theta), length(theta_ref), length(u)]);

        t = t(1:N);
        theta = theta(1:N);
        theta_ref = theta_ref(1:N);
        u = u(1:N);

        idx_valid = isfinite(t) & isfinite(theta) & isfinite(theta_ref) & isfinite(u);

        t = t(idx_valid);
        theta = theta(idx_valid);
        theta_ref = theta_ref(idx_valid);
        u = u(idx_valid);

        % Apenas fase da rampa
        idx_rampa = t >= t_inicio_rampa;

        if nnz(idx_rampa) < 10
            warning('Poucos pontos na fase da rampa em %s.', fileData);
            continue;
        end

        t_r = t(idx_rampa) - t_inicio_rampa;
        theta_r = theta(idx_rampa);
        theta_ref_r = theta_ref(idx_rampa);
        u_r = u(idx_rampa);

        e_theta = theta_ref_r - theta_r;

        % Janela final: ultimo segundo da rampa
        t_max_r = max(t_r);
        idx_final = t_r >= (t_max_r - janela_final);

        if nnz(idx_final) < 5
            idx_final = true(size(t_r));
        end

        e_final_vec = e_theta(idx_final);
        u_final_vec = u_r(idx_final);

        % Metricas
        e_medio      = mean(e_theta);
        e_abs_medio  = mean(abs(e_theta));
        e_rms        = sqrt(mean(e_theta.^2));
        e_final      = mean(e_final_vec);
        e_abs_final  = mean(abs(e_final_vec));
        e_max_abs    = max(abs(e_theta));

        u_medio      = mean(u_r);
        u_final      = mean(u_final_vec);
        u_max        = max(u_r);
        u_min        = min(u_r);
        u_max_abs    = max(abs(u_r));
        u_std        = std(u_r);

        theta_final     = mean(theta_r(idx_final));
        theta_ref_final = mean(theta_ref_r(idx_final));

        % Guardar em estrutura
        m = struct();
        m.Controlador = string(nomeCtrl);
        m.Codigo = string(ctrl);
        m.Experiencia = expNum;

        m.e_medio = e_medio;
        m.e_abs_medio = e_abs_medio;
        m.e_rms = e_rms;
        m.e_final = e_final;
        m.e_abs_final = e_abs_final;
        m.e_max_abs = e_max_abs;

        m.u_medio = u_medio;
        m.u_final = u_final;
        m.u_max = u_max;
        m.u_min = u_min;
        m.u_max_abs = u_max_abs;
        m.u_std = u_std;

        m.theta_final = theta_final;
        m.theta_ref_final = theta_ref_final;
        m.duracao_rampa = t_max_r;

        if isempty(metricas)
            metricas = m;
        else
            metricas(end+1) = m;
        end

        % Mostrar no Command Window
        fprintf('\nExp.%d\n', expNum);
        fprintf('  e_medio        = %+8.5f rad\n', e_medio);
        fprintf('  |e|_medio      = %8.5f rad\n', e_abs_medio);
        fprintf('  e_RMS          = %8.5f rad\n', e_rms);
        fprintf('  e_final        = %+8.5f rad\n', e_final);
        fprintf('  |e|_final      = %8.5f rad\n', e_abs_final);
        fprintf('  |e|_max        = %8.5f rad\n', e_max_abs);
        fprintf('  u_medio        = %8.2f PWM\n', u_medio);
        fprintf('  u_final        = %8.2f PWM\n', u_final);
        fprintf('  u_max          = %8.2f PWM\n', u_max);
        fprintf('  u_min          = %8.2f PWM\n', u_min);
        fprintf('  |u|_max        = %8.2f PWM\n', u_max_abs);
        fprintf('  std(u)         = %8.2f PWM\n', u_std);
    end
end

% ------------------------------------------------------------
% Resumo por controlador
% ------------------------------------------------------------

if isempty(metricas)
    error('Nao foram calculadas metricas. Verifica os ficheiros na pasta Data.');
end

metricasTable = struct2table(metricas);

fprintf('\n============================================\n');
fprintf('RESUMO MEDIA +- DESVIO-PADRAO POR CONTROLADOR\n');
fprintf('============================================\n');

resumo = struct([]);

for c = 1:length(controladores)

    ctrl = controladores{c};
    nomeCtrl = nomesTabela{c};

    idx = strcmp(metricasTable.Codigo, ctrl);

    if nnz(idx) == 0
        continue;
    end

    T = metricasTable(idx,:);

    r = struct();
    r.Controlador = string(nomeCtrl);
    r.N = height(T);

    r.e_rms_media       = mean(T.e_rms);
    r.e_rms_std         = std(T.e_rms);

    r.e_final_media     = mean(T.e_final);
    r.e_final_std       = std(T.e_final);

    r.e_abs_final_media = mean(T.e_abs_final);
    r.e_abs_final_std   = std(T.e_abs_final);

    r.e_max_abs_media   = mean(T.e_max_abs);
    r.e_max_abs_std     = std(T.e_max_abs);

    r.u_medio_media     = mean(T.u_medio);
    r.u_medio_std       = std(T.u_medio);

    r.u_final_media     = mean(T.u_final);
    r.u_final_std       = std(T.u_final);

    r.u_max_abs_media   = mean(T.u_max_abs);
    r.u_max_abs_std     = std(T.u_max_abs);

    r.u_std_media       = mean(T.u_std);
    r.u_std_std         = std(T.u_std);

    if isempty(resumo)
        resumo = r;
    else
        resumo(end+1) = r; 
    end

    fprintf('\n%s   N = %d\n', nomeCtrl, height(T));
    fprintf('  e_RMS        = %.5f +- %.5f rad\n', r.e_rms_media, r.e_rms_std);
    fprintf('  e_final      = %.5f +- %.5f rad\n', r.e_final_media, r.e_final_std);
    fprintf('  |e|_final    = %.5f +- %.5f rad\n', r.e_abs_final_media, r.e_abs_final_std);
    fprintf('  |e|_max      = %.5f +- %.5f rad\n', r.e_max_abs_media, r.e_max_abs_std);
    fprintf('  u_medio      = %.2f +- %.2f PWM\n', r.u_medio_media, r.u_medio_std);
    fprintf('  u_final      = %.2f +- %.2f PWM\n', r.u_final_media, r.u_final_std);
    fprintf('  |u|_max      = %.2f +- %.2f PWM\n', r.u_max_abs_media, r.u_max_abs_std);
    fprintf('  std(u)       = %.2f +- %.2f PWM\n', r.u_std_media, r.u_std_std);
end

resumoTable = struct2table(resumo);

% ------------------------------------------------------------
% Guardar apenas ficheiro .mat
% ------------------------------------------------------------

fileMetricas = fullfile(dataDir,'Lab2_43_metricas_rampa.mat');

save(fileMetricas, ...
    'metricas', 'metricasTable', ...
    'resumo', 'resumoTable', ...
    't_inicio_rampa', 'janela_final', ...
    'controladores', 'nomesTabela', 'expNums');

fprintf('\n============================================\n');
fprintf('METRICAS GUARDADAS\n');
fprintf('============================================\n');
fprintf('%s\n', fileMetricas);

fprintf('\nTabela detalhada disponivel em metricasTable.\n');
fprintf('Resumo disponivel em resumoTable.\n');
