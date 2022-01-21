# Beamforming-for-null-steering-and-tracking-using-anomalous-measurements

This repository contains MATLAB code for the following simulation:
1. A comparison of beamforming algorithms: Max Ratio Combining (MRC) and Minimum Variance Distortioless Response (MVDR).
2. The simulation contains a signal we want to track, and a jammer which we want to nullify.
3. The signal and jammer sources are moving with constant velocity, the jammer has twice the velocity of the signal source.
4. We use a set of pilot signals to estimate the channel model (weights), using least squares (LS) estimation.
5. The estimated QPSK symbols are than evaluated using Error Vector Magnitude (EVM), where the MVDR beamformer comes on top.
6. Finally the estimated Direction of Arrivals (DoA), go through a process of discovering anomalies and fitting a linear model using the Random Sample Consensus (RANSAC) algorithm. 

In depth look at the simulation:

1. We generate bits which transmit over a QPSK modulation, the sequence is made of pilot signals and the transmitted data. 
A block is defined in the following way using concatenation: [pilots, signals]. 

QPSK symbol set:

<img src="https://latex.codecogs.com/png.image?\dpi{110}&space;\bg_white&space;1&plus;j,&space;1-1j,&space;-1&plus;1j,&space;1-1j" title="\bg_white 1+j, 1-1j, -1+1j, 1-1j" />

![image](https://user-images.githubusercontent.com/60748408/150105145-57990d96-8ed5-4209-9538-1278fda34ae6.png)


The transmitted signals are defined in the following way: 

<img src="https://latex.codecogs.com/png.image?\dpi{110}&space;\bg_white&space;s_{N}(\theta)&space;=&space;e^{2\pi&space;\cdot&space;j&space;\cdot&space;\phi}&space;\cdot&space;e^{-&space;\pi&space;\cdot&space;j&space;\cdot&space;sin(\frac{\pi&space;\cdot&space;\theta}{180})&space;\cdot&space;[0,1,...,N-2,N-1]^{T}}&space;\cdot&space;symbols" title="\bg_white s_{N}(\theta) = e^{2\pi \cdot j \cdot \phi} \cdot e^{- \pi \cdot j \cdot sin(\frac{\pi \cdot \theta}{180}) \cdot [0,1,...,N-2,N-1]^{T}} \cdot symbols" />

where we have N antenas with different time delays to create the effect of coherent summation, as can be seen in the image below describing a phased array setup.

![Alt Text](https://upload.wikimedia.org/wikipedia/commons/4/4a/Phased_array_animation_with_arrow_10frames_371x400px_100ms.gif)

The interference which comes from a jammer is defined in the following way (where CN is a complex gaussian):

<img src="https://latex.codecogs.com/png.image?\dpi{110}&space;\bg_white&space;j_N(\theta)&space;=&space;e^{2\pi&space;\cdot&space;j&space;\cdot&space;\phi_{j}}&space;\cdot&space;e^{-&space;\pi&space;\cdot&space;j&space;\cdot&space;sin(\frac{\pi&space;\cdot&space;\theta_{j}}{180})&space;\cdot&space;[0,1,...,N-2,N-1]^{T}}&space;\cdot&space;\mathcal{CN}" title="\bg_white j_N(\theta) = e^{2\pi \cdot j \cdot \phi_{j}} \cdot e^{- \pi \cdot j \cdot sin(\frac{\pi \cdot \theta_{j}}{180}) \cdot [0,1,...,N-2,N-1]^{T}} \cdot \mathcal{CN}" />

The noise added to our model is complex gaussian noise:

<img src="https://latex.codecogs.com/png.image?\dpi{110}&space;\bg_white&space;n&space;\sim&space;&space;\mathcal{CN}(0,1)" title="\bg_white n \sim \mathcal{CN}(0,1)" />

Therefore the recieved signal model is:

<img src="https://latex.codecogs.com/png.image?\dpi{110}&space;\bg_white&space;x_N(\theta)=&space;s_N(\theta)&space;&plus;&space;j_N(\theta)&space;&plus;&space;n" title="\bg_white x_N(\theta)= s_N(\theta) + j_N(\theta) + n" />

The recieved signal is composed of three part, each with different amplitudes which we model in the following way:

<img src="https://latex.codecogs.com/png.image?\dpi{110}&space;\bg_white&space;x_N(\theta)=&space;s_N(\theta)&space;&plus;&space;m&space;j_N(\theta)&space;&plus;&space;\rho&space;n" title="\bg_white x_N(\theta)= s_N(\theta) + m j_N(\theta) + \rho n" />

Where:

<img src="https://latex.codecogs.com/png.image?\dpi{110}&space;\bg_white&space;m=10^{-\frac{SIRdB}{20}},&space;\rho=10^{-\frac{SNRdB}{20}}" title="\bg_white m=10^{-\frac{SIRdB}{20}}, \rho=10^{-\frac{SNRdB}{20}}" />


2. We do LS channel estimation using pilot signals, where the expected pilot signals structure is known and which will be used to estimate the channel coefficents using the recieved pilot signals. The problem can be formulated in the following manner:

<img src="https://latex.codecogs.com/png.image?\dpi{110}&space;\bg_white&space;\hat{w}&space;=&space;argmin_{w}&space;|p-Yw|^2&space;\rightarrow&space;\hat{w}=(Y^TY)^{-1}Y^Tp" title="\bg_white \hat{w} = argmin_{w} |p-Yw|^2 \rightarrow \hat{w}=(Y^TY)^{-1}Y^Tp" />

Where p are the expected pilot signals, Y are the recieved pilots and w describes the channel coefficents.

A video describing the beamforming and tracking with respect to time

[![IMAGE ALT TEXT](https://img.youtube.com/vi/bOLJTF90Vzs/0.jpg)](https://youtu.be/bOLJTF90Vzs)
