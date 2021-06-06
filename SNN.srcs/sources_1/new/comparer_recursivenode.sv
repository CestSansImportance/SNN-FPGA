`timescale 1ns / 1ns

module comparer_recursivenode #(
    parameter LEFT, RIGHT,
    DATA_WIDTH, TAG_WIDTH, MID = (LEFT + RIGHT) / 2   
)(
    input  logic [DATA_WIDTH-1 : 0] in_data[RIGHT : LEFT],
    output logic [TAG_WIDTH -1 : 0] out_tag
);
    if (LEFT == RIGHT)
    begin
        assign out_tag = LEFT;
    end
    
    else begin
        logic [TAG_WIDTH-1 : 0] lch_max_tag;  // lch: left  child
        logic [TAG_WIDTH-1 : 0] rch_max_tag;  // rch: right child
        
        logic [DATA_WIDTH-1 : 0] lch_in[MID : LEFT];
        assign lch_in = in_data[MID : LEFT];
        comparer_recursivenode #(
            .LEFT(LEFT), .RIGHT(MID),
            .DATA_WIDTH(DATA_WIDTH), .TAG_WIDTH(TAG_WIDTH)
        ) lch(
           .in_data(lch_in),  // .in_data(in_data[MID : LEFT]),  --strange bug: high end are Z in simulation
           .out_tag(lch_max_tag)
        );
        comparer_recursivenode #(
            .LEFT(MID+1), .RIGHT(RIGHT),
            .DATA_WIDTH(DATA_WIDTH), .TAG_WIDTH(TAG_WIDTH)
        ) rch(
           .in_data(in_data[RIGHT : MID+1]),
           .out_tag(rch_max_tag)
        );
        
        logic cmp;
        assign cmp = in_data[lch_max_tag] < in_data[rch_max_tag];
        assign out_tag = cmp ? rch_max_tag : lch_max_tag;
    end
    
endmodule
