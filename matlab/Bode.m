%% Bode assintótico para a questão 2.4

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