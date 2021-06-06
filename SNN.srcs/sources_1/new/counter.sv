`timescale 1ns / 1ns

module counter #(
    parameter CNT_WIDTH
)(
    input logic  clk,
    input logic  rst,
    input logic  en,
    
    input logic  signal,  // signal to be counted
    
    output logic [CNT_WIDTH - 1 : 0] cnt
);

    always_ff @(posedge clk)
    begin
        if (rst) cnt <= '0;
        else if (en) begin
            if (signal) cnt <= cnt + 1'b1;
            else cnt <= cnt;
        end
    end
    
endmodule
