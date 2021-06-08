## Spiking Neural Network RTL Implementation

A 784-100 Spiking Neural Network, implemented in SystemVerilog, and passed Vivado behavioral simulation. Failed to run on FPGA board because the hardware resources on the FPGA board we use (Xilinx xc7z010clg400-1) are exhausted.

This repo works together with https://github.com/oshears/fpga_snn_models. You encode an MNIST image into spike trains with Python scripts, write them into a ROM and pass them to the SNN. The synaptic weights of the SNN are also learned using Python scripts. After SNN finishes, we use a tournament tree to select the winner neuron (neuron with most spikes) and thus classifying the input image.

