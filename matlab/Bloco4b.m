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
% ATENÇÃO:
% Antes de repetir aquisição no laboratório, fazer sempre backup de
% Lab1_resultados_28.mat para não perder os dados experimentais.

% ===============================
% 0 - ESCOLHA DO MODO DE EXECUÇÃO
% ===============================
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
semilogx(wf_col, GainDB_col, 'ks-', ...
    'LineWidth', 1.5, 'MarkerFaceColor', 'g');

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