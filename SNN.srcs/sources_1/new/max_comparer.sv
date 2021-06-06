`timescale 1ns / 1ns

module max_comparer #(
    parameter ITEM_CNT,
    DATA_WIDTH, TAG_WIDTH
)(
    input  logic [DATA_WIDTH-1 : 0] in_data[ITEM_CNT-1 : 0],
    output logic [TAG_WIDTH -1 : 0] out_tag
);
    
    comparer_recursivenode #(
        .LEFT(0), .RIGHT(ITEM_CNT-1),
        .DATA_WIDTH(DATA_WIDTH), .TAG_WIDTH(TAG_WIDTH)
    ) comparer_tree_root(
        .in_data(in_data),
        .out_tag(out_tag)
    );
    
endmodule
