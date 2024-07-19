module cosine #(parameter STAGES = 21)
(
  input                   clk,
  input                   start,
  input                   reset,
  input  [31:0]           theta,
  output              done,
//  output reg[4:0]            count,
//  output signed [31:0]    result_y,
//  output signed [31:0]    result_z,
//  output signed [31:0]    result_pos,
  output signed [31:0]    result //
);

  // Internal variables
  wire signed [31:0]       x_1 [0:6];
  reg signed [31:0]       x_2 [0:6];
  reg signed [31:0]       x_3 [0:6];
  reg signed [31:0]       x_4 [0:6];
  wire signed [31:0]       y_1 [0:6];
  reg signed [31:0]       y_2 [0:6];
  reg signed [31:0]       y_3 [0:6];
  reg signed [31:0]       y_4 [0:6];
  wire signed [31:0]       z_1 [0:6];
  reg signed [31:0]       z_2 [0:6];
  reg signed [31:0]       z_3 [0:6];
  reg signed [31:0]       z_4 [0:6];
  reg [4:0] count;
  reg busy;

  // Constants
 reg signed [31:0] angle_table [0:24];
 initial begin
   // Precompute arctangent values for CORDIC iterations
 angle_table[0] = 32'b00000001100100100001111110110101;
	angle_table[1] = 32'b00000000111011010110001100111000;//0.463647609
 angle_table[2] = 32'b00000000011111010110110111010111;//0.2449786631
 angle_table[3] = 32'b00000000001111111010101101110101;//0.1243549945
 angle_table[4] = 32'b00000000000111111111010101011011;//0.06241881
 angle_table[5] = 32'b00000000000011111111111010101010;//0.03123983343
 angle_table[6] = 32'b00000000000001111111111111010101;//0.01562372862
 angle_table[7] = 32'b00000000000000111111111111111010;//0.00781234106
 angle_table[8] = 32'b00000000000000011111111111111111;
 angle_table[9] = 32'b00000000000000001111111111111111;
 angle_table[10] = 32'b00000000000000000111111111111111;
 angle_table[11] = 32'b00000000000000000011111111111111;//0.0004882812112
 angle_table[12] = 32'b00000000000000000001111111111111;//0.0002441406201
 angle_table[13] = 32'b00000000000000000000111111111111;//0.0001220703119
 angle_table[14] = 32'b00000000000000000000011111111111;//0.00006103515617
 angle_table[15] = 32'b00000000000000000000001111111111;//0.00003051757812
	angle_table[16] = 32'b00000000000000000000000111111111;
	angle_table[17] = 32'b00000000000000000000000011111111;
	angle_table[18] = 32'b00000000000000000000000001111111;
	angle_table[19] = 32'b00000000000000000000000000111111;
	angle_table[20] = 32'b00000000000000000000000000011111;
	angle_table[21] = 32'b00000000000000000000000000001111;
	angle_table[22] = 32'b00000000000000000000000000000111;
	angle_table[23] = 32'b00000000000000000000000000000011;
	angle_table[24] = 32'b00000000000000000000000000000001;


 end

 reg signed[31:0] cosine [0:6];
 reg signed [31:0] sine [0:6];
 reg signed [31:0] z_tmp [0:6];
 reg [4:0] reg_count;
  
  always @ (posedge clk) begin
    if (start) begin
      count = 0;
		reg_count = 0;
    end
	 else if (count == STAGES) begin
	   count = count;
		reg_count = reg_count;
	 end
    else begin
      count = count + 3;
		reg_count = reg_count + 1;
    end
  end
  
  	always@(posedge clk) begin
	   if (reset) begin
		   busy <= 1'b0;
		end
		else if (start) begin
		   busy <= 1'b1;
		end
		else if (count == STAGES) begin
		   busy <= 1'b0;
		end
	end

  // CORDIC algorithm
//  always @(*) begin
//    if (start) begin
//      z_1 <= theta;
//      x_1 <= 32'b00000001001101101110100111011110; // Initialize x with cosine value of 0
//      y_1 <= 0; 
//    end
//    else begin
		
//		x_1 <= cosine[reg_count] + ((z_tmp[reg_count][31]) ? (sine[reg_count]>>>(count)) : (-(sine[reg_count]>>>(count))));
//      y_1 <= sine[reg_count] + ((z_tmp[reg_count][31]) ? (-(cosine[reg_count]>>>(count))) : (cosine[reg_count]>>>(count)));
//      z_1 <= z_tmp[reg_count] + ((z_tmp[reg_count][31]) ? angle_table[(count)] : (-angle_table[(count)]));

