%% Teórica 2.4 - Bode assintótico

% Este bloco gera o diagrama de Bode assintótico pedido na questão 2.4
% do guia para um sistema de primeira ordem do tipo:
%
%       G(s) = k0 * a / (s + a)
%
% O objetivo é ilustrar o comportamento em frequência do modelo:
% - patamar de baixa frequência associado a k0;
% - frequência de corte wc = a;
% - declive de -20 dB/década em alta frequência.
%
% Embora a questão 2.4 seja teórica, o gráfico foi particularizado com
% as estimativas k0_hat e a_hat obtidas posteriormente a partir do segundo
% degrau, para manter coerência com o modelo identificado no relatório.

k0 = 0.0911;
a  = 2.1119;

w = logspace(log10(a/20), log10(20*a), 500);

% Curva real
G_mag_db = 20*log10(k0*a ./ sqrt(w.^2 + a^2));

% Assíntotas
k0_db = 20*log10(k0);

assintota_baixa = k0_db * ones(size(w));
assintota_alta  = k0_db - 20*log10(w/a);

assintota_baixa(w > a) = NaN;
assintota_alta(w < a)  = NaN;

% Figura
figure('Color','k');

semilogx(w, G_mag_db, 'b-', 'LineWidth', 1.5); 
hold on;
grid on;

semilogx(w, assintota_baixa, 'r--', 'LineWidth', 1.5);
semilogx(w, assintota_alta,  'r--', 'LineWidth', 1.5);

xline(a, 'k:', 'LineWidth', 1.3);

xlabel('\omega [rad/s]');
ylabel('Magnitude [dB]');
title('Diagrama de Bode assintótico do sistema identificado');

legend('Curva real |G(j\omega)|', ...
       'Assíntotas', ...
       '\omega_c = a', ...
       'Location', 'southwest');

saveas(gcf, 'Fig24_BodeAssintotico.png');

% --------------------------------------------------------------------------------------------

%% ----------------------------------------------------------------
%  INÍCIO DOS BLOCOS RELATIVOS Á PARTE LABORATORIAL
% -----------------------------------------------------------------

% %% 1 - Execução e recolha de dados no Lab (Fase 1)

% Corre as rampas e o degrau, e guarda os dados
%--------------------------------------------
% ATENçÃO - CORRER APENAS NO LAB ESTE BLOCO 1
%--------------------------------------------
% clear; clc;

% ===============================
% LAB 1 - AQUISIÇÃO DE DADOS
% ===============================

% ---- 2.5: Rampas ----
% disp('A correr rampa positiva...')
% data11 = run_experiment_Matlab2023(1,1);

% disp('A correr rampa negativa...')
% data12 = run_experiment_Matlab2023(1,-1);

% ---- 2.6: Degrau ----
% disp('A correr resposta ao degrau...')
% data2 = run_experiment_Matlab2023(2);

% ===============================
% GUARDAR DADOS
% ===============================
% disp('A guardar dados da Fase 1...')
% save('Lab1_dados_Fase1.mat', 'data11', 'data12', 'data2');

% disp('Dados guardados com sucesso em Lab1_dados_Fase1.mat');

% --------------------------------------------------------------------------------------------

%% 2 - Análise e visualização das rampas (Questão 2.5 L)

% ===============================
% CARREGAR DADOS (opcional)
% ===============================
% Descomentar load se repetir em casa!
load('Lab1_dados_Fase1.mat');

% ===============================
% GRÁFICO 1 - DADOS BRUTOS (TEMPORAL)
% ==========6=====================
figure(21);

subplot(2,1,1);
plot(data11.time, data11.u, 'b', 'LineWidth', 1.1); hold on;
plot(data12.time, data12.u, 'r', 'LineWidth', 1.1);
grid on;
xlabel('Tempo [s]');
ylabel('u [PWM]');
title('Rampas aplicadas (dados brutos)');
legend('Rampa +', 'Rampa -');

subplot(2,1,2);
plot(data11.time, data11.vel, 'b', 'LineWidth', 1.1); hold on;
plot(data12.time, data12.vel, 'r', 'LineWidth', 1.1);
grid on;
xlabel('Tempo [s]');
ylabel('\omega [rad/s]');
title('Resposta do sistema (dados brutos)');
legend('Rampa +', 'Rampa -');

