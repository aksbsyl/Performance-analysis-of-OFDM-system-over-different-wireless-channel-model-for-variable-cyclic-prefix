%for snr=10 rayleighn 16 psk 
cp=0:2:16
ber=[0.525 0.5041 0.4932 0.472786 0.4678 0.4698 0.47265 0.481 0.4765]
plot(cp,ber)
title('OFDM Bit Error Rate .VS. cp length');
ylabel('BER');
xlabel('cp length')