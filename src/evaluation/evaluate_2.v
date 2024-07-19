module evaluate_2(input         clock,
    input         clk_en,
    input         reset,
    input         start,
    //input         last,
    input [31:0]  dataa,//x[i]
    input [31:0]  datab,

    output reg       done,
    output [31:0] result
);

localparam [31:0] cosine_const = 32'b01000011000000000000000000000000;
localparam [31:0] mult_const = 32'b00111111000000000000000000000000;

wire sub_done, div_done, add_done, mult_done_1, mult_done_2, mult_done_3, cosine_done;
wire [31:0] sub_result, div_result, mult_result_1, mult_result_2, mult_result_3, add_result, cosine_result, sreg_out_1, sreg_out_2;
reg [4:0] count;
reg [5:0] end_count;

wire start_array;
assign start_array = (datab == 32'b00111111100000000000000000000000);
wire last;
assign last = (datab==32'b10111111100000000000000000000000);
//always@(posedge clock) begin
//    if (last) begin
//	     last <= 0;
//		  past_last <= 1;
//	 end
//	 else if (reset) begin
//	     past_last <= 0;
//	 end
//	 else if (past_last) begin
//	     last <= 0;
//		  past_last <= 1;
//	 end
//	 else begin
//	   last <= (datab[31]);
//		past_last <= 0;
//	 end
//end
//assign last = (datab[31])^last;

always@(posedge clock) begin
  if (start_array) begin
    count <= 0;
  end
  else if (count == 5'b11111) begin
    count <= count;
  end
  else begin
    count <= count + 1;
  end
end

//reg[5:0] end_count;
//always@(posedge clock) begin
//    if (last) begin
//        end_count <= 0;
//    end
//	 else if (start_array) begin
//	     end_count <= 6'b111111;
//	 end
//    else if (end_count == 6'b111111) begin
//        end_count <= end_count;
//    end
//    else begin
//        end_count <= end_count + 1;
//    end
//end


//to calculate 0.5*x[i]
mult my_mult_1(
    //.clk_en(clk_en),
    .clk(clock),
    .areset(reset),
    //.start(start),
    .a(dataa),
    .b(mult_const),
    //.done(mult_done_1),
    .q(mult_result_1)
);

shift_reg #(26) sreg_2(
    .clk(clock),
    .data_in(mult_result_1),
    .data_out(sreg_out_2)
);

//to calculate x[i]^2
mult my_mult_2(
    //.clk_en(clk_en),
    .clk(clock),
    .areset(reset),
    //.start(start),
    .a(dataa),
    .b(dataa),
    //.done(mult_done_2),
    .q(mult_result_2)
);

shift_reg SREG_1(
    .clk(clock),
    .data_in(mult_result_2),
    .data_out(sreg_out_1)
);

//to calculate x[i] -128
sub my_sub(
    //.clk_en(clk_en),
    .clk(clock),
    .areset(reset),
    //.start(start),
    .a(dataa),
    .b(cosine_const),
    //.done(sub_done),
    .q(sub_result)
);

//to calculate (x[i] -128)/128
div my_div(
    .clk_en(clk_en),
    .clock(clock),
    .reset(reset),
   // .start(sub_done),
    .start(1'b1),
    .dataa(sub_result),
    .datab(cosine_const),
    .done(div_done),
    .result(div_result)
);

//to calcualte cosine
cordic_top my_cosine(
    .clock(clock),
    .clk_en(clk_en),
    .start(1'b1),
    .reset(reset),
    .dataa(div_result),
    .done(cosine_done),
    .result(cosine_result)
);

//x[i]^2*cosine
mult my_mult_3(
    //.clk_en(clk_en),
    .clk(clock),
    .areset(reset),
    //.start(cosine_done),
    .a(sreg_out_1),
    .b(cosine_result),
    //.done(mult_done_3),
    .q(mult_result_3)
);

add my_add(
    .clk(clock),
    //.clk_en(clk_en),
    .areset(reset),
    //.start(mult_done_3),
    .a(sreg_out_2),
    .b(mult_result_3),
    //.done(add_done),
    .q(add_result)
);

reg [31:0] sum, add_result_1;
wire [31:0] sum_tmp;
reg [31:0] result_1;
reg busy;
//always@(*) begin
//    if (end_count == 6'd31) begin
//        result_1 <= sum_tmp;
//    end
//end
always@(*) begin
    if (reset || count < 6'd30) begin
        add_result_1 <= 0;
		  sum <= 0;
    end
//	 else if (count[0]==1) begin
//	     add_result_1 <= 0;
//		  sum <= sum;
////    else if (end_count == 6'd32) begin
////        add_result_1 <= result_1;
////        sum <= sum_tmp;
//  end
    else begin
        add_result_1 <= add_result;
		  sum <= sum_tmp;
    end
end


reg [5:0] counter;
always@(posedge clock) begin
	   if (reset) begin
		    counter <= 6'b111111;
		end
		else if (start) begin
		    counter <= last ? 6'd30 : 6'd1;
		end
//		else if (counter == 6'b111111) begin
//		    counter <= counter;
//		end
		else begin
		    counter <= counter -1;
		end
	end
	
	always@(posedge clock) begin
	   if (reset) begin
		   busy <= 1'b0;
		end
		else if (start) begin
		   busy <= 1'b1;
		end
		else if (counter == 2'b00) begin
		   busy <= 1'b0;
		end
	end
	always@(*) begin
	   if (counter == 6'b000000 && busy == 1) begin
		   done = 1'b1;
		end
		else begin
		   done = 1'b0;
		end
     
	end

add my_add_1(
    .clk(clock),
    //.clk_en(clk_en),
    .areset(reset),
    //.start(mult_done_3),
    .a(add_result_1),
    .b(sum),
    //.done(add_done),
    .q(sum_tmp)
);
assign result = add_result;
//assign done = (end_count == 6'b111111) || (end_count == 6'd34);
endmodule
