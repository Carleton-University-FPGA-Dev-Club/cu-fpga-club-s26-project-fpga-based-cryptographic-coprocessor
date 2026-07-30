`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 07/29/2026 12:07:45 PM
// Design Name:
// Module Name: sub_bytes
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


module sub_bytes(
    input [127:0] state,
    output [127:0] out
    );

    // The number in the instance name refers to the byte number
    // Note to self: [x*8] means the starting bit.
    // Because AES visualizes the state in a column-major order matrix.
    // Then, +8 means add 8 bits but the x*8 is included.

    sbox sb0 (.sbox_in(state[0*8  +: 8]), .sbox_out(out[0*8  +: 8]));
    sbox sb1 (.sbox_in(state[1*8  +: 8]), .sbox_out(out[1*8  +: 8]));
    sbox sb2 (.sbox_in(state[2*8  +: 8]), .sbox_out(out[2*8  +: 8]));
    sbox sb3 (.sbox_in(state[3*8  +: 8]), .sbox_out(out[3*8  +: 8]));
    sbox sb4 (.sbox_in(state[4*8  +: 8]), .sbox_out(out[4*8  +: 8]));
    sbox sb5 (.sbox_in(state[5*8  +: 8]), .sbox_out(out[5*8  +: 8]));
    sbox sb6 (.sbox_in(state[6*8  +: 8]), .sbox_out(out[6*8  +: 8]));
    sbox sb7 (.sbox_in(state[7*8  +: 8]), .sbox_out(out[7*8  +: 8]));
    sbox sb8 (.sbox_in(state[8*8  +: 8]), .sbox_out(out[8*8  +: 8]));
    sbox sb9 (.sbox_in(state[9*8  +: 8]), .sbox_out(out[9*8  +: 8]));
    sbox sb10 (.sbox_in(state[10*8 +: 8]), .sbox_out(out[10*8 +: 8]));
    sbox sb11 (.sbox_in(state[11*8 +: 8]), .sbox_out(out[11*8 +: 8]));
    sbox sb12 (.sbox_in(state[12*8 +: 8]), .sbox_out(out[12*8 +: 8]));
    sbox sb13 (.sbox_in(state[13*8 +: 8]), .sbox_out(out[13*8 +: 8]));
    sbox sb14 (.sbox_in(state[14*8 +: 8]), .sbox_out(out[14*8 +: 8]));
    sbox sb15 (.sbox_in(state[15*8 +: 8]), .sbox_out(out[15*8 +: 8]));
endmodule
