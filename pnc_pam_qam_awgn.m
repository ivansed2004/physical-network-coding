clear;
clc;
close all;

pkg load signal;
pkg load communications;

##########################################################################
###########################  СИМУЛЯЦИЯ С AWGN  ###########################
##########################################################################

## ПАРАМЕТРЫ

% Размер PAM-созвездия
M = 4;
k = log2(M);
ph0 = 0; % начальная фаза
% Параметры шума
SNR = 0:1:20; % диапазон SNR
EbN0 = SNR - 10*log10(k); % диапазон Eb/N0

% Генерация данных
N = 100000; % Объем данных
s1_data = randi([0, M-1], 1, N);
s2_data = randi([0, M-1], 1, N);


## 1. Передача по каналам связи

% PAM-модуляция
s1 = pammod(s1_data, M, ph0); s1 = complex(real(s1), imag(s1));
s2 = pammod(s2_data, M, ph0); s2 = complex(real(s2), imag(s2));

% Вычисление BER
ber = zeros(4, length(EbN0));

for i = 1:1:length(EbN0)
    % Добавление белого шума для M-PAM
    z1 = awgn(s1, SNR(i), 'measured');
    z2 = awgn(s2, SNR(i), 'measured');
    zi2 = z2 .* 1i; % для демонстрации на графике

    % PAM-демодуляция
    ds11_data = pamdemod(z1, M, ph0);
    ds12_data = pamdemod(z2, M, ph0);

    % Подсчет экспериментального BER
    s1_ber = biterr(de2bi(ds11_data(:), k), de2bi(s1_data(:), k)) / (k*N);
    s2_ber = biterr(de2bi(ds12_data(:), k), de2bi(s2_data(:), k)) / (k*N);
    ber(1, i) = s1_ber; ber(2, i) = s2_ber;

    % Преобразование двух M-PAM в M^2-QAM
    r = pam2qam( z1, z2 );

    % Добавление белого шума для M^2-QAM (нормировка для )
    rz1 = awgn(r / sqrt(2), SNR(i), 'measured'); % ретранслятор -> источник №1
    rz2 = awgn(r / sqrt(2), SNR(i), 'measured'); % ретранслятор -> источник №2

    % Извлечение I- и Q-составляющих из QAM-символов ретранслятора
    s1_recovered = []; % данные от 2 источника, восстановленные на стороне 1-го
    s2_recovered = []; % аналогично, но наоборот

    for j = 1:1:length(r)
        Q = imag(rz1(j)); % данные от источника №2
        I = real(rz2(j)); % данные от источника №1
        s1_recovered = [ s1_recovered, complex(Q, 0) ];
        s2_recovered = [ s2_recovered, complex(I, 0) ];
    endfor

    % PAM-демодуляция
    ds21_data = pamdemod(s1_recovered, M, ph0);
    ds22_data = pamdemod(s2_recovered, M, ph0);

    % Подсчет экспериментального BER
    r1_ber = biterr(de2bi(ds21_data(:), k), de2bi(s2_data(:), k)) / (k*N);
    r2_ber = biterr(de2bi(ds22_data(:), k), de2bi(s1_data(:), k)) / (k*N);
    ber(3, i) = r1_ber; ber(4, i) = r2_ber;
end


## ПОСТРОЕНИЕ ГРАФИКОВ

f1 = figure();
pl1 = semilogy(EbN0, ber(1, :), 'ro-', 'MarkerSize', 7, 'LineWidth', 2,
               EbN0, ber(2, :), 'bo-', 'MarkerSize', 7, 'LineWidth', 2,
               EbN0, ber(3, :), 'rx-', 'MarkerSize', 7, 'LineWidth', 2,
               EbN0, ber(4, :), 'bx-', 'MarkerSize', 7, 'LineWidth', 2);
title(strcat('Помехоустойчивость передачи'));
legend({'S1 -> R',
        'S2 -> R',
        'R -> S1',
        'R -> S2'}, 'location', 'northeast', 'fontsize', 5);
xlabel('Eb/N0 (dB)');
ylabel('BER');
set(gca, 'FontSize', 20);
grid on;

f2 = figure();
pl2 = plot(real(z1), imag(z1), 'rx', 'MarkerSize', 7, 'LineWidth', 2);
title(strcat('Созвездие ', num2str(M), '-PAM в канале S1->R'));
xlabel('I');
ylabel('Q');
set(gca, 'FontSize', 20);
grid on;

f3 = figure();
pl3 = plot(real(zi2), imag(zi2), 'bx', 'MarkerSize', 7, 'LineWidth', 2);
title(strcat('Созвездие ', num2str(M), '-PAM в канале S2->R'));
xlabel('I');
ylabel('Q');
set(gca, 'FontSize', 20);
grid on;

f4 = figure();
pl4 = plot(real(r), imag(r), 'kx', 'MarkerSize', 7, 'LineWidth', 2);
title(strcat('Созвездие ', num2str(M^2), '-QAM на R'));
xlabel('I');
ylabel('Q');
set(gca, 'FontSize', 20);
grid on;

f5 = figure();
pl5 = plot(real(rz1), imag(rz2), 'rx', 'MarkerSize', 7, 'LineWidth', 2);
title(strcat('Созвездие ', num2str(M^2), '-QAM на R->S1'));
xlabel('I');
ylabel('Q');
set(gca, 'FontSize', 20);
grid on;

f6 = figure();
pl6 = plot(real(rz1), imag(rz2), 'bx', 'MarkerSize', 7, 'LineWidth', 2);
title(strcat('Созвездие ', num2str(M^2), '-QAM на R->S2'));
xlabel('I');
ylabel('Q');
set(gca, 'FontSize', 20);
grid on;