% Guardar figura em PNG
saveas(figure(21), 'Fig21_RampasBrutas.png');

% ===============================
% GRÁFICO 2 - ANÁLISE COM MARCAÇÕES
% ===============================
figure(22);

plot(data11.u, data11.vel, 'b', 'LineWidth', 1.1); hold on;
plot(data12.u, data12.vel, 'r', 'LineWidth', 1.1);
grid on;

xlabel('u [PWM]');
ylabel('\omega [rad/s]');
title('Identificação da zona morta (2.5)');
legend('Rampa +', 'Rampa -', 'Location', 'northwest');

% ===============================
% DETEÇÃO DA ZONA MORTA
% ===============================
% limiar de velocidade para ignorar ruído em torno de zero
limiar = 1;

% Ignorar zona perto de zero (histerese)
zona_excluir = 10; % PWM

idx_p = find(data11.vel > limiar & data11.u > zona_excluir, 1, 'first');
idx_n = find(data12.vel < -limiar & data12.u < -zona_excluir, 1, 'first');

if ~isempty(idx_p) && ~isempty(idx_n)

    u_barra_pos = data11.u(idx_p);
    u_barra_neg = data12.u(idx_n);
    c_est = (abs(u_barra_pos) + abs(u_barra_neg)) / 2;

    % Marcações
    plot(u_barra_pos, data11.vel(idx_p), 'gx', ...
        'MarkerSize', 12, 'LineWidth', 2);

    plot(u_barra_neg, data12.vel(idx_n), 'gx', ...
        'MarkerSize', 12, 'LineWidth', 2);

    % Texto no gráfico
    text(u_barra_pos, data11.vel(idx_p), ...
        ['  u_{+} = ' num2str(u_barra_pos, '%.2f')], ...
        'FontSize', 10, 'FontWeight', 'bold');

    text(u_barra_neg, data12.vel(idx_n), ...
        ['  u_{-} = ' num2str(u_barra_neg, '%.2f')], ...
        'FontSize', 10, 'FontWeight', 'bold');

    % Output
    fprintf('\n--- RESULTADOS 2.5 ---\n');
    fprintf('u_barra+ = %.2f\n', u_barra_pos);
    fprintf('u_barra- = %.2f\n', u_barra_neg);
    fprintf('c = %.2f\n', c_est);

else
    warning('Ajustar limiar!');
    u_barra_pos = NaN;
    u_barra_neg = NaN;
    c_est = NaN;
end

% Guardar figura em PNG
saveas(figure(22), 'Fig22_ZonaMorta.png');

% ===============================
% GUARDAR RESULTADOS
% ===============================
save('Lab1_resultados_25.mat', ...
    'u_barra_pos', 'u_barra_neg', 'c_est');

% --------------------------------------------------------------------------------------------

%% 3 - Identificação por resposta ao degrau (Questões 2.6 L e 2.7 L)

% ===============================
% CARREGAR DADOS (opcional)
% ===============================
% Descomentar load se repetir em casa!
load('Lab1_dados_Fase1.mat');

% ===============================
% GRÁFICO 1 - DADOS BRUTOS DO DEGRAU
% ===============================
figure(31);

subplot(2,1,1);
plot(data2.time, data2.u, 'r', 'LineWidth', 1.1);
grid on;
xlabel('Tempo [s]');
ylabel('u [PWM]');
title('Sinal de comando - resposta ao degrau');

subplot(2,1,2);
plot(data2.time, data2.vel, 'b', 'LineWidth', 1.1);
grid on;
xlabel('Tempo [s]');
ylabel('\omega [rad/s]');
title('Velocidade angular - resposta ao degrau');

% Guardar figura em PNG
saveas(figure(31), 'Fig31_DegrauBruto.png');

% ===============================
% GRÁFICO 2 - ANÁLISE COM MARCAÇÕES
% ===============================
figure(32);
plot(data2.time, data2.vel, 'b', 'LineWidth', 1.1); hold on;
grid on;
xlabel('Tempo [s]');
ylabel('\omega [rad/s]');
title('Identificação dos parâmetros pelo método dos 63.2%');

