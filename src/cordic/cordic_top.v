module cordic_top(
    input             clock,
    input             clk_en,
    input             reset,
    input             start,
    input [31:0]      dataa,

    output            done,
    output [31:0]     result
);

wire [31:0] fixed_angle, fixed_result, subwire;
wire convert_done, convert_back_done, sub_done;
convert_25 myConvert (
    .clock(clock),
    .clk_en(clk_en),
    .reset(reset),
    .start(1'b1),
    .dataa(dataa),
    .done(convert_done),
    .result(fixed_angle)
);

cosine myCosine(
    .clk(clock),
    .start(1'b1),
    .theta(fixed_angle),
	 .reset(reset),
    .done(convert_back_done),
    .result(fixed_result)
);



convert_back_25 myCon (
    .clock(clock),
    .clk_en(clk_en),
    .reset(reset),
    .start(1'b1),
    .dataa(fixed_result),
    .done(sub_done),
    .result(subwire)
);

//convert_back myCon (
//    .clock(clock),
//    .clk_en(clk_en),
//    .reset(reset),
//    .start(convert_done),
//    .dataa(fixed_angle),
//    .done(sub_done),
//    .result(subwire)
//);

assign done = 1'b1;
assign result = subwire;

endmodule