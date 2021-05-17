`timescale 1ns / 1ns

module neuron # (
    parameter
    PREV_LAYER_NEURONS,
    WEIGHT_WIDTH = 32,
    POTENT_WIDTH = 48
)(
    input  logic  clk,
    input  logic  rst,
    input  logic  en,
    
    // weight memory write port
    input  logic  [9:0] waddr,
    input  logic  [WEIGHT_WIDTH-1 : 0] wdata,
    input  logic  wen,
    
    input  logic  [PREV_LAYER_NEURONS-1 : 0] spike_in,
    output logic  spike_out 
);
    
    logic signed [POTENT_WIDTH-1 : 0] potent;  // membrane potential of this neuron
    localparam   potent_thres = 'h00000a;      // threshold potential to trigger a spike
    localparam   potent_rest  = 'h000000;      // resting potential
    
    logic signed [WEIGHT_WIDTH-1 : 0] synapses_weight[PREV_LAYER_NEURONS-1 : 0];
    logic signed [WEIGHT_WIDTH-1 : 0] potent_in[PREV_LAYER_NEURONS-1 : 0];  // won't exceed weight width
    logic signed [POTENT_WIDTH-1 : 0] sum_potent_in;
    
    logic       refrac_en;
    logic [3:0] refrac_timer;  // refractory period
    localparam  refrac_len = 'd5;
    
    always_ff @(posedge clk)
    begin
        if (wen) synapses_weight[waddr] <= wdata;  // must manually initialize; don't reset
    end
    
    always_comb
    begin
        for (integer i = 0; i < PREV_LAYER_NEURONS; i = i+1)
            potent_in[i] = spike_in[i] ? synapses_weight[i] : '0;
    end
    
    always_comb
    begin
        sum_potent_in = '0;
        for (integer i = 0; i < PREV_LAYER_NEURONS; i = i+1)
            sum_potent_in = sum_potent_in + potent_in[i];
    end
    
    always_ff @ (posedge clk)
    begin
        if (rst) begin
            potent    <= '0;
            spike_out <= '0;
        end
        else if (en) begin
            if (refrac_en == 1'b0) begin
                potent <= potent + sum_potent_in;
                if (potent >= potent_thres) spike_out <= 1'b1;  // trigger a spike
                if (spike_out == 1'b1) begin
                    potent    <= potent_rest;  // enter refractory period
                    spike_out <= 1'b0;
                end
            end
            else begin  // in refractory period
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
            if (refrac_timer == refrac_len - 1) begin  // end of refractory period
                refrac_en    <= 1'b0;
                refrac_timer <= '0;
            end
            else if (refrac_en) refrac_timer <= refrac_timer + 1'b1;
        end
    end 
    
endmodule