% ===============================
% PARÂMETROS DOS DOIS DEGRAUS
% ===============================
t_degraus = [1, 10];          % instantes dados no guia
janela_analise = 5;           % segundos após cada degrau (alterar se erro)
cores = ['m', 'g'];

fprintf('\n--- RESULTADOS 2.6 (DEGRAU) ---\n');

for i = 1:2

    t0 = t_degraus(i);

    % Janela local de análise
    idx_janela = find(data2.time >= t0 & data2.time <= t0 + janela_analise);
    t_local = data2.time(idx_janela);
    u_local = data2.u(idx_janela);
    v_local = data2.vel(idx_janela);

% Valor inicial e final da entrada usando pontos antes e depois do degrau
idx_pre = find(data2.time < t0, 1, 'last');
idx_pos = find(data2.time > t0 + 0.2, 1, 'first');

u_inicial = data2.u(idx_pre);
u_final   = data2.u(idx_pos);

% Valor inicial e final da velocidade na janela de análise
v_inicial = v_local(1);
v_final   = mean(v_local(end-20:end));

    % Variações incrementais
    delta_u = u_final - u_inicial;
    delta_v = v_final - v_inicial;

    % Ganho estático
    k0_est = delta_v / delta_u;

    % Valor correspondente a 63.2%
    v_63 = v_inicial + 0.632 * delta_v;

    % Encontrar instante correspondente aos 63.2%
    idx_63 = find(v_local >= v_63, 1, 'first');

    if isempty(idx_63)
        warning('Não foi possível detetar o ponto de 63.2%% para o degrau em t = %.1f s.', t0);
        t_63 = NaN;
        tau_est = NaN;
        a_est = NaN;
    else
        t_63 = t_local(idx_63);
        tau_est = t_63 - t0;
        a_est = 1 / tau_est;
    end

    % Guardar variáveis separadas para cada degrau
    if i == 1
        t0_1 = t0;
        u0_1 = u_inicial;
        uf_1 = u_final;
        w0_1 = v_inicial;
        wf_1 = v_final;
        du_1 = delta_u;
        dw_1 = delta_v;
        t63_1 = t_63;
        tau_1 = tau_est;
        k0_1 = k0_est;
        a_1 = a_est;
    else
        t0_2 = t0;
        u0_2 = u_inicial;
        uf_2 = u_final;
        w0_2 = v_inicial;
        wf_2 = v_final;
        du_2 = delta_u;
        dw_2 = delta_v;
        t63_2 = t_63;
        tau_2 = tau_est;
        k0_2 = k0_est;
        a_2 = a_est;
    end

    % Marcação no gráfico
    if ~isnan(t_63)
        plot(t_63, v_63, [cores(i) 'x'], 'MarkerSize', 12, 'LineWidth', 2);
        yline(v_final, [cores(i) '--'], 'LineWidth', 1.0);
        text(t_63, v_63, ['  63.2% @ t = ' num2str(t_63, '%.2f') ' s'], ...
            'FontSize', 9, 'FontWeight', 'bold');
    end

    % Output na command window
    fprintf('Degrau em t = %.1f s:\n', t0);
    fprintf('  delta_u = %.3f\n', delta_u);
    fprintf('  delta_w = %.3f\n', delta_v);
    fprintf('  k0      = %.4f\n', k0_est);
    fprintf('  tau     = %.4f s\n', tau_est);
    fprintf('  a       = %.4f s^-1\n', a_est);
end

% Guardar figura em PNG
saveas(figure(32), 'Fig32_Degrau632.png');

% ===============================
% DEFINIR ESTIMATIVAS FINAIS (2.7)
% ===============================
% Pelo guia, o segundo par será o par final a usar
k0_hat = k0_2;
a_hat  = a_2;

fprintf('--------------------------------\n');
fprintf('Estimativas finais escolhidas:\n');
fprintf('  k0_hat = %.4f\n', k0_hat);
fprintf('  a_hat  = %.4f s^-1\n', a_hat);
fprintf('--------------------------------\n');

