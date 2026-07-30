`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/29/2026 02:09:52 PM
// Design Name: 
// Module Name: shift_rows
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


module shift_rows(
    input wire [127:0] state,
    output reg [127:0] out
    );
    
    //reg [7:0] temp;
    // Let's not do the matrix solution, at the end of the day it'll look like magic numbers too.
    // AES visualizes the plaintext in a column-major matrix of 16 bytes
    // wire [7:0] state_matrix[3:0][3:0];
    
    // Notes for self:
    // Removed the temp reg because we are never overwriting the original state.
    // The reason it was needed from the C adaptation is because the in-memory state was being updated.
    // Need to make sure:
    //  1. ALL bits of the out reg are set, otherwise inferred latch.
    //  2. Look into indexed-part selection if the compiler complains.
    
    always @(*) begin 
        // First row (B0, B4, B8, B12) remains unchanged
        out[end_bit(0)  : start_bit(0)] = state[end_bit(0) : start_bit(0)];
        out[end_bit(4)  : start_bit(4)] = state[end_bit(4) : start_bit(4)];
        out[end_bit(8)  : start_bit(8)] = state[end_bit(8) : start_bit(8)];
        out[end_bit(12)  : start_bit(12)] = state[end_bit(12) : start_bit(12)];
        
        // Second row (B1, B5, B9, B13) moves one to the left
        //temp = 
        out[end_bit(1)  : start_bit(1)] = state[end_bit(5) : start_bit(5)];
        out[end_bit(5)  : start_bit(5)] = state[end_bit(9) : start_bit(9)];
        out[end_bit(9)  : start_bit(9)] = state[end_bit(13): start_bit(13)];
        out[end_bit(13) : start_bit(13)] = state[end_bit(1) : start_bit(1)];
  
        // Third row (B2, B6, B10, B14) moves two to the left
        //temp = 
        out[end_bit(2): start_bit(2)] = state[end_bit(10) : start_bit(10)];
        out[end_bit(10) : start_bit(10)] = state[end_bit(2) : start_bit(2)];
        //temp = 
        out[end_bit(6) : start_bit(6)] = state[end_bit(14) : start_bit(14)];
        out[end_bit(14) : start_bit(14)] = state[end_bit(6) : start_bit(6)];
        
        // Fourth row (B3, B7, B11, B15) moves three to the left
        //temp = 
        out[end_bit(3) : start_bit(3)] = state[end_bit(15) : start_bit(15)];
        out[end_bit(15) : start_bit(15)] = state[end_bit(11) : start_bit(11)];
        out[end_bit(11) : start_bit(11)] = state[end_bit(7) : start_bit(7)];
        out[end_bit(7): start_bit(7)] = state[end_bit(3) : start_bit(3)];
    end
    
    function integer start_bit(input integer byte); 
        start_bit = byte * 8;
    endfunction
    
    function integer end_bit(input integer byte); 
        end_bit = (byte * 8) + 7;
    endfunction 
    
endmodule
