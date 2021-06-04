`timescale 1ns / 1ns

module snn #(
    parameter
    WEIGHT_WIDTH = 32,
    POTENT_WIDTH = 48,
    TIMESTEP_MAX = 200
)(
    input  logic  clk,
    input  logic  rst,
    input  logic  en,
    
    output logic [CNT_WIDTH-1 : 0] hidden_layer_spike_cnt[HIDDEN_LAYER_NEURONS-1 : 0]
);

    localparam INPUT_LAYER_NEURONS = 'd784;
    localparam HIDDEN_LAYER_NEURONS = 'd100;  // currently only one hidden layer
    localparam BRAM_LATENCY = 'd2;
    localparam INIT_STEPS = INPUT_LAYER_NEURONS + BRAM_LATENCY;
    localparam TIMESTEP_MAX_I = TIMESTEP_MAX + BRAM_LATENCY;  // num of lines in the input coe file + bram latency
    localparam CNT_WIDTH = 'd7;  // = width of TIMESTEP/2

    logic [9:0] init_timer;  // [0, 784); iterate over the synaptic weight ROM to load weight into neurons
    logic init_ren, init_wen, init_done;
    always_ff @(posedge clk)
    begin
        if (rst) init_timer <= 1'b0;
        else if (en && !init_done) init_timer <= init_timer + 1'b1;
    end
    
    assign init_ren = init_timer < INPUT_LAYER_NEURONS + 1'd1;  // add 1 clock to ensure the last read is done (only necessary for the BRAM IP)
    assign init_wen = init_timer >= BRAM_LATENCY && init_timer < INIT_STEPS;
    assign init_done = init_timer == INIT_STEPS;
    
    logic [HIDDEN_LAYER_NEURONS * WEIGHT_WIDTH - 1 : 0] init_weight; 
    weight_mem u_weight_mem(
        .clka(clk),
        .ena(en && init_ren),
        .addra(init_timer),
        .douta(init_weight)
    );
    

    logic [7:0] timestep;  // [0, 200)
    logic timestep_en;
    always_ff @(posedge clk)
    begin
        if (rst) timestep <= '0;
        else if (en && init_done && timestep_en) timestep <= timestep + 1'b1;
    end
    assign timestep_en = timestep < TIMESTEP_MAX_I;  // freeze after all simulation timestep elapsed

    logic [INPUT_LAYER_NEURONS-1 : 0] input_spike;
    input_mem u_input_mem(
        .clka(clk),
        .ena(en && timestep < TIMESTEP_MAX + 'd1),
        .addra(timestep),
        .douta(input_spike)
    );
    
    
    logic [HIDDEN_LAYER_NEURONS-1 : 0] hidden_layer_spike;
    hidden_layer #(
        .WEIGHT_WIDTH(WEIGHT_WIDTH),
        .POTENT_WIDTH(POTENT_WIDTH),
        .PREV_LAYER_NEURONS(INPUT_LAYER_NEURONS),
        .CURR_LAYER_NEURONS(HIDDEN_LAYER_NEURONS)
    ) u_hidden_layer(
        .clk(clk),
        .rst(rst),
        .en(en && timestep_en),
        
        .waddr(init_timer - BRAM_LATENCY),
        .wdata(init_weight),
        .wen(en && init_wen),
        
        .prev_layer_spike(input_spike),
        .curr_layer_spike(hidden_layer_spike)
    );
    
    logic [CNT_WIDTH-1 : 0] hidden_layer_spike_cnt[HIDDEN_LAYER_NEURONS-1 : 0];
    generate
        for (genvar i = 0; i < HIDDEN_LAYER_NEURONS; i++)
            counter #(
                .CNT_WIDTH(CNT_WIDTH)
            )
            spike_counter(
                .clk(clk),
                .rst(rst),
                .en(en && timestep_en),
                
                .signal(hidden_layer_spike[i]),
                
                .cnt(hidden_layer_spike_cnt[i])
            );
    endgenerate
    
endmodule
