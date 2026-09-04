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
%       L_PD_base(s) = (s+z)*Gtheta(s)
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
%  Controlador:
%
%       K_PID(s) = k1 + k2*s + k3/s
%
%  No tempo:
%
%       u(t) = k1*theta_e(t)
%            + k2*omega_e(t)
%            + k3*integral(theta_e(t))
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
% Por isso k3 deve ser escolhido com cuidado:
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
    fprintf('  Erro médio |e|, t>7s = %.6f rad\n', RampErrMean_42(i));
    fprintf('  Erro máx.  |e|, t>7s = %.6f rad\n', RampErrMax_42(i));
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

% Para root locus, escreve-se:
%
%       K_PID(s) = (k2*s^2 + k1*s + k3)/s
%
% Aqui fixa-se a razão k1/k2 e k3/k2, e varia-se k2.
%
% Controlador base normalizado:
%
%       K_base = s + z + alpha/s
%
% com:
%       z = k1/k2
%       alpha = k3/k2

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