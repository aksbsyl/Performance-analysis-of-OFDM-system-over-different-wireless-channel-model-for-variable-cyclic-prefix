clc; 
clear all;
close all;
%..............................................................
% Initiation
%..............................................................
no_of_data_bits = 64%Number of bits per channel extended to 128
M =4 %Number of subcarrier channel
n=256;%Total number of bits to be transmitted at the transmitter
block_size = 16; %Size of each OFDM block to add cyclic prefix
cp_len = floor(0.1 * block_size); %Length of the cyclic prefix
%............................................................
% Transmitter
%.........................................................
%.........................................................
% Source generation and modulation
%........................................................
% Generate random data source to be transmitted of length 64
data = randsrc(1, no_of_data_bits, 0:M-1);   %Create a 2-by-3 matrix where element values are 3 or 4. 
                                                %>> out = randsrc(2,3,[3 4]
figure(1),stem(data); grid on; xlabel('Data Points'); ylabel('Amplitude')
title('Original Data ')
% Perform QPSK modulation on the input source data
qpsk_modulated_data = pskmod(data, M);
    %Y = pskmod(X,M) outputs the complex envelope of the modulation of the
    % message signal X, using the phase shift keying modulation. M is the
    %alphabet size and must be an integer power or 2. The message signal X
    %must consist of integers between 0 and M-1. For two-dimensional
    %signals, the function treats each column as 1 channel.
figure(2),stem(qpsk_modulated_data);title('QPSK Modulation ')
%............................................................
%.............................................................
% Converting the series data stream into four parallel data stream to form
% four sub carriers
S2P = reshape(qpsk_modulated_data, no_of_data_bits/M,M)
    %reshape(X,M,N) or reshape(X,[M,N]) returns the M-by-N matrix 
    %whose elements are taken columnwise from X. An error results 
    %if X does not have M*N elements. Here 16*4 matrix of data
Sub_carrier1 = S2P(:,1)
Sub_carrier2 = S2P(:,2)
Sub_carrier3 = S2P(:,3)
Sub_carrier4 = S2P(:,4)
figure(3), subplot(4,1,1),stem(Sub_carrier1),title('Subcarrier1'),grid on;
subplot(4,1,2),stem(Sub_carrier2),title('Subcarrier2'),grid on;
subplot(4,1,3),stem(Sub_carrier3),title('Subcarrier3'),grid on;
subplot(4,1,4),stem(Sub_carrier4),title('Subcarrier4'),grid on;
%..................................................................
%..................................................................
% IFFT OF FOUR SUB_CARRIERS
%.................................................................
%..............................................................
number_of_subcarriers=4;
cp_start=block_size-cp_len;
ifft_Subcarrier1 = ifft(Sub_carrier1)
ifft_Subcarrier2 = ifft(Sub_carrier2)
ifft_Subcarrier3 = ifft(Sub_carrier3)
ifft_Subcarrier4 = ifft(Sub_carrier4)
    %In summary the signal is easier synthesized in discrete frequency domain in the
    %transmitter and to transmit it must be converted to discrte time domain by IFFT
figure(4), subplot(4,1,1),plot(real(ifft_Subcarrier1),'r'),
title('IFFT on all the sub-carriers')
subplot(4,1,2),plot(real(ifft_Subcarrier2),'c')
subplot(4,1,3),plot(real(ifft_Subcarrier3),'b')
subplot(4,1,4),plot(real(ifft_Subcarrier4),'g')
%...........................................................
%...........................................................
% ADD-CYCLIC PREFIX %..........................................................
%............................................................
for i=1:number_of_subcarriers,
ifft_Subcarrier(:,i) = ifft((S2P(:,i)),16)% 16 is the ifft point
for j=1:cp_len,
cyclic_prefix(j,i) = ifft_Subcarrier(j+cp_start,i)
end
Append_prefix(:,i) = vertcat( cyclic_prefix(:,i), ifft_Subcarrier(:,i))
% Appends prefix to each subcarriers
end
A1=Append_prefix(:,1);
A2=Append_prefix(:,2);
A3=Append_prefix(:,3);
A4=Append_prefix(:,4);
figure(5), subplot(4,1,1),plot(real(A1),'r'),title('Cyclic prefix added to all the sub-carriers')
subplot(4,1,2),plot(real(A2),'c')
subplot(4,1,3),plot(real(A3),'b')
subplot(4,1,4),plot(real(A4),'g')
figure(11),plot((real(A1)),'r'),title('Orthogonality'),hold on ,plot((real(A2)),'c'),hold on ,
plot((real(A3)),'b'),hold on ,plot((real(A4)),'g'),hold on ,grid on 
%Convert to serial stream for transmission
[rows_Append_prefix cols_Append_prefix]=size(Append_prefix)
len_ofdm_data = rows_Append_prefix*cols_Append_prefix
% OFDM signal to be transmitted
ofdm_signal = reshape(Append_prefix, 1, len_ofdm_data);
figure(6),plot(real(ofdm_signal)); xlabel('Time'); ylabel('Amplitude');
title('OFDM Signal');grid on;
%...............................................................

%Passing time domain data through channel and AWGN

%.............................................................
channel = randn(1,2) + sqrt(-1)*randn(1,2);
after_channel = filter(channel, 1, ofdm_signal);
awgn_noise = awgn(zeros(1,length(after_channel)),0);
recvd_signal = awgn_noise+after_channel; % With AWGN noise
figure(7),plot(real(recvd_signal)),xlabel('Time'); ylabel('Amplitude');
title('OFDM Signal after passing through channel');grid on;
%...........................................................

%OFDM receiver part

%..........................................................
recvd_signal_paralleled = reshape(recvd_signal,rows_Append_prefix, cols_Append_prefix);
%........................................................
%........................................................
% Remove cyclic Prefix
%.......................................................
%......................................................
recvd_signal_paralleled(1:cp_len,:)=[];
R1=recvd_signal_paralleled(:,1);
R2=recvd_signal_paralleled(:,2);
R3=recvd_signal_paralleled(:,3);
R4=recvd_signal_paralleled(:,4);
figure(8),plot((imag(R1)),'r'),subplot(4,1,1),plot(real(R1),'r'),
title('Cyclic prefix removed from the four sub-carriers')
subplot(4,1,2),plot(real(R2),'c')
subplot(4,1,3),plot(real(R3),'b')
subplot(4,1,4),plot(real(R4),'g')
%...................................................
%...................................................
% FFT Of recievied signal
for i=1:number_of_subcarriers,
% FFT
fft_data(:,i) = fft(recvd_signal_paralleled(:,i),16);
end
F1=fft_data(:,1);
F2=fft_data(:,2);
F3=fft_data(:,3);
F4=fft_data(:,4);
figure(9), subplot(4,1,1),plot(real(F1),'r'),title('FFT of all the four sub-carriers')
subplot(4,1,2),plot(real(F2),'c')
subplot(4,1,3),plot(real(F3),'b')
subplot(4,1,4),plot(real(F4),'g')
%................................
%..............................
% Signal Reconstructed
%..................................
%..................................
% Conversion to serial and demodulationa
recvd_serial_data = reshape(fft_data, 1,(16*4));
qpsk_demodulated_data = pskdemod(recvd_serial_data,4);
figure(10)
stem(data)
hold on
stem(qpsk_demodulated_data,'rx');
grid on;xlabel('Data Points');ylabel('Amplitude');
title('Recieved Signal with error')
% Calculating the Bit Error Rate
    [n, r]=biterr(data,qpsk_demodulated_data);


%% Plotting BER vs SNR
semilogy(snr,r,'-ok');
grid;
title('OFDM Bit Error Rate .VS. Signal To Noise Ratio');
ylabel('BER');
xlabel('SNR [dB]');