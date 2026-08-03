`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/30/2026 12:29:03 PM
// Design Name: 
// Module Name: key_expansion
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module key_expansion(
    input wire [127:0] key,
    input wire [3:0] round_number,
    output reg [127:0] out
    );
    
    // This looks so bad 
    // But the original idea doesn't work
    // You can't just spitball change sb_in0 = ..., sb_in1 = ... 
    // The code in THIS module executes sequentially but we can't control the sbox module.
    wire [7:0] sb_in0, sb_in1, sb_in2, sb_in3;
    // IMPORTANT: The RotWord is handled here now
    // So let's hope this knocks out Sbox + RotWord in one go? 
    assign sb_in0 = key[13*8 +: 8]; 
    assign sb_in1 = key[14*8 +: 8]; 
    assign sb_in2 = key[15*8 +: 8]; 
    assign sb_in3 = key[12*8 +: 8];  
    wire [7:0] sb_out0, sb_out1, sb_out2, sb_out3;
    sbox sb0(.sbox_in(sb_in0), .sbox_out(sb_out0));
    sbox sb1(.sbox_in(sb_in1), .sbox_out(sb_out1));
    sbox sb2(.sbox_in(sb_in2), .sbox_out(sb_out2));
    sbox sb3(.sbox_in(sb_in3), .sbox_out(sb_out3));
    
    always @(*) begin
        // === Column 0 === //
       // RotWord
       // IMPORTANT: No longer needed because I rotated the indices in the Sbox inputs above
       //out[0*8 +: 8] = key[13*8 +: 8];
       //out[1*8 +: 8] = key[14*8 +: 8];
       //out[2*8 +: 8] = key[15*8 +: 8];
       //out[3*8 +: 8] = key[12*8 +: 8];
       
       //SubWord
       //sb_in0 = out[0*8 +: 8];
       out[0*8 +: 8] = sb_out0;
       //sb_in1 = out[1*8 +: 8];
       out[1*8 +: 8] = sb_out1;
       //sb_in2 = out[2*8 +: 8];
       out[2*8 +: 8] = sb_out2;
       //sb_in3 = out[3*8 +: 8];
       out[3*8 +: 8] = sb_out3;
       
       //RoundConstant (just the first row)
       out[0*8 +: 8] = out[0*8 +: 8] ^ round_constant(round_number);
       
       // XOR with current column 0
       out[0*8 +: 8] = out[0*8 +: 8] ^ key[0*8 +: 8];
       out[1*8 +: 8] = out[1*8 +: 8] ^ key[1*8 +: 8];
       out[2*8 +: 8] = out[2*8 +: 8] ^ key[2*8 +: 8];
       out[3*8 +: 8] = out[3*8 +: 8] ^ key[3*8 +: 8];
       
       // === Columns 1-3 === //
       // New column 1: New column 0 XOR Current column 1
       out[4*8 +: 8] = out[0*8 +: 8] ^ key[4*8 +: 8];
       out[5*8 +: 8] = out[1*8 +: 8] ^ key[5*8 +: 8];
       out[6*8 +: 8] = out[2*8 +: 8] ^ key[6*8 +: 8];
       out[7*8 +: 8] = out[3*8 +: 8] ^ key[7*8 +: 8];
       
       // New column 2: New column 1 XOR Current column 2
       out[8*8 +: 8] = out[4*8 +: 8] ^ key[8*8 +: 8];
       out[9*8 +: 8] = out[5*8 +: 8] ^ key[9*8 +: 8];
       out[10*8 +: 8] = out[6*8 +: 8] ^ key[10*8 +: 8];
       out[11*8 +: 8] = out[7*8 +: 8] ^ key[11*8 +: 8];
       
       // New column 3: New column 2 XOR Current column 3
       out[12*8 +: 8] = out[8*8 +: 8] ^ key[12*8 +: 8];
       out[13*8 +: 8] = out[9*8 +: 8] ^ key[13*8 +: 8];
       out[14*8 +: 8] = out[10*8 +: 8] ^ key[14*8 +: 8];
       out[15*8 +: 8] = out[11*8 +: 8] ^ key[15*8 +: 8];
    end
    
    function [7:0] round_constant(input [3:0] round_number);
    begin
        case (round_number)
            4'd1: round_constant = 8'h01;
            4'd2:round_constant = 8'h02;
            4'd3:round_constant = 8'h04;
            4'd4:round_constant = 8'h08;
            4'd5:round_constant = 8'h10;
            4'd6:round_constant = 8'h20;
            4'd7:round_constant = 8'h40;
            4'd8:round_constant = 8'h80;
            4'd9:round_constant = 8'h1B;
            4'd10: round_constant = 8'h36;
            default: round_constant = 8'h00; 
        endcase
    end
    endfunction
endmodule