% ===============================
% GUARDAR RESULTADOS DA 2.6 / 2.7
% ===============================
save('Lab1_resultados_26_27.mat', ...
    't0_1', 'u0_1', 'uf_1', 'w0_1', 'wf_1', 'du_1', 'dw_1', 't63_1', 'tau_1', 'k0_1', 'a_1', ...
    't0_2', 'u0_2', 'uf_2', 'w0_2', 'wf_2', 'du_2', 'dw_2', 't63_2', 'tau_2', 'k0_2', 'a_2', ...
    'k0_hat', 'a_hat');

% --------------------------------------------------------------------------------------------

%% 4 - Resposta em frequência (Questões 2.8 L e base para 2.9)
%
% ===============================
% ORGANIZAÇÃO DO BLOCO 4
% ===============================
% Este bloco está dividido em duas partes:
%
% 4A - Aquisição experimental:
%      corre apenas no laboratório;
%      chama o motor;
%      guarda os dados brutos em Lab1_resultados_28.mat.
%
% 4B - Processamento dos dados:
%      pode correr em casa;
%      NÃO chama o motor;
%      carrega Lab1_resultados_28.mat;
%      calcula amplitudes, ganhos, tabela e gráficos.
%
% ATENÇÃO!!!!!!!!
% Não repetir bloco 4A em casa que perco os dados exprimentais
% Backup de Lab1_resultados_28.mat para não perder os dados experimentais!

% ===========================================
% 0 - ESCOLHA DO MODO DE EXECUÇÃO - Segurança
% ===========================================
modo_aquisicao = input('Deseja iniciar nova aquisição experimental? (s/n): ', 's');

% ===============================
% CARREGAR RESULTADOS DE 2.6/2.7
% ===============================
load('Lab1_resultados_26_27.mat');   % k0_hat, a_hat

% ===============================
% 1 - CÁLCULO DAS FREQUÊNCIAS DE ENSAIO
% ===============================
% Frequências no intervalo [a_hat/10, 10*a_hat]
freqs_testar = logspace(log10(a_hat/10), log10(a_hat*10), 5);

