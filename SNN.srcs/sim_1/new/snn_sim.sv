`timescale 1ns / 1ns

module snn_sim();

    logic clk, rst, en;
    always begin clk <= 1'b1; #5; clk <= 1'b0; #5; end
    initial begin rst = 1'b1; #18; rst = 1'b0; end
    assign en = 1'b1;
    
    logic [6:0] spike_cnt[99:0];
    snn dut(clk, rst, en, spike_cnt);
    
endmodule
