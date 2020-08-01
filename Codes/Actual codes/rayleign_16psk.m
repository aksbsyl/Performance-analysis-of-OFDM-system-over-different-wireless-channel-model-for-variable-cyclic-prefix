%for snr=10 rayleighn 16 psk 
cp=0:2:24
ber1=[0.1839 0.1812 0.1820 0.1825 0.1785 0.1772 0.1768 0.1771 0.1763 0.1784 0.1785  0.1786 0.1782]
ber2=[0.525 0.5041 0.4932 0.472786 0.4678 0.4698 0.47265 0.481 0.4765 0.4712 0.467 0.457 0.4502]
plot(cp,ber1,'-ok'); hold on
plot(cp,ber2,'-or'); hold off

title('OFDM Bit Error Rate .VS. cp length');
ylabel('BER');
xlabel('cp length')
legend('AWGN Channel','Rayleigh Channel')