fprintf('\n--- FREQUÊNCIAS PROPOSTAS PARA 2.8 ---\n');
fprintf('a_hat = %.4f rad/s\n', a_hat);
fprintf('Frequências calculadas [rad/s]:\n');
disp(freqs_testar.');

% ============================================================
% 4A - AQUISIÇÃO EXPERIMENTAL DA RESPOSTA EM FREQUÊNCIA
% ============================================================
if lower(strtrim(modo_aquisicao)) == 's'

    % ===============================
    % 2 - VALIDAÇÃO MANUAL ANTES DE AVANÇAR
    % ===============================
    resposta = input('Deseja prosseguir com estas frequências? (s/n): ', 's');

    if lower(strtrim(resposta)) ~= 's'
        disp('Aquisição de resposta em frequência cancelada para ajuste manual.');
        return;
    end

    % ===============================
    % 3 - INICIALIZAÇÃO DAS VARIÁVEIS DE AQUISIÇÃO
    % ===============================
    n_freq = length(freqs_testar);

    wf_col      = zeros(n_freq,1);
    tfinal_col  = zeros(n_freq,1);
    data3_cell  = cell(n_freq,1);

    % ===============================
    % 4 - CICLO DE AQUISIÇÃO
    % ===============================
    for i = 1:n_freq

        wf = freqs_testar(i);

        % Duração do ensaio:
        % usar pelo menos 8 períodos ou, no mínimo, 20 s
        T = 2*pi / wf;
        t_final = max(20, 8*T);

        fprintf('\nA correr ensaio %d/%d | wf = %.4f rad/s | t_final = %.2f s\n', ...
            i, n_freq, wf, t_final);

        % Aquisição experimental
        data3 = run_experiment_Matlab2023(3, wf, t_final);

        % Guardar dados brutos
        data3_cell{i} = data3;
        wf_col(i) = wf;
        tfinal_col(i) = t_final;
    end

    % ===============================
    % 5 - GUARDAR DADOS BRUTOS DA 2.8
    % ===============================
    save('Lab1_resultados_28.mat', ...
        'a_hat', 'k0_hat', ...
        'freqs_testar', 'wf_col', 'tfinal_col', ...
        'data3_cell');

    disp(' ');
    disp('Dados brutos da 2.8 guardados em Lab1_resultados_28.mat.');
    disp('Segue-se o processamento dos dados no Bloco 4B.');

else

    % ===============================
    % VERIFICAR SE EXISTEM DADOS PARA PROCESSAR
    % ===============================
    if ~isfile('Lab1_resultados_28.mat')
        error(['Ficheiro em falta: Lab1_resultados_28.mat. ', ...
               'Não é possível processar os dados da 2.8 sem este ficheiro.']);
    end

end

% ============================================================
% 4B - PROCESSAMENTO DOS DADOS DA RESPOSTA EM FREQUÊNCIA
% ============================================================

% ===============================
% 6 - CARREGAR DADOS EXPERIMENTAIS DA 2.8
% ===============================
load('Lab1_resultados_28.mat');

% Verificação mínima das variáveis necessárias
if ~exist('data3_cell','var') || ~exist('wf_col','var') || ~exist('tfinal_col','var')
    error(['O ficheiro Lab1_resultados_28.mat não contém as variáveis necessárias ', ...
           'data3_cell, wf_col e tfinal_col.']);
end

n_freq = length(wf_col);

Ain_col    = zeros(n_freq,1);
Aout_col   = zeros(n_freq,1);
GainDB_col = zeros(n_freq,1);

% Cores consistentes para entrada/saída da mesma frequência
cores = lines(n_freq);

% ===============================
% 7 - FIGURA DOS SINAIS EM REGIME ESTACIONÁRIO
% ===============================
figure(100); clf;

subplot(2,1,1);
hold on; grid on;
title('Entradas sinusoidais em regime estacionário');
xlabel('Ciclos desde o início da janela');
ylabel('u [PWM]');

subplot(2,1,2);
hold on; grid on;
title('Respostas em velocidade em regime estacionário');
xlabel('Ciclos desde o início da janela');
ylabel('\omega [rad/s]');

% ===============================
% 8 - PROCESSAMENTO DE CADA FREQUÊNCIA
% ===============================
for i = 1:n_freq

    data3 = data3_cell{i};
    wf = wf_col(i);

    T = 2*pi / wf;

    % ===============================
    % 8.1 - SELEÇÃO DO REGIME ESTACIONÁRIO
    % ===============================
    % Selecionar apenas a zona em que a entrada sinusoidal está ativa.
    % Isto evita usar a parte final em que o comando pode já estar a zero.
    idx_u_ativo = find(abs(data3.u) > 1);

    if isempty(idx_u_ativo)
        warning('Sem zona ativa detetada para wf = %.4f rad/s.', wf);
        Ain_col(i) = NaN;
        Aout_col(i) = NaN;
        GainDB_col(i) = NaN;
        continue;
    end

    t_inicio = data3.time(idx_u_ativo(1));
    t_fim    = data3.time(idx_u_ativo(end));

    % Usar os últimos ciclos úteis da zona ativa.
    % Isto evita:
    % - a zona parada no primeiro ensaio;
    % - o transitório inicial nas frequências mais elevadas.
    n_ciclos_ss = 3;
    t_inicio_ss = max(t_inicio + T, t_fim - n_ciclos_ss*T);

    idx_ss = find(data3.time >= t_inicio_ss & ...
                  data3.time <= t_fim);

    if isempty(idx_ss)
        warning('Janela de regime estacionário vazia para wf = %.4f rad/s.', wf);
        Ain_col(i) = NaN;
        Aout_col(i) = NaN;
        GainDB_col(i) = NaN;
        continue;
    end

    t_ss   = data3.time(idx_ss);
    u_ss   = data3.u(idx_ss);
    vel_ss = data3.vel(idx_ss);

    % Para comparar frequências diferentes, representar o eixo horizontal
    % em número de ciclos desde o início da janela selecionada.
    t_ss_cycles = (t_ss - t_ss(1)) / T;

    % ===============================
    % 8.2 - VALIDAÇÃO VISUAL DOS SINAIS
    % ===============================
    subplot(2,1,1);
    plot(t_ss_cycles, u_ss, 'Color', cores(i,:), 'LineWidth', 1.1, ...
        'DisplayName', ['\omega_f = ' num2str(wf, '%.2f') ' rad/s']);

    subplot(2,1,2);
    plot(t_ss_cycles, vel_ss, 'Color', cores(i,:), 'LineWidth', 1.1, ...
        'DisplayName', ['\omega_f = ' num2str(wf, '%.2f') ' rad/s']);

    % ===============================
    % 8.3 - EXTRAÇÃO DAS AMPLITUDES
    % ===============================
    % Amplitude = metade do valor pico-a-pico
    A_in  = (max(u_ss)   - min(u_ss))   / 2;
    A_out = (max(vel_ss) - min(vel_ss)) / 2;

    % Ganho em dB
    g_db = 20*log10(A_out / A_in);

    Ain_col(i)    = A_in;
    Aout_col(i)   = A_out;
    GainDB_col(i) = g_db;

    fprintf('\nwf = %.4f rad/s\n', wf);
    fprintf('  A_in  = %.4f\n', A_in);
    fprintf('  A_out = %.4f\n', A_out);
    fprintf('  Gain  = %.4f dB\n', g_db);
end

% ===============================
% 9 - FINALIZAR FIGURA DOS SINAIS
% ===============================
subplot(2,1,1);
legend('Location', 'bestoutside');

subplot(2,1,2);
legend('Location', 'bestoutside');

figure(100);
saveas(gcf, 'Fig4_SinaisRegimeEstacionario_Comparados.png');

% ===============================
% 10 - CRIAÇÃO DA TABELA FINAL
% ===============================
TabelaResumo = table(wf_col, tfinal_col, Ain_col, Aout_col, GainDB_col, ...
    'VariableNames', {'Frequencia_rads', 't_final_s', ...
                      'Amp_Entrada', 'Amp_Saida', 'Ganho_dB'});

disp(' ');
disp('--- TABELA 1 FINAL ---');
disp(TabelaResumo);

% ===============================
% 11 - GRÁFICO DE BODE EXPERIMENTAL
% ===============================
figure(40); clf;
semilogx(wf_col, GainDB_col, 'o-', ...
    'Color', [0 0.447 0.741], ...
    'LineWidth', 1.8, ...
    'MarkerFaceColor', [0 0.447 0.741]);

grid on;
xlabel('Frequência [rad/s]');
ylabel('Ganho [dB]');
title('Diagrama de Bode Experimental');

saveas(gcf, 'Fig40_BodeExperimental.png');

% ===============================
% 12 - GUARDAR RESULTADOS PROCESSADOS DA 2.8
% ===============================
save('Lab1_resultados_28.mat', ...
    'a_hat', 'k0_hat', ...
    'freqs_testar', 'wf_col', 'tfinal_col', ...
    'Ain_col', 'Aout_col', 'GainDB_col', ...
    'TabelaResumo', 'data3_cell');

disp(' ');
disp('Resultados da 2.8 guardados em Lab1_resultados_28.mat - Fim do bloco 4');

% --------------------------------------------------------------------------------------------

%% 5 - Bode aproximado e novas estimativas (Questão 2.9 L)
% Usa os resultados experimentais da 2.8 para:
% 1) estimar o ganho de baixa frequência;
% 2) estimar a frequência de corte;
% 3) obter novas estimativas de k0 e a;
% 4) comparar essas estimativas com o modelo identificado por degrau (2.6);
% 5) desenhar no mesmo gráfico:
%    - os pontos experimentais do Bode,
%    - a curva teórica do modelo de 1ª ordem obtido em 2.6,
%    - as assíntotas aproximadas de baixa e alta frequência.