//     assign x_1[0] = cosine[0] + ((z_tmp[0][31]) ? (sine[0]) : (-(sine[0])));
//     assign y_1[0] = sine[0] + ((z_tmp[0][31]) ? (-(cosine[0])) : (cosine[0]));
//     assign z_1[0] = z_tmp[0] + ((z_tmp[0][31]) ? angle_table[0] : (-angle_table[0]));
//		
//	  assign	x_1[1] = cosine[1] + ((z_tmp[1][31]) ? (sine[1]>>>3) : (-(sine[1]>>>3)));
//     assign y_1[1] = sine[1] + ((z_tmp[1][31]) ? (-(cosine[1]>>>3)) : (cosine[1]>>>3));
//     assign z_1[1] = z_tmp[1] + ((z_tmp[1][31]) ? angle_table[3] : (-angle_table[3]));
//		
//	  assign x_1[2] = cosine[2] + ((z_tmp[2][31]) ? (sine[2]>>>6) : (-(sine[2]>>>6)));
//     assign y_1[2] = sine[2] + ((z_tmp[2][31]) ? (-(cosine[2]>>>6)) : (cosine[2]>>>6));
//     assign z_1[2] = z_tmp[2] + ((z_tmp[2][31]) ? angle_table[6] : (-angle_table[6]));
//		
//	  assign x_1[3] = cosine[3] + ((z_tmp[3][31]) ? (sine[3]>>>9) : (-(sine[3]>>>9)));
//     assign y_1[3] = sine[3] + ((z_tmp[3][31]) ? (-(cosine[3]>>>9)) : (cosine[3]>>>9));
//     assign z_1[3] = z_tmp[3] + ((z_tmp[3][31]) ? angle_table[9] : (-angle_table[9]));
//		
//	  assign	x_1[4] = cosine[4] + ((z_tmp[4][31]) ? (sine[4]>>>12) : (-(sine[4]>>>12)));
//     assign y_1[4] = sine[4] + ((z_tmp[4][31]) ? (-(cosine[4]>>>12)) : (cosine[4]>>>12));
//     assign z_1[4] = z_tmp[4] + ((z_tmp[4][31]) ? angle_table[12] : (-angle_table[12]));
//		
//	  assign	x_1[5] = cosine[5] + ((z_tmp[5][31]) ? (sine[5]>>>16) : (-(sine[5]>>>16)));
//     assign y_1[5] = sine[5] + ((z_tmp[5][31]) ? (-(cosine[5]>>>16)) : (cosine[5]>>>16));
//     assign z_1[5] = z_tmp[5] + ((z_tmp[5][31]) ? angle_table[16] : (-angle_table[16]));


     assign x_1[0] = cosine[0] + ((z_tmp[0][31]) ? (sine[0]) : (-(sine[0])));
     assign y_1[0] = sine[0] + ((z_tmp[0][31]) ? (-(cosine[0])) : (cosine[0]));
     assign z_1[0] = z_tmp[0] + ((z_tmp[0][31]) ? angle_table[0] : (-angle_table[0]));
		
	  assign	x_1[1] = cosine[1] + ((z_tmp[1][31]) ? (sine[1]>>>4) : (-(sine[1]>>>4)));
     assign y_1[1] = sine[1] + ((z_tmp[1][31]) ? (-(cosine[1]>>>4)) : (cosine[1]>>>4));
     assign z_1[1] = z_tmp[1] + ((z_tmp[1][31]) ? angle_table[4] : (-angle_table[4]));
		
	  assign x_1[2] = cosine[2] + ((z_tmp[2][31]) ? (sine[2]>>>8) : (-(sine[2]>>>8)));
     assign y_1[2] = sine[2] + ((z_tmp[2][31]) ? (-(cosine[2]>>>8)) : (cosine[2]>>>8));
     assign z_1[2] = z_tmp[2] + ((z_tmp[2][31]) ? angle_table[8] : (-angle_table[8]));
		
	  assign x_1[3] = cosine[3] + ((z_tmp[3][31]) ? (sine[3]>>>12) : (-(sine[3]>>>12)));
     assign y_1[3] = sine[3] + ((z_tmp[3][31]) ? (-(cosine[3]>>>12)) : (cosine[3]>>>12));
     assign z_1[3] = z_tmp[3] + ((z_tmp[3][31]) ? angle_table[12] : (-angle_table[12]));
	  
	  
	  assign	x_1[4] = cosine[4] + ((z_tmp[4][31]) ? (sine[4]>>>16) : (-(sine[4]>>>16)));
     assign y_1[4] = sine[4] + ((z_tmp[4][31]) ? (-(cosine[4]>>>16)) : (cosine[4]>>>16));
     assign z_1[4] = z_tmp[4] + ((z_tmp[4][31]) ? angle_table[16] : (-angle_table[16]));
		
		


		
