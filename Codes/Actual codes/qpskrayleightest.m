%% Program to plot the BER of OFDM in Frequency selective Rayleigh channel

clc;
clear all;
close all;
N = 128;                                                % No of subcarriers
Ncp =42;                                               % Cyclic prefix length
Ts = 1e-3;                                              % Sampling period of channel
Fd = 0;                                                 % Max Doppler frequency shift
Np = 4;                                                 % No of pilot symbols
M = 16;   
b=1;% No of symbols for PSK modulation
Nframes = 128;                                         % No of OFDM frames
D = round((M-1)*rand((N-2*Np),Nframes));
const = pskmod([0:M-1],M);
Dmod = pskmod(D,M);
Data = [zeros(Np,Nframes); Dmod ; zeros(Np,Nframes)];   % Pilot Insertion


%% OFDM symbol

IFFT_Data = (128/sqrt(120))*ifft(Data,N);
TxCy = [IFFT_Data((128-Ncp+1):128,:); IFFT_Data];       % Cyclic prefix
[r c] = size(TxCy);
Tx_Data = TxCy;

%% Frequency selective channel with 4 taps

tau = [0 1e-5 3.5e-5 12e-5];                            % Path delays
pdb = [0 -1 -1 -3];                                     % Avg path power gains
h = rayleighchan(Ts, Fd, tau, pdb);
h.StoreHistory = 0;
h.StorePathGains = 1;
h.ResetBeforeFiltering = 1;

%% SNR of channel

EbNo = 0:5:40;
EsNo= EbNo + 10*log10(120/128)+ 10*log10(128/144);      % symbol to noise ratio
snr= EsNo - 10*log10(128/144); 

%% Transmit through channel

berofdm = zeros(1,length(snr));
Rx_Data = zeros((N-2*Np),Nframes);
for i = 1:length(snr)
    for j = 1:c                                         % Transmit frame by frame
        hx = filter(h,Tx_Data(:,j).');                  % Pass through Rayleigh channel
        a = h.PathGains;
        AM = h.channelFilter.alphaMatrix;
        g = a*AM;                                       % Channel coefficients
        G(j,:) = fft(g,N);                              % DFT of channel coefficients
        y = awgn(hx,snr(i));                            % Add AWGN noise

%% Receiver    
        Rx = y(Ncp+1:r);                                % Removal of cyclic prefix 
        FFT_Data = (sqrt(120)/128)*fft(Rx,N)./G(j,:);   % Frequency Domain Equalization
        Rx_Data(:,j) = pskdemod(FFT_Data(5:124),M);     % Removal of pilot and Demodulation 
    end
    berofdm(i) = sum(sum(Rx_Data~=D))/((N-2*Np)*Nframes);
%% Plot the BER
%figure;
berofdm   
semilogy(snr,berofdm,'-ok','linewidth',2);grid;
%semilogy(EbNo,berofdm,'--or','linewidth',2);
grid on;
title('OFDM BER vs SNR in Frequency selective Rayleigh fading channel');
xlabel('snr');
ylabel('BER');
hold on;
b=b+1;
end
