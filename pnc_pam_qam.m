clear;
clc;
close all;

pkg load signal;
pkg load communications;

##########################################################################
##########################  СИМУЛЯЦИЯ БЕЗ AWGN  ##########################
##########################################################################

## ПАРАМЕТРЫ

% Размер PAM-созвездия
M = 4;
k = log2(M);
ph0 = 0; # начальная фаза

% Генерация данных
N = 1000; % Объем данных
s1_data = randi([0, M-1], 1, N);
s2_data = randi([0, M-1], 1, N);


## 1. Передача по каналу "источник-ретранслятор"

% PAM-модуляция
s1 = pammod(s1_data, M, ph0); s1 = complex(real(s1), imag(s1));
s2 = pammod(s2_data, M, ph0); s2 = complex(real(s2), imag(s2));


## 2. Преобразования на ретранслятора

% Поворот созвездия s2 на pi/2 (для демонстрации на графике)
rs2 = s2 .* 1i;

% Преобразование двух M-PAM в M^2-QAM
r = pam2qam( s1, s2 );


## 3. Извлечение данных на источниках

s1_recovered = [];
s2_recovered = [];

% Извлечение I- и Q-составляющих из QAM-символов ретранслятора
for i = 1:1:length(r)
    Q = imag(r(i));
    I = real(r(i));
    s1_recovered = [ s1_recovered, complex(I, 0) ];
    s2_recovered = [ s2_recovered, complex(Q, 0) ];
endfor

ds1_data = pamdemod(s1_recovered, M, ph0);
ds2_data = pamdemod(s2_recovered, M, ph0);

serr1 = 0;
serr2 = 0;

for i = 1:1:length(s1_recovered)
    if (ds1_data(i) != s1_data(i))
        serr1 = serr1 + 1;
    endif
    if (ds2_data(i) != s2_data(i))
        serr2 = serr2 + 1;
    endif
endfor


## ПОСТРОЕНИЕ ГРАФИКОВ

f1 = figure();
pl1 = plot(real(s1), imag(s1), 'rx', 'MarkerSize', 7, 'LineWidth', 2);
title(strcat(num2str(M), '-PAM источника №1 на ретрансляторе'));
xlabel('I');
ylabel('Q');
set(gca, 'FontSize', 20);
grid on;

f2 = figure();
pl2 = plot(real(rs2), imag(rs2), 'rx', 'MarkerSize', 7, 'LineWidth', 2);
title(strcat(num2str(M), '-PAM источника №2 на ретрансляторе'));
xlabel('I');
ylabel('Q');
set(gca, 'FontSize', 20);
grid on;

f3 = figure();
pl3 = plot(real(r), imag(r), 'rx', 'MarkerSize', 7, 'LineWidth', 2);
title(strcat(num2str(M^2), '-QAM модуляция на ретрансляторе'));
xlabel('I');
ylabel('Q');
set(gca, 'FontSize', 20);
grid on;
