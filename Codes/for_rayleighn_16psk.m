 a=0:5:40
 b=[0.8098 0.71634 0.5246744 0.391667 0.2404 0.182291 0.15976 0.1347 0.12871]
 c=[0.812 0.6873 0.5041 0.32708 0.1748 0.1 0.0496744 0.02819 0.02721]
 d=[0.78 0.6619 0.4932 0.23164 0.1205 0.044 0.0046 0.00071 0.0008]
 e=[0.79 0.664322 0.4678 0.1542 0.1052 0.03834 0.0091 0.0001 0]
 f=[0.79 0.655 0.45 0.1664 0.097 0.042256 0.018 0.0015 0.000]
 semilogy(a,b,'-ok');grid;hold on
 semilogy(a,c,'-ob');grid;hold on
 semilogy(a,d,'-og');grid;hold on
 semilogy(a,e,'-oc');grid;hold on
 semilogy(a,f,'-or');grid;hold off
 title('OFDM BER vs SNR in Frequency selective Rayleigh fading channel');
xlabel('snr');
ylabel('BER');
legend('cp-0','cp-2','cp-4','cp-8','cp-10')
