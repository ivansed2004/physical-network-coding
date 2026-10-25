function qam = pam2qam( pam1, pam2 )
% PAM2QAM  Формирует M^2-QAM созвездие из M-PAM
%
% Вход:
%   pam1 — вектор из M комплексных чисел вида a+0i (точки M-PAM) первого источника
%   pam2 — вектор из M комплексных чисел вида b+0i (точки M-PAM) второго источника
%
% Выход:
%   qam — вектор-строка из M^2 комплексных чисел вида a+bi

    pam1_i = pam1(:);
    M      = numel(pam1_i);

    % Принудительное преобразование в комплексное число
    if ~iscomplex(pam1_i)
        pam1_i = complex(real(pam1_i), zeros(M, 1));
    end

    % Поворот на pi/2
    pam2_q = pam2 * 1i;

    I = real(pam1_i);
    Q = imag(pam2_q);

    % Формирование комплексных точек (a + bi)
    qam = [];
    for i = 1:1:length(pam1_i)
        qam = [qam, complex( I(i), Q(i) )];
    endfor

end
