clc;
clear all;
close all;
%% Initializing parameters
L=128; %input('Length Of OFDM Data = ');
Ncp=L*0.0625;
%% Transmitter
% data generation
Tx_data=randi([0 15],L,Ncp);
a=1
for Ncp=Ncp:0.0625:Ncp+0.5 
%%%%%%%%%%%%%%%%%%% QAM modulation %%%%%%%%%%%%%%%%%%%%%
mod_data=qammod(Tx_data,16);
% Serial to Parallel
s2p=mod_data.';
% IFFT
am=ifft(s2p);
% Parallel to series
p2s=am.';
% Cyclic Prefixing
CP_part=p2s(:,end-Ncp+1:end); %Cyclic Prefix part to be appended.
cp=[CP_part p2s];

%%  Reciever

% Adding Noise using AWGN
SNRstart=0;
SNRincrement=1;
SNRend=25;
c=0;
r=zeros(size(SNRstart:SNRincrement:SNRend));
for snr=SNRstart:SNRincrement:SNRend
    c=c+1;
    noisy=awgn(cp,snr,'measured');
% Remove cyclic prefix part
    cpr=noisy(:,Ncp+1:Ncp+Ncp); %remove the Cyclic prefix
% series to parallel
    parallel=cpr.';
% FFT
    amdemod=fft(parallel);
% Parallel to serial
    rserial=amdemod.';
%%%%%%%%%%%%%%%%%%%% QAM demodulation %%%%%%%%%%%%%%%%%%%%%
    Umap=qamdemod(rserial,16);
% Calculating the Bit Error Rate
    [n, r(c)] = biterr(Tx_data,Umap);

end
snr=SNRstart:SNRincrement:SNRend;
%% Plotting BER vs SNR
if a==1
    r
semilogy(snr,r,'-ok');
end
if a==2
    r
semilogy(snr,r,'-ok');
end
if a==3
    r
semilogy(snr,r,'-og');
end
if a==4
    r
semilogy(snr,r,'-or');
end
if a==5
    r
semilogy(snr,r,'-or');
end
grid;
title('OFDM Bit Error Rate .VS. Signal To Noise Ratio');
ylabel('BER');
xlabel('SNR [dB]');
hold on
a=a+1;
end