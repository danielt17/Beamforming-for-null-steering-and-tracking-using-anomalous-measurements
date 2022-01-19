# Beamforming-and-tracking-using-anomalous-measurements

This repository contains MATLAB code for the following simulation:
1. A comparison of beamforming algorithms: Max Ratio Combining (MRC) and Minimum Variance Distortioless Response (MVDR).
2. The simulation contains a signal we want to track, and a jammer which we want to nullify.
3. The signal and jammer sources are moving with constant velocity, the jammer has twice the velocity of the signal source.
4. We use a set of pilot signals to estimate the channel model (weights), using least squares (LS) estimation.
5. The estimated QPSK symbols are than evaluated using Error Vector Magnitude (EVM), where the MVDR beamformer comes on top.
6. Finally the estimated Direction of Arrivals (DoA), go through a process of discovering anomalies and fitting a linear model using the Random Sample Consensus (RANSAC) algorithm. 

In depth look at the simulation:

1. We generate bits which transmit over a QPSK modulation, the signals are made of pilot signals and the transmitted data. 
A block is defined in the following way using concatenation: [pilots, signals]. 
The signals are defined in the following way: 

<img src="https://latex.codecogs.com/png.image?\dpi{110}&space;\bg_white&space;s&space;=&space;e^{2\pi&space;\cdot&space;j&space;\cdot&space;\phi}&space;\cdot&space;e^{-&space;\pi&space;\cdot&space;j&space;\cdot&space;sin(\frac{\pi&space;\cdot&space;\theta}{180})&space;\cdot&space;[0,1,...,N-2,N-1]^{T}}&space;\cdot&space;symbols" title="\bg_white s = e^{2\pi \cdot j \cdot \phi} \cdot e^{- \pi \cdot j \cdot sin(\frac{\pi \cdot \theta}{180}) \cdot [0,1,...,N-2,N-1]^{T}} \cdot symbols" />

where we have N antenas with different time delays to create the effect of coherent summation, as can be seen in the image below describing a phased array setup.

![image](https://en.wikipedia.org/wiki/Phased_array#/media/File:Phased_array_animation_with_arrow_10frames_371x400px_100ms.gif)


QPSK symbol set:
<img src="https://latex.codecogs.com/png.image?\dpi{110}&space;\bg_white&space;1&plus;j,&space;1-1j,&space;-1&plus;1j,&space;1-1j" title="\bg_white 1+j, 1-1j, -1+1j, 1-1j" />

![image](https://user-images.githubusercontent.com/60748408/150105145-57990d96-8ed5-4209-9538-1278fda34ae6.png)


A video describing the beamforming and tracking with respect to time

[![IMAGE ALT TEXT](https://img.youtube.com/vi/bOLJTF90Vzs/0.jpg)](https://youtu.be/bOLJTF90Vzs)