% ===============================
% CARREGAR RESULTADOS (opcional)
% ===============================
% Descomentar load se repetir em casa!
load('Lab1_resultados_28.mat');
load('Lab1_resultados_26_27.mat');

% ===============================
% 1 - ESTIMATIVA DO GANHO DE BAIXA FREQUÊNCIA
% ===============================
% Decisão validada: usar a média dos 2 primeiros pontos
G_lf_db = mean(GainDB_col(1:2));

% Conversão para escala linear
k0_bode = 10^(G_lf_db/20);

% Nível de corte (-3 dB relativamente ao patamar de baixa frequência)
G_cut_db = G_lf_db - 3;

% ===============================
% 2 - ESTIMATIVA DA FREQUÊNCIA DE CORTE
% ===============================
% Decisão validada: usar o ponto experimental mais próximo de G_cut_db
[~, idx_cut] = min(abs(GainDB_col - G_cut_db));
wc_est = wf_col(idx_cut);

% Para um sistema de 1ª ordem, a ~ wc
a_bode = wc_est;

% ===============================
% 3 - ASSÍNTOTAS DO BODE APROXIMADO
% ===============================
w_asym = logspace(log10(min(wf_col)/1.5), log10(max(wf_col)*1.5), 200);

% Assíntota de baixa frequência: horizontal
GainLF_asym = G_lf_db * ones(size(w_asym));

