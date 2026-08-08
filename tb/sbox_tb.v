`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/07/2026 09:09:06 PM
// Design Name: 
// Module Name: sbox_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: https://en.wikipedia.org/wiki/Rijndael_S-box
// Substitution box for the AES algorithm.
//////////////////////////////////////////////////////////////////////////////////


module sbox_tb;
    reg [7:0] test_input;
    wire [7:0] test_output;
    reg [7:0] expected_output;

    sbox uut (
        .sbox_in(test_input),
        .sbox_out(test_output)
    );

    initial begin
        test_input = 8'h9a;
        expected_output = 8'hb8;
        #10;
        
        if (test_output == expected_output)
            $display("Test case #1 passed");
        else begin
            $display("Test case #1 failed");
            $display("Expected: %h", expected_output);
            $display("Actual: %h", test_output);
        end
        
        test_input = 8'hc3;
        expected_output = 8'h2e;
        #10;
        
        if (test_output == expected_output)
            $display("Test case #2 passed");
        else begin
            $display("Test case #2 failed");
            $display("Expected: %h", expected_output);
            $display("Actual: %h", test_output);
        end
        
        test_input = 8'h86;
        expected_output = 8'h44;
        #10;
        
        if (test_output == expected_output)
            $display("Test case #3 passed");
        else begin
            $display("Test case #3 failed");
            $display("Expected: %h", expected_output);
            $display("Actual: %h", test_output);
        end
        

        $finish;
    end
endmodule
