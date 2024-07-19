module shift_reg #(parameter DELAY=24)
(
    input     clk,
    input [31:0] data_in,
    output [31:0] data_out
);

reg [31:0] sreg [0:DELAY-1];
genvar i;

generate
 for(i=1; i<DELAY; i= i+1) begin:sreg_1
   always@(posedge clk) begin
    	sreg[i] <= sreg[i-1];
    end
	 //data_cout <= sreg[DELAY-1];
end
endgenerate

always@(posedge clk) begin
  sreg[0] <= data_in;
end

assign data_out = sreg[DELAY-1][31:0];

endmodule