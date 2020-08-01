a=0:2:30
b=[0.382339 0.3492 0.3135 0.2705 0.27796 0.1775 0.1306 0.077 0.0373 0.0145 0.0025 0.00024 0 0 0 0]
c=[0.271728 0.24536 0.17944 0.143 0.0991210975 0.0647 0.02734 0.00048 0 0 0 0 0 0 0 0]
d=[0.8 0.744 0.7082 0.6573 0.563 0.476 0.37 0.30266 0.2161458 0.16634 0.1094 0.08646 0.0418 0.02161 0.02584 0.019]
semilogy(a,b,'-ok ','linewidth',1);grid;hold on
semilogy(a,c,'-or','linewidth',1);grid;hold on 
semilogy(a,d,'-ob','linewidth',1);grid;hold off
title('OFDM Bit Error Rate vs SNR');
ylabel('Bit Error Rate');
xlabel('SNR [dB]');
legend('16-psk AWGN','16-qam AWGN','16-psk rayleigh')

