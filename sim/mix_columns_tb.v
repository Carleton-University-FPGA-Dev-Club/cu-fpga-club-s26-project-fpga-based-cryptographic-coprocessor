`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/30/2026 07:16:47 PM
// Design Name: 
// Module Name: mix_columns_tb
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


module mix_columns_tb;
    reg [127:0] test_input;
    wire [127:0] test_output;
    reg [127:0] expected_output;

    mix_columns uut (
        .state(test_input),
        .out(test_output)
    );

    initial begin
        test_input = 128'hd4bf5d30e0b452aeb84111f11e2798e5;
        expected_output = 128'h046681e5e0cb199a48f8d37a2806264c;
        #10;
        
        if (test_output == expected_output)
            $display("Test case #1 passed");
        else begin
            $display("Test case #1 failed");
            $display("Expected: %h", expected_output);
            $display("Actual: %h", test_output);
        end
        
        test_input = 128'h49db873b453953897f02d2f177de961a;
        expected_output = 128'h584dcaf11b4b5aacdbe7caa81b6bb0e5;
        #10;
        
        if (test_output == expected_output)
            $display("Test case #2 passed");
        else begin
            $display("Test case #2 failed");
            $display("Expected: %h", expected_output);
            $display("Actual: %h", test_output);
        end
        
        test_input = 128'hacc1d6b8efb55a7b1323cfdf457311b5;
        expected_output = 128'h75ec0993200b633353c0cf7cbb25d0dc;
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