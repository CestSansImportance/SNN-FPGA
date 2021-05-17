`timescale 1ns / 1ns

module hidden_layer #(
    parameter
    WEIGHT_WIDTH = 32,
    POTENT_WIDTH = 48,
    PREV_LAYER_NEURONS,
    CURR_LAYER_NEURONS
)(
    input  logic  clk,
    input  logic  rst,
    input  logic  en,
    
    // weight memory write port
    input  logic  [9:0] waddr,
    input  logic  [CURR_LAYER_NEURONS * WEIGHT_WIDTH - 1 : 0] wdata,
    input  logic  wen,
    
    input  logic  [PREV_LAYER_NEURONS - 1 : 0] prev_layer_spike,
    output logic  [CURR_LAYER_NEURONS - 1 : 0] curr_layer_spike
);

    generate
        for (genvar k = 0; k < CURR_LAYER_NEURONS; k++)
            neuron #(
                .PREV_LAYER_NEURONS(PREV_LAYER_NEURONS),
                .POTENT_WIDTH(POTENT_WIDTH),
                .WEIGHT_WIDTH(WEIGHT_WIDTH)
            )
            u_neuron(
                .clk(clk),
                .rst(rst),
                .en(en),
                
                .waddr(waddr),
                .wdata(wdata[(k+1) * WEIGHT_WIDTH - 1 -: WEIGHT_WIDTH]),
                .wen(wen),
                
                .spike_in(prev_layer_spike),
                .spike_out(curr_layer_spike[k])
            );
    endgenerate
    
endmodule
