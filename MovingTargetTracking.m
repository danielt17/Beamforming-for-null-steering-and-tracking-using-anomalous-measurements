%% Setup

close all;
clear;
clc;

%% Constants

% Signal to Noise ratio
SNRdB = 15;
% Signal to Interference ratio
SIRdB = -25;
% Number of Rx (Receiver) antenas
N = 8;
% Number of pilot signals for training channel estimator
NumPilots = 10;
% Number of payload signals to receive
NumPayLoad = 1000;
% Number of packets after which channel is estimated
estimate_channel_every_packets = 2;

%% Signal generation

% Pilots generation 
pilots = randsrc(1,NumPilots,[1+1j 1-1j -1+1j -1-1j])/sqrt(2);
% Signal generation without noise
s = randsrc(1,NumPayLoad,[1+1j 1-1j -1+1j -1-1j])/sqrt(2);
% Random phase generation
a_desired = exp(1j*2*pi*rand);
% Generate Circulant AWGN for interference (jammer)
r = (randn(1,length([pilots,s])) + 1j * randn(1,length([pilots,s])))/sqrt(2);
figure('units','normalized','outerposition',[0 0 1 1]);
for iii = 1:101

thetas_deg = 30:0.1:40;
% Desired signal DoA (Direction of Arrival)
theta_deg = thetas_deg(iii);
x_desired = exp(-1j*pi*sin(theta_deg*pi/180)*[0:N-1].');
% Interference signal DoA
interf_angles = flip(0:0.2:20);
Interf_angle = interf_angles(iii);
x_Interf = exp(-1j*pi*sin(Interf_angle*pi/180)*[0:N-1].');
% Full signl generation without noise as would be received at antenaa array
y_desired = a_desired * x_desired * [pilots,s];

% Generate full interference, one should notice it has a different phase
y_interf = exp(1j*2*pi*rand)*x_Interf*10^(-SIRdB/20)*r;
% Generate noise for actual signal
Noise = 10^(-SNRdB/20) * (randn(N,length([pilots,s])) + 1j * randn(N,length([pilots,s])))/sqrt(2);
% Total signal
y = y_desired + y_interf + Noise;
% Plotting total signal generated


%% Channel estimation

% Doing channel estimation using pilots, transposes needed to solve the
% equations in a nice way
if mod(iii,estimate_channel_every_packets) == 1
    Y = y(:,1:NumPilots).';
    p = pilots.';
    % Channel weights using least squares estimation
    w_hat = pinv(Y'*Y)*Y'*p;
end
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

%% Plot spatial response

% Look at spatial filter design of the beamformers
phi_deg = [-90:.1:90];
% We input signals with different DoA and see the beamformers response
for k = 1:length(phi_deg)
    x_test = exp(-1j*pi*sin(phi_deg(k)*pi/180)*[0:N-1].');
    MRC_resp(k) = abs(x_desired'*x_test)/N;
    MVDR_resp(k) = abs(w_hat.'*x_test);
end

% Error vector magnitude calculation (Error to the actual IQ symbol)
EVM_mrc_dB = 10 * log10(mean(abs(s_hat_MRC-s).^2)); 
EVM_mvdr_dB = 10 * log10(mean(abs(s_hat_MVDR-s).^2)); 
[~,mrc_est_sig_angle] = max(20*log10(MRC_resp)); mrc_est_sig_angle = phi_deg(mrc_est_sig_angle); mrc_est_sig_angle_ar(iii) = mrc_est_sig_angle;
[~,mvdr_est_sig_angle] = max(20*log10(MVDR_resp)); mvdr_est_sig_angle = phi_deg(mvdr_est_sig_angle); mvdr_est_sig_angle_ar(iii) = mvdr_est_sig_angle;
[~,est_jammer_angle] = min(20*log10(MVDR_resp)); est_jammer_angle = phi_deg(est_jammer_angle); est_jammer_angle_ar(iii) = est_jammer_angle;
clf;
subplot(2,1,1)
plot(phi_deg,20*log10(MRC_resp)); hold on; grid;
plot(phi_deg,20*log10(MVDR_resp),'r');
xline(theta_deg,'blue');
xline(Interf_angle);
xline(mrc_est_sig_angle,'cyan')
xline(mvdr_est_sig_angle,'magenta')
xline(est_jammer_angle,'red')
ylim([-60 max(max(20*log10(MRC_resp)),max(20*log10(MVDR_resp)))+10]); xticks(-100:25:100)
title(['Spatial Response with ', num2str(N), ' Rx antennas. Desired at ',num2str(theta_deg),' deg and interf (jammer) at ',num2str(Interf_angle),' deg. Channel estimation every: ',num2str(estimate_channel_every_packets), ' packes.']);
legend(['MRC response, EVM = ',num2str(EVM_mrc_dB),'dB'],['MVDR BF, EVM = ',num2str(EVM_mvdr_dB),'dB'],'True signal DoA','True jammer DoA','MRC BF signal estimated DoA','MVDR BF signal estimated DoA','MVDR BF jammer estimated DoA')
xlabel('DoA (deg)')
ylabel('Response (dB)')
subplot(2,1,2)
plot(s_hat_MRC,'.'); grid; hold on
plot(s_hat_MVDR,'r.')
xlabel('In-Phase')
ylabel('Quadrature')
legend(['MRC (perfect channel), EVM = ',num2str(EVM_mrc_dB),'dB'], ['MVDR BF, EVM = ',num2str(EVM_mvdr_dB),'dB'])
if EVM_mrc_dB > -5 && EVM_mvdr_dB <= -5
    title('IQ scatter plot. MRC beamformer symbol decoding: Failed. MVDR beamformer symbol decoding: Success')
elseif EVM_mrc_dB > -5 && EVM_mvdr_dB > -5
    title('IQ scatter plot. MRC beamformer symbol decoding: Failed. MVDR beamformer symbol decoding: Failed')
elseif EVM_mrc_dB <= -5 && EVM_mvdr_dB <= -5
    title('IQ scatter plot. MRC beamformer symbol decoding: Success. MVDR beamformer symbol decoding: Success')
elseif EVM_mrc_dB <= -5 && EVM_mvdr_dB > -5
    title('IQ scatter plot. MRC beamformer symbol decoding: Success. MVDR beamformer symbol decoding: Failed')
end
pause(0.001)

end

pause(3)
%% Plot tracking of signal and jammer

N = 1;           % first-degree polynomial
maxDistance = 1; % maximum allowed distance for a point to be inlier
x = 1:1:101;
[Psig, siginlierIdx] = fitPolynomialRANSAC([x;mvdr_est_sig_angle_ar].',N,maxDistance); % ransac polyfits
[Pjammer, jammerinlierIdx] = fitPolynomialRANSAC([x;est_jammer_angle_ar].',N,maxDistance); % ransac polyfits
mvdr_est_sig_angle_ransac = polyval(Psig,x);
mvdr_est_jammer_angle_ransac = polyval(Pjammer,x);


figure;
plot(mrc_est_sig_angle_ar,'-o'); hold on; grid;
plot(mvdr_est_sig_angle_ar,'-o');
plot(mvdr_est_sig_angle_ransac,'--');
plot(x(~siginlierIdx),mvdr_est_sig_angle_ar(~siginlierIdx),'ro')
plot(thetas_deg);
plot(est_jammer_angle_ar,'-o');
plot(mvdr_est_jammer_angle_ransac,'--','LineWidth',3);
plot(x(~jammerinlierIdx),est_jammer_angle_ar(~jammerinlierIdx),'ro')
plot(interf_angles);
ylim([-100 100]);
xlabel('Time [msec]')
ylabel('DoA [deg]')
title('DoA estimation with respect to time')
legend('MRC beamformer signal DoA','MVDR beamformer signal DoA','MVDR beamformer + ransac fit to signal velocity model DoA','Outliers signal model','True signal DoA','MVDR beamformer jammer DoA','MVDR beamformer + ransac fit to jammer velocity model DoA','Outliers jammer model','True jammer DoA')


