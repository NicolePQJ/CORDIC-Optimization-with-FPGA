module evaluate_3(input         clock,
    input         clk_en,
    input         reset,
    input         start,
    input [31:0]  dataa,//x[i]

    output        done,
//	 output        sub_done,
//	 output        div_done,
//	 output        mult_done_1,
//	 output        mult_done_2,
//	 output        mult_done_3,
//	 output        add_done,
//	 output        cosine_done,
//	 output [31:0] sub_result,
//	 output [31:0] div_result,
//	 output [31:0] mult_result_1,
//	 output [31:0] mult_result_2,
//	 output [31:0] mult_result_3,
//	 output [31:0] add_result,
//	 output [31:0] cosine_result,
    output [31:0] result
);

//reg [31:0] const_128;
//reg [31:0] const_half;
//
//initial begin
//    const_128 = 32'h43000000;
//    const_half = 32'h3f000000;
//end

localparam [31:0] cosine_const = 32'b01000011000000000000000000000000;
localparam [31:0] mult_const = 32'b00111111000000000000000000000000;

wire sub_done, div_done, mult_done_1, mult_done_2, mult_done_3, add_done, cosine_done;
wire [31:0] sub_result, div_result, mult_result_1, mult_result_2, mult_result_3, add_result, cosine_result;

//to calculate 0.5*x[i]
new_mult my_mult_1(
    .clk_en(clk_en),
    .clock(clock),
    .reset(reset),
    .start(start),
    .dataa(dataa),
    .datab(const_half),
    .done(mult_done_1),
    .result(mult_result_1)
);

//to calculate x[i]^2
new_mult my_mult_2(
    .clk_en(clk_en),
    .clock(clock),
    .reset(reset),
    .start(start),
    .dataa(dataa),
    .datab(dataa),
    .done(mult_done_2),
    .result(mult_result_2)
);

//to calculate x[i] -128
new_sub my_sub(
    .clk_en(clk_en),
    .clock(clock),
    .reset(reset),
    .start(start),
    .dataa(dataa),
    .datab(const_128),
    .done(sub_done),
    .result(sub_result)
);

//to calculate (x[i] -128)/128
div my_div(
    .clk_en(clk_en),
    .clock(clock),
    .reset(reset),
    .start(sub_done),
    .dataa(sub_result),
    .datab(const_128),
    .done(div_done),
    .result(div_result)
);

//to calcualte cosine
cordic_top my_cosine(
    .clock(clock),
    .clk_en(clk_en),
    .start(div_done),
    .reset(reset),
    .dataa(div_result),
    .done(cosine_done),
    .result(cosine_result)
);

wire mult_3_start;
assign mult_3_start = mult_done_2 && cosine_done;
//x[i]^2*cosine
new_mult my_mult_3(
    .clk_en(clk_en),
    .clock(clock),
    .reset(reset),
    .start(cosine_done),
    .dataa(mult_result_2),
    .datab(cosine_result),
    .done(mult_done_3),
    .result(mult_result_3)
);

wire add_start;
assign add_start = mult_done_3 && mult_done_1;
new_add my_add(
    .clock(clock),
    .clk_en(clk_en),
    .reset(reset),
    .start(mult_done_3),
    .dataa(mult_result_1),
    .datab(mult_result_3),
    .done(add_done),
    .result(add_result)
);

assign result = mult_result_1;
assign done = mult_done_1;
endmodule
