% Inverter
clear;
close all;
clc;

% -----------------------------------------------
% --------------  SIMULATION  -------------------
% -----------------------------------------------
% parameters
samples = 72000;
w = (2 * pi) / samples;
V_in = 17;
time = 1:samples;

% clarke transform (code)
V_A = V_in * sin(w * time);
% V_B = V_in * sin(w * time - 2 * pi / 3);
% V_C = V_in * sin(w * time - 4 * pi / 3);

% -----------------------------------------------
% ------------  SIGNAL PROCESSING  --------------
% -----------------------------------------------
% establecemos el maximo que encontramos en el ADC
maximo_adc = 4010;

% establecemos valor maximo a llegar
valor_escala = 18000;

% generamos la onda
V_A = V_A / V_in;
V_A = int32(round(abs(maximo_adc * V_A)));
% plot and save
figure;
plot(time, V_A);
title('Adquisicion de la Señal');
xlabel('Tiempo (muestras)');
ylabel('Amplitud (ADC)');
ylim([0, 4096]);
saveas(gcf, 'new/V_A_Recibida.png');

% ahora le aplicamos el tratamiento de escala
V_A = int32(round((V_A * valor_escala) / maximo_adc));

% plot and save
figure;
plot(time, V_A);
title('Procesamiento de la Señal');
xlabel('Tiempo (muestras)');
ylabel('Amplitud (ADC)');
saveas(gcf, 'new/V_A_Escalada.png');

% ----------------------------------------------------------
% ------------------------ ANGLE SUM -----------------------
% ----------------------------------------------------------
% Calculate cumulative sum of phase angle differences
adc_sum = zeros(1, samples);
adc_sum(1) = V_A(1);

for i = 2:samples
    % calculate the consecutive difference
    difference = abs(V_A(i) - V_A(i - 1));

    % make the cumulative sum
    adc_sum(i) = adc_sum(i - 1) + difference;

end

% save adc_sum for debug
% fileID = fopen('adc_sum.txt', 'w');
% fprintf(fileID, '%d\n', adc_sum);
% fclose(fileID);

max_adc_sum = max(adc_sum);

% plot and save
figure;
plot(time, adc_sum);
title('Suma Acumulativa');
xlabel('Tiempo (muestras)');
ylabel('Valor Acumulado (ADC)');
saveas(gcf, 'new/Suma_Angulos.png');

% ----------------------------------------------------------
% -------------------------- MASK --------------------------
% ----------------------------------------------------------
% getting pulses and sextants
sextant = zeros(1, samples);
pulse1 = zeros(1, samples);
pulse2 = zeros(1, samples);

% for i = 1:samples
%     aux = Mask(adc_sum(i));
%     sextant(i) = aux(1);
%     pulse1(i) = aux(2);
%     pulse2(i) = aux(3);
% end

% pulse1 = int32(round(72000 * pulse1));
% pulse2 = int32(round(72000 * pulse2));

% % just for the LUT
% % save this data to lut
% fileID = fopen('sextant.txt', 'w');
% fprintf(fileID, '%d, ', sextant);
% fclose(fileID);
% fileID = fopen('pulse1.txt', 'w');
% fprintf(fileID, '%d, ', pulse1);
% fclose(fileID);
% fileID = fopen('pulse2.txt', 'w');
% fprintf(fileID, '%d, ', pulse2);
% fclose(fileID);

% load the data from the files
sextant_data = load('sextant.txt');
pulse1_data = load('pulse1.txt');
pulse2_data = load('pulse2.txt');
% use a for loop to assign the data to the value of the adc_sum
for i = 1:samples
    indice_suma = adc_sum(i);
    if (indice_suma == 0)
        indice_suma = 1;
    end
    sextant(i) = sextant_data(indice_suma);
    pulse1(i) = pulse1_data(indice_suma);
    pulse2(i) = pulse2_data(indice_suma);
end


% plot and save
figure;
plot(time, sextant);
title('Asignación de los Sextantes');
xlabel('Tiempo (muestras)');
ylabel('Sextante');
saveas(gcf, 'new/Sextante.png');

% plot and save
figure;
plot(time, pulse1);
hold on;
plot(time, pulse2);
title('Razón entre las Fases');
xlabel('Tiempo (muestras)');
ylabel('Amplitud (ADC)');
legend('Cociente 1', 'Cociente 2');
ylim([0, 72e3]);
saveas(gcf, 'new/Pulsos.png');


% ----------------------------------------------------------
% ------------------------ SAWTOOTH ------------------------
% ----------------------------------------------------------
% now the sawtooth signal is a rect from 0,0 to samples, max_adc_sum
sawtoothSignal = zeros(1, samples);

for i = 1:samples
    sawtoothSignal(i) = int32(round((max_adc_sum / samples) * i));
end

% plot and save
figure;
plot(time, sawtoothSignal);
title('Creación de Señal Rampa');
xlabel('Tiempo (muestras)');
ylabel('Amplitud (ADC)');
saveas(gcf, 'new/Diente_de_Sierra.png');

% ----------------------------------------------------------
% ------------------- SUPERPUESTAS -------------------------
% ----------------------------------------------------------
% plot and save the sawtooth signal and the sum of angles together
figure;
plot(time, adc_sum);
hold on;
plot(time, sawtoothSignal);
title('Señales Superpuestas');
xlabel('Tiempo (muestras)');
ylabel('Amplitud (ADC)');
legend('Suma de Angulos', 'Señal Diente de Sierra');
saveas(gcf, 'new/Suma_Angulos_Diente_de_Sierra.png');

% ----------------------------------------------------------
% ----------------- COMPARACION DE RAMPAS ------------------
% ----------------------------------------------------------
% creating pwm control signals
switch1 = pulse1 >= sawtoothSignal;
switch2 = ~(pulse1 >= sawtoothSignal);
% plot and save
figure;
plot(time, switch1);
hold on;
plot(time, switch2);
title('Comparacion de Señales');
xlabel('Tiempo (muestras)');
ylabel('Estado de la Señal Comparada');
legend('Switch 1', 'Switch 2');
saveas(gcf, 'new/Comparacion_Rampa.png');

% ----------------------------------------------------------
% -------------------- MASK ASSIGN -------------------------
% ----------------------------------------------------------
% create the pulse mask
S1t = zeros(1, samples);
S2t = zeros(1, samples);
S3t = zeros(1, samples);
S4t = zeros(1, samples);
S5t = zeros(1, samples);
S6t = zeros(1, samples);

for i = time
    aux = MaskAssign(switch1(i), switch2(i), sextant(i));
    S1t(i) = aux(1);
    S2t(i) = aux(2);
    S3t(i) = aux(3);
    S4t(i) = aux(4);

    S5t(i) = aux(5);
    S6t(i) = aux(6);
end

% plot and save
figure;
plot(time, S1t, time, S2t, time, S3t, time, S4t, time, S5t, time, S6t);
title('Activación de los Interruptores');
xlabel('Tiempo (muestras)');
ylabel('Estado del Interruptor');
legend('S_1', 'S_2', 'S_3', 'S_4', 'S_5', 'S_6');
saveas(gcf, 'new/Asignacion_Mascara.png');

close all;