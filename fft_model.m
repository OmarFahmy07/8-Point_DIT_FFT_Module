%% Credits
% File : fft_model.m
% Author : Omar Fahmy
% Date : 8/12/2022
% Version : 1
% Abstract : model for DIT FFT implemented in fixed-point representation

%% Parameters
clear; clc;
NFFT = 8;
Mod_Index = 1024;
numOfInputs = 6;
Integer_Part = 16;
Fractional_Part = 16;
Data_Width = Integer_Part + Fractional_Part;

%% Mapper
info_data = randi(Mod_Index-1, [NFFT numOfInputs]);
mod_data = qammod(info_data, Mod_Index);

%% Reference FFT Inputs and Outputs
reference_fft_in = ifft(mod_data, NFFT);
reference_fft_out = mod_data;

%% Twiddle Factors
n = (0: 1 : NFFT-1);
twiddle = exp(-1i*2*pi*n/NFFT);

%% Fixed-Point Representation Object
q = quantizer('DataMode', 'fixed', 'Format', [Integer_Part+Fractional_Part Fractional_Part]);

%% Fixed-Point Representation of Inputs
fft_in_fixed_I = num2bin(q, real(reference_fft_in));
fft_in_fixed_Q = num2bin(q, imag(reference_fft_in));

%% Fixed-Point Representation of Twiddle Factors
twiddle_fixed_I = num2bin(q, real(twiddle));
twiddle_fixed_Q = num2bin(q, imag(twiddle));

%% Write Inputs in an External Text File
fileID1 = fopen('inputs_real.txt', 'w');
for i = 1 : size(fft_in_fixed_I,1)
    if i == size(fft_in_fixed_I,1)
      fprintf(fileID1, '%s', fft_in_fixed_I(i, :));
    else
      fprintf(fileID1, '%s\n', fft_in_fixed_I(i, :));
    end
end
fileID2 = fopen('inputs_imag.txt', 'w');
for i = 1 : size(fft_in_fixed_Q,1)
    if i == size(fft_in_fixed_Q,1)
      fprintf(fileID2, '%s', fft_in_fixed_Q(i, :));
    else
      fprintf(fileID2, '%s\n', fft_in_fixed_Q(i, :));
    end
end

%% Write Twiddle Factors in an External Text File
fileID3 = fopen('twiddle_real.txt', 'w');
for i = 1 : size(twiddle_fixed_I,1)
    if i == size(twiddle_fixed_I,1)
      fprintf(fileID3, '%s', twiddle_fixed_I(i, :));
    else
      fprintf(fileID3, '%s\n', twiddle_fixed_I(i, :));
    end
end
fileID4 = fopen('twiddle_imag.txt', 'w');
for i = 1 : size(twiddle_fixed_Q,1)
    if i == size(twiddle_fixed_Q,1)
      fprintf(fileID4, '%s', twiddle_fixed_Q(i, :));
    else
      fprintf(fileID4, '%s\n', twiddle_fixed_Q(i, :));
    end
end

%% Butterfly Units
% butterfly0_out0 = reference_fft_in(1,1) + reference_fft_in(5,1) * twiddle(1);
% butterfly0_out1 = reference_fft_in(1,1) - reference_fft_in(5,1) * twiddle(1);
% 
% butterfly1_out0 = reference_fft_in(3,1) + reference_fft_in(7,1) * twiddle(1);
% butterfly1_out1 = reference_fft_in(3,1) - reference_fft_in(7,1) * twiddle(1);
% 
% butterfly2_out0 = reference_fft_in(2,1) + reference_fft_in(6,1) * twiddle(1);
% butterfly2_out1 = reference_fft_in(2,1) - reference_fft_in(6,1) * twiddle(1);
% 
% butterfly3_out0 = reference_fft_in(4,1) + reference_fft_in(8,1) * twiddle(1);
% butterfly3_out1 = reference_fft_in(4,1) - reference_fft_in(8,1) * twiddle(1);
% 
% butterfly4_out0 = butterfly0_out0 + butterfly1_out0 * twiddle(1);
% butterfly4_out1 = butterfly0_out0 - butterfly1_out0 * twiddle(1);
% 
% butterfly5_out0 = butterfly0_out1 + butterfly1_out1 * twiddle(3);
% butterfly5_out1 = butterfly0_out1 - butterfly1_out1 * twiddle(3);
% 
% butterfly6_out0 = butterfly2_out0 + butterfly3_out0 * twiddle(1);
% butterfly6_out1 = butterfly2_out0 - butterfly3_out0 * twiddle(1);
% 
% butterfly7_out0 = butterfly2_out1 + butterfly3_out1 * twiddle(3);
% butterfly7_out1 = butterfly2_out1 - butterfly3_out1 * twiddle(3);
% 
% butterfly8_out0 = butterfly4_out0 + butterfly6_out0 * twiddle(1);
% butterfly8_out1 = butterfly4_out0 - butterfly6_out0 * twiddle(1);
% 
% butterfly9_out0 = butterfly5_out0 + butterfly7_out0 * twiddle(2);
% butterfly9_out1 = butterfly5_out0 - butterfly7_out0 * twiddle(2);
% 
% butterfly10_out0 = butterfly4_out1 + butterfly6_out1 * twiddle(3);
% butterfly10_out1 = butterfly4_out1 - butterfly6_out1 * twiddle(3);
% 
% butterfly11_out0 = butterfly5_out1 + butterfly7_out1 * twiddle(4);
% butterfly11_out1 = butterfly5_out1 - butterfly7_out1 * twiddle(4);

%% Reading RTL Output Files
fileID5 = fopen('../outputs_real.txt','r');
fileID6 = fopen('../outputs_imag.txt','r');
temp1 = fscanf(fileID5, '%s');
temp2 = fscanf(fileID6, '%s');
rtlOutDecFileReal = [];
rtlOutDecFileImag = [];
temp3 = [];
temp4 = [];
for j = 0 : numOfInputs-1
    for i = 1 + j * NFFT * Data_Width : Data_Width : 1 + j * NFFT * Data_Width + (NFFT - 1) * Data_Width
        temp3 = [temp3; temp1(i : i + Data_Width -1)];
        temp4 = [temp4; temp2(i : i + Data_Width -1)];
    end
    rtlOutDecFileReal = [rtlOutDecFileReal q2dec(temp3, Integer_Part-1, Fractional_Part, 'bin')];
    rtlOutDecFileImag = [rtlOutDecFileImag q2dec(temp4, Integer_Part-1, Fractional_Part, 'bin')];
    temp3 = [];
    temp4 = [];
end
rtl_fft_out = rtlOutDecFileReal + 1i * rtlOutDecFileImag;

%% Calculate the Average Error Percentage
error = abs(reference_fft_out - rtl_fft_out);
average_err = mean(mean(error)) * 100;

%% Close All Opened Files
fclose(fileID1);
fclose(fileID2);
fclose(fileID3);
fclose(fileID4);
fclose(fileID5);
fclose(fileID6);