//		x_1【6】 <= cosine[6] + ((z_tmp[6][31]) ? (sine[6]>>>20) : (-(sine[6]>>>20)));
//      y_1【6】 <= sine[6] + ((z_tmp[6][31]) ? (-(cosine[6]>>>20)) : (cosine[6]>>>20));
//      z_1【6】 <= z_tmp[6] + ((z_tmp[6][31]) ? angle_table[20] : (-angle_table[20]));
		
//    end
//  end
  
    integer i;
	always@(*) begin
	 
    for (i=0;i<6;i=i+1) begin
	   x_2[i] = x_1[i] + ((z_1[i][31]) ? (y_1[i]>>>((i<<2)+1)) : (-(y_1[i]>>>((i<<2)+1))));
      y_2[i] = y_1[i] + ((z_1[i][31]) ? (-(x_1[i]>>>((i<<2)+1))) : (x_1[i]>>>((i<<2)+1)));
      z_2[i] = z_1[i] + ((z_1[i][31]) ? angle_table[((i<<2)+1)] : (-angle_table[((i<<2)+1)]));
		
      x_3[i] = x_2[i] + ((z_2[i][31]) ? (y_2[i]>>>((i<<2)+2)) : (-(y_2[i]>>>((i<<2)+2))));
      y_3[i] = y_2[i] + ((z_2[i][31]) ? (-(x_2[i]>>>((i<<2)+2))) : (x_2[i]>>>((i<<2)+2)));
		z_3[i] = z_2[i] + ((z_2[i][31]) ? angle_table[((i<<2)+2)] : (-angle_table[((i<<2)+2)]));
		
		x_4[i] = x_3[i] + ((z_3[i][31]) ? (y_3[i]>>>((i<<2)+3)) : (-(y_3[i]>>>((i<<2)+3))));
      y_4[i] = y_3[i] + ((z_3[i][31]) ? (-(x_3[i]>>>((i<<2)+3))) : (x_3[i]>>>((i<<2)+3)));
		z_4[i] = z_3[i] + ((z_3[i][31]) ? angle_table[((i<<2)+3)] : (-angle_table[((i<<2)+3)]));
	 end
	end
 
  
//  assign x_2 = x_1 + ((z_1[31]) ? (y_1>>>(count+1)) : (-(y_1>>>(count+1))));
//  
//  assign y_2 = y_1 + ((z_1[31]) ? (-(x_1>>>(count+1))) : (x_1>>>(count+1)));
//  assign z_2 = z_1 + ((z_1[31]) ? angle_table[(count+1)] : (-angle_table[(count+1)]));
//
//
//  assign x_3 = x_2 + ((z_2[31]) ? (y_2>>>(count+2)) : (-(y_2>>>(count+2))));
//  assign y_3 = y_2 + ((z_2[31]) ? (-(x_2>>>(count+2))) : (x_2>>>(count+2)));
//  assign z_3 = z_2 + ((z_2[31]) ? angle_table[(count+2)] : (-angle_table[(count+2)]));

integer j;

always@(posedge clk) begin
  //if (start) begin
    z_tmp[0] <= theta;
    cosine[0] <= 32'b00000001001101101110100111011110; // Initialize x with cosine value of 0
    sine[0] <= 0; 
    //end
	 //else begin
	 for (j = 0; j<6; j=j+1) begin
  cosine[j+1] <= x_4[j];
  sine[j+1] <= y_4[j];
  z_tmp[j+1] <= z_4[j];
  
  end
end

  
  
//  always@(*) begin
//    if (reg_count == 5 && busy == 1) begin
//    done = 1;
//    //result = x[STAGES-2];
//	 end
//	 else begin
//	 done = 0;
//   //result = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
//	 end
//  end
// 
 assign result = cosine[5];
 assign done = 1'b1;
  

endmodule