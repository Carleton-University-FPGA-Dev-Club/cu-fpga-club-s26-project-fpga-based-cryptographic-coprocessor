`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/30/2026 06:52:40 PM
// Design Name: 
// Module Name: sub_bytes_tb
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


module sub_bytes_tb;
    reg [127:0] test_input;
    wire [127:0] test_output;
    reg [127:0] expected_output;

    sub_bytes uut (
        .state(test_input),
        .out(test_output)
    );

    initial begin
        test_input = 128'h0848f8e92a8dc69a2be2f4a0bee33d19;
        expected_output = 128'h3052411ee55db4b8f198bfe0ae1127d4;
        #10;
        
        if (test_output == expected_output)
            $display("Test case #1 passed");
        else begin
            $display("Test case #1 failed");
            $display("Expected: %h", expected_output);
            $display("Actual: %h", test_output);
        end
        
        test_input = 128'h49506a0243ea5b6b2b359f68f27f9ca4;
        expected_output = 128'h3b5302771a87397ff196db4589d2de49;
        #10;
        
        if (test_output == expected_output)
            $display("Test case #2 passed");
        else begin
            $display("Test case #2 failed");
            $display("Expected: %h", expected_output);
            $display("Actual: %h", test_output);
        end
        
        test_input = 128'h9a463268d24ad282efe3dd61035f8faa;
        expected_output = 128'hb85a2345b5d6b513df11c1ef7bcf73ac;
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
