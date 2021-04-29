`timescale 1ns / 1ns

module neuron # (
    parameter REFRAC_LEN = 4
)(
    input  logic  clk,
    input  logic  rst,
    input  logic  en,
    
    input  logic  signed [23:0] potent_in,  // potential incoming from external
    
    output logic  spike_out 
);
    logic signed [23:0] potent;
    logic signed [23:0] potent_thres;  // threshold potential to trigger a spike
    logic signed [23:0] potent_rest;   // resting potential
    logic       refrac_en;
    logic [3:0] refrac_timer;  // refractory period
    
    assign potent_thres = 24'h0d0000;
    assign potent_rest  = 24'hbc0000;
    
    always_ff @ (posedge clk)
    begin
        if (rst) begin
            potent    <= '0;
            spike_out <= '0;
        end
        else if (en) begin
            if (refrac_en == 1'b0) begin
                potent <= potent + potent_in;
                if (potent >= potent_thres) spike_out <= 1'b1;  // trigger a spike (and then enter refractory period)
                if (spike_out == 1'b1) begin
                    potent    <= potent_rest;  // enter refractory period
                    spike_out <= 1'b0;
                end
            end
            else begin
                potent    <= potent;
                spike_out <= 1'b0;
            end
        end 
    end
    
    always_ff @ (posedge clk)
    begin
        if (rst) begin
            refrac_en    <= '0;
            refrac_timer <= '0;
        end
        else if (en) begin
            if (spike_out == 1'b1) refrac_en <= 1'b1;  // enter refractory period in next clock
            if (refrac_timer == REFRAC_LEN - 1 || refrac_timer == 4'b1111) begin  // end of refractory period
                refrac_en    <= 1'b0;
                refrac_timer <= '0;
            end
            else if (refrac_en) refrac_timer <= refrac_timer + 1'b1;
        end
    end 
    
endmodule
