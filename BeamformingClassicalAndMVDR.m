%% Setup

close all;
clear;
clc;

%% Constants

% Signal to Noise ratio
SNRdB = 15;
% Signal to Interference ratio
SIRdB = -20;
% Number of Rx (Receiver) antenas
N = 8;
% Number of pilot signals for training channel estimator
NumPilots = 10;
% Number of payload signals to receive
NumPayLoad = 1000;

%% Signal generation

% Desired signal DoA (Direction of Arrival)
theta_deg = 30;
x_desired = exp(-1j*pi*sin(theta_deg*pi/180)*[0:N-1].');
% Interference signal DoA
Interf_angle = 20;
x_Interf = exp(-1j*pi*sin(Interf_angle*pi/180)*[0:N-1].');
% Pilots generation 
pilots = randsrc(1,NumPilots,[1+1j 1-1j -1+1j -1-1j])/sqrt(2);
% Signal generation without noise
s = randsrc(1,NumPayLoad,[1+1j 1-1j -1+1j -1-1j])/sqrt(2);
% Random phase generation
a_desired = exp(1j*2*pi*rand);
% Full signl generation without noise as would be received at antenaa array
y_desired = a_desired * x_desired * [pilots,s];
% Generate Circulant AWGN for interference (jammer)
r = (randn(1,length([pilots,s])) + 1j * randn(1,length([pilots,s])))/sqrt(2);
% Generate full interference, one should notice it has a different phase
y_interf = exp(1j*2*pi*rand)*x_Interf*10^(-SIRdB/20)*r;
% Generate noise for actual signal
Noise = 10^(-SNRdB/20) * (randn(size(y_desired)) + 1j * randn(size(y_desired)))/sqrt(2);
% Total signal
y = y_desired + y_interf + Noise;
% Plotting total signal generated


%% Channel estimation

% Doing channel estimation using pilots, transposes needed to solve the
% equations in a nice way
Y = y(:,1:NumPilots).';
p = pilots.';
% Channel weights using least squares estimation
w_hat = pinv(Y'*Y)*Y'*p;

%% Max Ratio Combining (MRC) Beamformer

% This beamformer does maximum likelihood (ML) estimation of the following
% problem: y = h*s+rho*n where h is the antena array, s in the signal, rho
% is the power of the noise and n is C-AWGN. We solve the equation using
% ML estimation in the following way: y - h*s = rho* n , where n~N(0,sigma^2*I)

% Extraction of reconstructed QAM signals using MRC beamformer
s_hat_MRC = (a_desired*x_desired)'/N*y(:,NumPilots+1:end);

%% Minimum Variance Distortionless Response (MVDR) Beamformer

% This beamformer does ML estimation of the following problem: y = h*s + m
% where m now is Gaussiaan colored noise with covariance matrix C, the
% gaussian variable is colored because there is asymmetry in the geometry
% as a result of another signal present, therefore we would like to
% eliminae it, thats exactly what the MVDR beamformer will do for us, we
% are going to do null-steering using it, and eliminate the interference.

% We use the channel estimation (Channel state information - CSI) inside
% our MVDR beamformer because we cant know the actual covariance matrix of
% the signals without the noise.
s_hat_MVDR = w_hat.'*y(:,NumPilots+1:end);

%% Plot comparison between beamformers at IQ plane

% Error vector magnitude calculation (Error to the actual IQ symbol)
EVM_mrc_dB = 10 * log10(mean(abs(s_hat_MRC-s).^2)); 
EVM_mvdr_dB = 10 * log10(mean(abs(s_hat_MVDR-s).^2)); 
% Plot
plot(s_hat_MRC,'.'); grid; hold on
plot(s_hat_MVDR,'r.')
xlabel('In-Phase')
ylabel('Quadrature')
legend(['MRC (perfect channel), EVM = ',num2str(EVM_mrc_dB),'dB'], ['MVDR BF, EVM = ',num2str(EVM_mvdr_dB),'dB'])

%% Plot spatial response

% Look at spatial filter design of the beamformers
phi_deg = [-90:.1:90];
% We input signals with different DoA and see the beamformers response
for k = 1:length(phi_deg)
    x_test = exp(-1j*pi*sin(phi_deg(k)*pi/180)*[0:N-1].');
    MRC_resp(k) = abs(x_desired'*x_test)/N;
    MVDR_resp(k) = abs(w_hat.'*x_test);
end

figure;
plot(phi_deg,20*log10(MRC_resp)); hold on; grid;
plot(phi_deg,20*log10(MVDR_resp),'r');
xline(theta_deg,'blue');
xline(Interf_angle);
ylim([-60 max(max(20*log10(MRC_resp)),max(20*log10(MVDR_resp)))+10]); xticks(-100:25:100)
title(['Spatial Response with ', num2str(N), ' Rx antennas. Desired at ',num2str(theta_deg),' deg and interf (jammer) at ',num2str(Interf_angle),' deg']);
legend('MRC response','MVDR response','Desired signal DoA','Jammer DoA')
xlabel('DoA (deg)')
ylabel('Response (dB)')









