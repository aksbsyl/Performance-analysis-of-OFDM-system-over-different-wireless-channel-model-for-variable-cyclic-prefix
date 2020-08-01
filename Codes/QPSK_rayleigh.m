% QPSK simulation with Gray coding and simple Rayleigh (no LOS) multipath 
% and AWGN included.

% Clear all the previously used variables and close all figures
clear all;
close all;

format long;

% Frame Length
bit_count = 10000;

% Range of SNR over which to simulate 
Eb_No = -3: 1: 30;

% Convert Eb/No values to channel SNR
% Consult BERNARD SKLAR'S book 'Digital Communications'
SNR = Eb_No + 10*log10(2);

% Start the main calculation loop
for aa = 1: 1: length(SNR)
    
    % Initiate variables
    T_Errors = 0;
    T_bits = 0;
    
    % Keep going until you get 100 errors
    while T_Errors < 100
    
        % Generate some information bits
        uncoded_bits  = round(rand(1,bit_count));
        
        % Split the stream into two streams, for Quadrature Carriers
        B1 = uncoded_bits(1:2:end);
        B2 = uncoded_bits(2:2:end);
        
        % QPSK modulator set to pi/4 radians constellation
        % If you want to change the constellation angles
        % just change the angles. (Gray Coding)
        qpsk_sig = ((B1==0).*(B2==0)*(exp(i*pi/4))+(B1==0).*(B2==1)...
            *(exp(3*i*pi/4))+(B1==1).*(B2==1)*(exp(5*i*pi/4))...
            +(B1==1).*(B2==0)*(exp(7*i*pi/4))); 
        
        % Variance = 0.5 - Tracks theoritical PDF closely
        ray = sqrt(0.5*((randn(1,length(qpsk_sig))).^2+(randn(1,length(qpsk_sig))).^2));
        
        % Include The Multipath
        rx = qpsk_sig.*ray;
        
        % Noise variance
        N0 = 1/10^(SNR(aa)/10);
        
        % Send over Gaussian Link to the receiver
        rx = rx + sqrt(N0/2)*(randn(1,length(qpsk_sig))+i*randn(1,length(qpsk_sig)));
        
%---------------------------------------------------------------
        
        % Equaliser
        rx = rx./ray;

        % QPSK demodulator at the Receiver
        B4 = (real(rx)<0);
        B3 = (imag(rx)<0);
        
        uncoded_bits_rx = zeros(1,2*length(rx));
        uncoded_bits_rx(1:2:end) = B3;
        uncoded_bits_rx(2:2:end) = B4;

    
        % Calculate Bit Errors
        diff = uncoded_bits - uncoded_bits_rx;
        T_Errors = T_Errors + sum(abs(diff));
        T_bits = T_bits + length(uncoded_bits);
        
    end
    % Received data constellation
    figure; clf;
    plot(real(rx),imag(rx),'o');  % Scatter Plot
    title(['constellation of received symbols for SNR = ', num2str(SNR(aa))]); 
    xlabel('Inphase Component'); ylabel('Quadrature Component');

    % Calculate Bit Error Rate
    BER(aa) = T_Errors / T_bits;
    disp(sprintf('bit error probability = %f',BER(aa)));

end
  
%------------------------------------------------------------

% Finally plot the BER Vs. SNR(dB) Curve on logarithmic scale 
% BER through Simulation
figure(1);
semilogy(SNR,BER,'or');
hold on;
xlabel('SNR (dB)');
ylabel('BER');
title('SNR Vs BER plot for QPSK Modualtion in Rayleigh Channel');

% Rayleigh Theoretical BER
figure(1);
EbN0Lin = 10.^(Eb_No/10);
theoryBerRay = 0.5.*(1-sqrt(EbN0Lin./(EbN0Lin+1)));
semilogy(SNR,theoryBerRay);
grid on;

% Theoretical BER
figure(1);
theoryBerAWGN = 0.5*erfc(sqrt(10.^(Eb_No/10)));
semilogy(SNR,theoryBerAWGN,'g-+');
grid on;
legend('Simulated', 'Theoretical Raylegh', 'Theroretical AWGN');
axis([SNR(1,1) SNR(end-3) 0.00001 1]);