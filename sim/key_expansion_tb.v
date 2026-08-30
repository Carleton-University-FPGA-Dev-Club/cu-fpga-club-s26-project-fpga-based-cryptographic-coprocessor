`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/30/2026 09:10:41 PM
// Design Name: 
// Module Name: key_expansion_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197.pdf
// NIST Step-by-Step AES128 Test Vectors @ Page 38
//////////////////////////////////////////////////////////////////////////////////


module key_expansion_tb;
    reg [127:0] test_input;
    wire [127:0] test_output;
    reg [127:0] expected_output;
    reg [3:0] round_number;

    key_expansion uut (
        .key(test_input),
        .round_number(round_number),
        .out(test_output)
    );

    initial begin
        test_input = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        expected_output = 128'ha0fafe1788542cb123a339392a6c7605;
        round_number = 1; 
        #10;
        
        if (test_output == expected_output)
            $display("Test case #1 passed");
        else begin
            $display("Test case #1 failed");
            $display("Expected: %h", expected_output);
            $display("Actual: %h", test_output);
        end
        
        test_input = 128'ha0fafe1788542cb123a339392a6c7605;
        expected_output = 128'hf2c295f27a96b9435935807a7359f67f;
        round_number = 2;
        #10;
        
        if (test_output == expected_output)
            $display("Test case #2 passed");
        else begin
            $display("Test case #2 failed");
            $display("Expected: %h", expected_output);
            $display("Actual: %h", test_output);
        end
        
        test_input = 128'hf2c295f27a96b9435935807a7359f67f;
        expected_output = 128'h3d80477d4716fe3e1e237e446d7a883b;
        round_number = 3;
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