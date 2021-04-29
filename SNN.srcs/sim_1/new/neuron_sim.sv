`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/29 00:26:30
// Design Name: 
// Module Name: neuron_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module neuron_sim();
    logic clk, rst, en;
    always begin clk <= 1'b1; #5; clk <= 1'b0; #5; end
    initial begin rst = 1'b1; #12; rst = 1'b0; end
    initial begin en = 1'b1; #20 en = 1'b0; #10 en = 1'b1; #70 en = 1'b0; #10 en = 1'b1; end
    
    logic signed [23:0] potent_in;
    always begin potent_in = {$random % 2048, 12'h0}; #10; end
    // $random % 2048: [-7ff, 7ff]
    // (can't write 'd2048 or 'h800 in place of 2048, because this would
    //  turn the result into unsigned)
    
    logic spike_out;
    neuron dut(clk, rst, en, potent_in, spike_out);
     
endmodule