% Assíntota de alta frequência: -20 dB/década a partir de wc_est
GainHF_asym = G_lf_db - 20*log10(w_asym / wc_est);

% Para visualização limpa, limitar cada assíntota à sua zona
GainHF_plot = GainHF_asym;
GainHF_plot(w_asym < wc_est) = NaN;

GainLF_plot = GainLF_asym;
GainLF_plot(w_asym > wc_est) = NaN;

% ===============================
% 4 - MODELO TEÓRICO OBTIDO NA 2.6
% ===============================
% Curva teórica do Bode usando k0_hat e a_hat (vinda do degrau)
G_model_mag = (k0_hat * a_hat) ./ sqrt(w_asym.^2 + a_hat^2);
G_model_db = 20*log10(G_model_mag);

% ===============================
% 5 - GRÁFICO FINAL SOBREPOSTO
% ===============================
figure(50); clf;

% Pontos experimentais
semilogx(wf_col, GainDB_col, 'ko', ...
    'MarkerSize', 7, 'MarkerFaceColor', 'g', ...
    'DisplayName', 'Bode experimental'); hold on;

% Curva teórica da 2.6
semilogx(w_asym, G_model_db, 'b-', ...
    'LineWidth', 1.4, ...
    'DisplayName', 'Modelo teórico (2.6)');

% Assíntota de baixa frequência
semilogx(w_asym, GainLF_plot, 'r--', ...
    'LineWidth', 1.3, ...
    'DisplayName', 'Assíntota baixa frequência');

% Assíntota de alta frequência
semilogx(w_asym, GainHF_plot, 'm--', ...
    'LineWidth', 1.3, ...
    'DisplayName', 'Assíntota alta frequência');

% Linha vertical na frequência de corte estimada
xline(wc_est, 'c--', ...
    'LineWidth', 1.2, ...
    'DisplayName', ['\omega_c \approx ' num2str(wc_est, '%.2f') ' rad/s']);

grid on;
grid minor;
xlabel('Frequência [rad/s]');
ylabel('Ganho [dB]');
title('Bode experimental e comparação com o modelo identificado');
legend('Location', 'southwest');

% Guardar figura em PNG
figure(50);
saveas(gcf, 'Fig50_BodeComparacao.png');

% ===============================
% 6 - OUTPUT PARA RELATÓRIO
% ===============================
fprintf('\n--- RESULTADOS 2.9 (BODE) ---\n');
fprintf('Ganho de baixa frequência (dB): %.3f dB\n', G_lf_db);
fprintf('k0 estimado por Bode:           %.4f\n', k0_bode);
fprintf('Nível de corte (-3 dB):         %.3f dB\n', G_cut_db);
fprintf('Frequência de corte estimada:   %.4f rad/s\n', wc_est);
fprintf('a estimado por Bode:            %.4f rad/s\n', a_bode);
fprintf('--------------------------------\n');

fprintf('\n--- COMPARAÇÃO COM 2.6 ---\n');
fprintf('k0_hat (degrau): %.4f | k0_bode: %.4f\n', k0_hat, k0_bode);
fprintf('a_hat  (degrau): %.4f | a_bode : %.4f\n', a_hat, a_bode);
fprintf('--------------------------\n');

% ===============================
% 7 - GUARDAR RESULTADOS DA 2.9
% ===============================

save('Lab1_resultados_29.mat', ...
    'G_lf_db', 'k0_bode', 'G_cut_db', 'idx_cut', 'wc_est', 'a_bode', ...
    'w_asym', 'GainLF_asym', 'GainHF_asym', ...
    'GainLF_plot', 'GainHF_plot', 'G_model_db', ...
    'wf_col', 'GainDB_col');

disp('Resultados da 2.9 guardados em Lab1_resultados_29.mat - Fim de bloco 5');