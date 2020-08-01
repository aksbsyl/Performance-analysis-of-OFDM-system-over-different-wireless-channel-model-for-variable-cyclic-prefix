% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Montadar Abas Taher May 13, 2014
%  OFDM system, Transmitter and Reciever
%  You do not need for any user defined functions.
%  This OFDM system asks about the following parameters:
%  N          : size of OFDM symbol assuming fully loaded symbol
%  M          : constellation order size (Alphabet size)
%  PoQ        : PSK or QAM mapping? 1 means PSK and 2 means QAM
%  Phase_Offset: constellation phase offset
%  Symbol_Order: constellation Symbol Order {1 for Binary and 2 for Gray}
%  Ncp        : size of cyclic prefix samples
%  m          : Number of OFDM symbols to be simulated
%%
clear all;close all;clc;
%%
% Initializing parameters
OFDM.N=128             %input('Size of OFDM Symbol N = ');
OFDM.m=128             %input('Number of OFDM symbols to be simulated m = ');
OFDM.M=4            %('Size of Alphabet M = ');
OFDM.L=1             %input('Up-sampling factor L = ');
OFDM.PoQ=1           %input('Type of Mapping (1 for PSK) and (2 for QAM) = ');
OFDM.Phase_Offset=0  %input('constellation phase offset = ');
OFDM.Symbol_Order=1  %input('constellation Symbol Order (1 for Binary) and (2 for Gray) = ');
OFDM.Ncp=16
Ncp=16
%input('size of cyclic prefix samples Ncp = ');
%% Transmitter
% Creating Baseband modems Tx/Rx
if OFDM.Symbol_Order == 1
    OFDM.Symbol_Order = 'binary';
else
    OFDM.Symbol_Order = 'gray';
end
if OFDM.PoQ == 1
    hTx = modem.pskmod('M',OFDM.M,'PhaseOffset',OFDM.Phase_Offset,'SymbolOrder',OFDM.Symbol_Order);
    hRx = modem.pskdemod('M',OFDM.M,'PhaseOffset',OFDM.Phase_Offset,'SymbolOrder',OFDM.Symbol_Order);
else
    hTx = modem.qammod('M',OFDM.M,'PhaseOffset',OFDM.Phase_Offset,'SymbolOrder',OFDM.Symbol_Order);
    hRx = modem.qamdemod('M',OFDM.M,'PhaseOffset',OFDM.Phase_Offset,'SymbolOrder',OFDM.Symbol_Order);
end
% data generation
OFDM.DATA=randi([0 OFDM.M-1],OFDM.m,OFDM.N/OFDM.L);

a=1

for Ncp=Ncp:0.0625:Ncp+0.25 
    OFDM.Ncp=Ncp;
% Mapping
OFDM.Dmap=modulate(hTx,OFDM.DATA);
% Serial to Parallel
OFDM.parallel=OFDM.Dmap.';
% Oversampling 
OFDM.upsampled=upsample(OFDM.parallel,OFDM.L);
% Amplitude modulation (IDFT using fast version IFFT)
ofdm.am=ifft(OFDM.upsampled,OFDM.N);
% Parallel to serial
ofdm.serial=ofdm.am.';
% Cyclic Prefixing
ofdm.CP_part=ofdm.serial(:,end-OFDM.Ncp+1:end); % this is the Cyclic Prefix part to be appended.
ofdm.cp=[ofdm.CP_part ofdm.serial];
%%  Reciever
% Adding Noise using AWGN
SNRstart=0;
SNRincrement=2;
SNRend=30;
c=0;
r=zeros(size(SNRstart:SNRincrement:SNRend));
for snr=SNRstart:SNRincrement:SNRend
    c=c+1;
    ofdm.noisy=awgn(ofdm.cp,snr,'measured');
% Remove cyclic prefix part
    ofdm.cpr=ofdm.noisy(:,OFDM.Ncp+1:OFDM.N+OFDM.Ncp); %remove the Cyclic prefix
% serial to parallel
    ofdm.parallel=ofdm.cpr.';
% Amplitude demodulation (DFT using fast version FFT)
    OFDM.amdemod=fft(ofdm.parallel,OFDM.N);
% Down-Sampling
OFDM.downsampled=downsample(OFDM.amdemod,OFDM.L);
% Parallel to serial
    OFDM.rserial=OFDM.downsampled.';
% Baseband demodulation (Un-mapping)
    OFDM.Umap=demodulate(hRx,OFDM.rserial);
% Calculating the Symbol Error Rate
    [n, r(c)]=biterr(OFDM.DATA,OFDM.Umap);
    disp(['SNR = ',num2str(snr),' step: ',num2str(c),' of ',num2str(length(r))]);
end
snr=SNRstart:SNRincrement:SNRend;
% Plotting SER vs SNR
if a==1
semilogy(snr,r,'-ok','linewidth',2,'markerfacecolor','r','markersize',8,'markeredgecolor','b');grid;

end
if a==2
semilogy(snr,r,'-or','linewidth',2,'markerfacecolor','r','markersize',8,'markeredgecolor','b');grid;

end
if a==3
semilogy(snr,r,'-ob','linewidth',2,'markerfacecolor','r','markersize',8,'markeredgecolor','b');grid;

end
if a==4
semilogy(snr,r,'-og','linewidth',2,'markerfacecolor','r','markersize',8,'markeredgecolor','b');grid;

end
if a==5
semilogy(snr,r,'-oc','linewidth',2,'markerfacecolor','r','markersize',8,'markeredgecolor','b');grid;

end
title('OFDM Bit Error Rate vs SNR');
ylabel('Bit Error Rate');
xlabel('SNR [dB]');
legend(['SER N = ', num2str(OFDM.N),' ',num2str(hTx.M),'-',hTx.type]);
hold on;
a=a+1;
end

    
    
    
    
    
    
    
    
