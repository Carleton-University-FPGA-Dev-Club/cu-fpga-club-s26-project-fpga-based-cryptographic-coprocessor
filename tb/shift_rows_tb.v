`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/30/2026 08:48:42 PM
// Design Name: 
// Module Name: shift_rows_tb
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


module shift_rows_tb;
    reg [127:0] test_input;
    wire [127:0] test_output;
    reg [127:0] expected_output;

    shift_rows uut (
        .state(test_input),
        .out(test_output)
    );

    initial begin
        test_input = 128'hd42711aee0bf98f1b8b45de51e415230;
        expected_output = 128'hd4bf5d30e0b452aeb84111f11e2798e5;
        #10;
        
        if (test_output == expected_output)
            $display("Test case #1 passed");
        else begin
            $display("Test case #1 failed");
            $display("Expected: %h", expected_output);
            $display("Actual: %h", test_output);
        end
        
        test_input = 128'h49ded28945db96f17f39871a7702533b;
        expected_output = 128'h49db873b453953897f02d2f177de961a;
        #10;
        
        if (test_output == expected_output)
            $display("Test case #2 passed");
        else begin
            $display("Test case #2 failed");
            $display("Expected: %h", expected_output);
            $display("Actual: %h", test_output);
        end
        
        test_input = 128'hac73cf7befc111df13b5d6b545235ab8;
        expected_output = 128'hacc1d6b8efb55a7b1323cfdf457311b5;
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