`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/29/2026 05:07:45 PM
// Design Name: 
// Module Name: mix_columns
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


module mix_columns(
    input wire [127:0] state,
    output reg [127:0] out
    );
    
    // Note to self:
    // Trying out the index-slicing with addition, start_bit & end_bit like the one in shift_rows would look ugly.
    // Because it'd be function within a function. 
    // BUT, this is pretty repetitive and prone to typos with the indexes.
    // So maybe another generate like the sub_bytes.
    
    always @(*) begin
        // First column
        out[15*8 +: 8] = (galois_multiply(state[15*8 +: 8], 2) 
        ^ galois_multiply(state[14*8 +: 8], 3) 
        ^ galois_multiply(state[13*8 +: 8], 1) 
        ^ galois_multiply(state[12*8 +: 8], 1));
        
        out[14*8 +: 8] = (galois_multiply(state[15*8 +: 8], 1) 
        ^ galois_multiply(state[14*8 +: 8], 2) 
        ^ galois_multiply(state[13*8 +: 8], 3) 
        ^ galois_multiply(state[12*8 +: 8], 1));
        
        out[13*8 +: 8] = (galois_multiply(state[15*8 +: 8], 1) 
        ^ galois_multiply(state[14*8 +: 8], 1) 
        ^ galois_multiply(state[13*8 +: 8], 2) 
        ^ galois_multiply(state[12*8 +: 8], 3));
        
        out[12*8 +: 8] = (galois_multiply(state[15*8 +: 8], 3) 
        ^ galois_multiply(state[14*8 +: 8], 1) 
        ^ galois_multiply(state[13*8 +: 8], 1) 
        ^ galois_multiply(state[12*8 +: 8], 2));
    
        // Second column
        out[11*8 +: 8] = (galois_multiply(state[11*8 +: 8], 2) 
        ^ galois_multiply(state[10*8 +: 8], 3) 
        ^ galois_multiply(state[9*8 +: 8], 1) 
        ^ galois_multiply(state[8*8 +: 8], 1));
        
        out[10*8 +: 8] = (galois_multiply(state[11*8 +: 8], 1) 
        ^ galois_multiply(state[10*8 +: 8], 2) 
        ^ galois_multiply(state[9*8 +: 8], 3) 
        ^ galois_multiply(state[8*8 +: 8], 1));
        
        out[9*8 +: 8] = (galois_multiply(state[11*8 +: 8], 1) 
        ^ galois_multiply(state[10*8 +: 8], 1) 
        ^ galois_multiply(state[9*8 +: 8], 2) 
        ^ galois_multiply(state[8*8 +: 8], 3));
        
        out[8*8 +: 8] = (galois_multiply(state[11*8 +: 8], 3) 
        ^ galois_multiply(state[10*8 +: 8], 1) 
        ^ galois_multiply(state[9*8 +: 8], 1) 
        ^ galois_multiply(state[8*8 +: 8], 2));
        
        // Third column
        out[7*8 +: 8] = (galois_multiply(state[7*8 +: 8], 2) 
        ^ galois_multiply(state[6*8 +: 8], 3) 
        ^ galois_multiply(state[5*8 +: 8], 1) 
        ^ galois_multiply(state[4*8 +: 8], 1));
        
        out[6*8 +: 8] = (galois_multiply(state[7*8 +: 8], 1) 
        ^ galois_multiply(state[6*8 +: 8], 2) 
        ^ galois_multiply(state[5*8 +: 8], 3) 
        ^ galois_multiply(state[4*8 +: 8], 1));
        
        out[5*8 +: 8] = (galois_multiply(state[7*8 +: 8], 1) 
        ^ galois_multiply(state[6*8 +: 8], 1) 
        ^ galois_multiply(state[5*8 +: 8], 2) 
        ^ galois_multiply(state[4*8 +: 8], 3));
        
        out[4*8 +: 8] = (galois_multiply(state[7*8 +: 8], 3) 
        ^ galois_multiply(state[6*8 +: 8], 1) 
        ^ galois_multiply(state[5*8 +: 8], 1) 
        ^ galois_multiply(state[4*8 +: 8], 2));
        
        // Fourth column
        out[3*8 +: 8] = (galois_multiply(state[3*8 +: 8], 2) 
        ^ galois_multiply(state[2*8 +: 8], 3) 
        ^ galois_multiply(state[1*8 +: 8], 1) 
        ^ galois_multiply(state[0*8 +: 8], 1));
        
        out[2*8 +: 8] = (galois_multiply(state[3*8 +: 8], 1) 
        ^ galois_multiply(state[2*8 +: 8], 2) 
        ^ galois_multiply(state[1*8 +: 8], 3) 
        ^ galois_multiply(state[0*8 +: 8], 1));
        
        out[1*8 +: 8] = (galois_multiply(state[3*8 +: 8], 1) 
        ^ galois_multiply(state[2*8 +: 8], 1) 
        ^ galois_multiply(state[1*8 +: 8], 2) 
        ^ galois_multiply(state[0*8 +: 8], 3));
        
        out[0*8 +: 8] = (galois_multiply(state[3*8 +: 8], 3) 
        ^ galois_multiply(state[2*8 +: 8], 1) 
        ^ galois_multiply(state[1*8 +: 8], 1) 
        ^ galois_multiply(state[0*8 +: 8], 2));
    end
   
   /* Multiplies a state byte by a constant in the Galois GF(2^8) field.
   Only works with the constants 1, 2, and 3.
   Since those are the only numbers in the constant matrix for the MixColumns step.
   */ 
    function [7:0] galois_multiply(
        input [7:0] byte,
        input integer constant
        );
    begin
        if (constant == 1) 
            galois_multiply = byte;
        else if (constant == 2) begin
            if (byte[7] == 1)
                galois_multiply = (byte << 1) ^ 8'h1B;
            else
                galois_multiply = byte << 1;
            end
        else if (constant == 3)
            galois_multiply = galois_multiply(byte, 2) ^ byte;
        else 
            galois_multiply = byte;
        end
    endfunction
    
    
endmodule
