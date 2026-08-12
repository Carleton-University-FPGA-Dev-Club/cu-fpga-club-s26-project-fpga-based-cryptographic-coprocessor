`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Carleton University Summer 2026 FPGA Club
// Author:
//
// Create Date: 07/27/2026 08:38:33 PM
// Design Name: AES-128 Algorithm
// Module Name: aes
// Project Name: FPGA-Based Cryptographic Coprocessor
// Target Devices: Zybo Z7-20
// Tool Versions: Xilinx Vivado 2023.1
// Description: Implements the AES-128 algorithm as a state machine.
//
// Dependencies: sub_bytes.v, shift_rows.v, mix_columns.v, key_expansion.v
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments: N/A
//
//////////////////////////////////////////////////////////////////////////////////


module aes(
    input clk,
    input rst,
    input start,
    input [127:0] plaintext,
    input [127:0] key,
    output reg [127:0] ciphertext,
    output reg ready
    );

    // States & constants
    parameter IDLE = 3'b000;
    parameter INITIAL_ROUND = 3'b001;
    parameter SUB_BYTES = 3'b010;
    parameter SHIFT_ROWS = 3'b011;
    parameter MIX_COLUMN = 3'b100;
    parameter EXPAND_KEY = 3'b101;
    parameter ADD_ROUND_KEY = 3'b110;
    parameter READY = 3'b111;
    parameter NUMBER_OF_ROUNDS = 10; 
     
    // Internal variables
    reg [3:0] round_number, next_round_number;
    reg [2:0] state, next_state;
    reg [127:0] state_register, next_state_register;
    reg [127:0] key_register, next_key_register;

    // Structural instantiations
    wire [127:0] subbytes_out;
    sub_bytes sb(
        .state(state_register),
        .out(subbytes_out)
    );

    wire [127:0] shiftrows_out;
    shift_rows sr(
        .state(state_register),
        .out(shiftrows_out)
    );

    wire [127:0] mixcolumns_out;
    mix_columns mc(
        .state(state_register),
        .out(mixcolumns_out)
    );

    wire [127:0] keyexpansion_out;
    key_expansion ke(
        .key(key_register),
        .round_number(round_number),
        .out(keyexpansion_out)
    );

    // === FSM === //
    // 1. Sequential logic for state
    always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        state_register <= 128'b0;
        key_register <= 128'b0;
        round_number <= 4'b1;
        end
    else begin
        state <= next_state;
        state_register <= next_state_register;
        key_register <= next_key_register;
        round_number <= next_round_number;
        end
    end

    // 2. Combinational logic for algorithm
    always @(*) begin
        // Assign defaults to be sure we don't infer latches
        next_state = state;
        next_state_register = state_register;
        next_key_register = key_register;
        next_round_number = round_number;
   
        // And thus begin the cases  
        case (state)
            IDLE: begin
                if (start) begin
                    next_state_register = plaintext;
                    next_key_register = key;
                    next_state = INITIAL_ROUND;
                    next_round_number = 1;
                    end
                else
                    next_state = IDLE;
                end
            INITIAL_ROUND: begin
                next_state_register = state_register ^ key_register;
                next_state = EXPAND_KEY; 
                end
            EXPAND_KEY: begin
                next_key_register = keyexpansion_out;
                next_state = SUB_BYTES;
                end
            SUB_BYTES: begin
                next_state_register = subbytes_out;
                next_state = SHIFT_ROWS;
                end
            SHIFT_ROWS: begin
                next_state_register = shiftrows_out;
                if (round_number < NUMBER_OF_ROUNDS)
                    next_state = MIX_COLUMN;
                else
                    next_state = ADD_ROUND_KEY;
                end
            MIX_COLUMN: begin
                next_state_register = mixcolumns_out;
                next_state = ADD_ROUND_KEY;
                end
            ADD_ROUND_KEY: begin
                next_state_register = state_register ^ key_register;
                if (round_number == NUMBER_OF_ROUNDS)
                    next_state = READY;
                else begin 
                    next_state = EXPAND_KEY;
                    next_round_number = round_number + 1;
                    end
                end
            READY: begin
                next_state = READY;
                end
            default: begin
                next_state = 3'bx;
                next_state_register = 128'bx;
                next_key_register = 128'bx;
                next_round_number = 4'bx;
            end
        endcase
    end

    // 3. Output generation
    always @(*) begin
        ciphertext = state_register;
        ready = 0;
        
        if (state == READY) begin
            ciphertext = state_register;
            ready = 1;
        end
    end


endmodule
