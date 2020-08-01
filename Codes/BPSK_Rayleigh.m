%% BPSK over Rayleigh fading wireless channel 
%% and its comparison with BPSK transmission over AWGN channel
close all;clear all;clc;
SNRdB=1:1:26;
SNR=10.^(SNRdB/10);
bl=10^6;
ber=zeros(1,length(SNRdB));

%% BPSK Transmission over AWGN channel
for k=1:length(SNR);
    x=(2*floor(2*rand(1,bl)))-1;
    y=(sqrt(SNR(k))*x)+randn(1,bl);
    ber(k)=length(find((y.*x)<0));
end
ber=ber/bl;
semilogy(SNRdB,ber,'k-<', 'linewidth' ,2.0);
hold on
semilogy(SNRdB,qfunc(sqrt(SNR)),'m-','linewidth',2.0);
gtext('BPSK over AWGN')
hold on

%% BPSK over Rayleigh Fading Wireless Channel
for k=1:length(SNR)
    y=raylrnd(1/sqrt(2),1,bl).*((sqrt(SNR(k))*x))+randn(1,bl);
    ber(k)=length(find((y.*x)<0));
end
ber=ber/bl;
semilogy(SNRdB,ber,'k-<', 'linewidth' ,2.0);
hold on
semilogy(SNRdB,0.5*(1-(sqrt(SNR./(2+SNR)))),'r-','linewidth',2.0);
gtext('BPSK over Rayleigh')
title('BPSK over Rayleigh and BPSK over AWGN Simulation');xlabel('SNR in dB');ylabel('BER');
%axis tight
grid