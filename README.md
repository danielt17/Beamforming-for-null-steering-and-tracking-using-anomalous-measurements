# Beamforming-and-tracking-using-anomalous-measurements

This repository contains MATLAB code for the following simulation:
1. A comparison of beamforming algorithms: Max Ratio Combining (MRC) and Minimum Variance Distortioless Response (MVDR)
2. The simulation contains a signal we want to track, and a jammer which we want to nullify.
3. The signal and jammer sources are moving with constant velocity, the jammer has twice the velocity of the signal source.
4. We use a set of pilot signals to estimate the channel model (weights).
5. The estimated QPSK symbols are than evaluated using Error Vector Magnitude (EVM), where the MVDR beamformer comes on top.
6. Finally the estimated Direction of Arrivals (DoA), go through a process of discovering anomalies and fitting a linear model using the Random Sample Consensus (RANSAC) algorithm. 

A video describing the beamforming and tracking with respect to time

[![IMAGE ALT TEXT](https://img.youtube.com/vi/bOLJTF90Vzs/0.jpg)](https://youtu.be/bOLJTF90Vzs)
