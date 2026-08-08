`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/30/2026 05:45:19 PM
// Design Name: 
// Module Name: aes_tb
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
// NIST Step-by-Step AES128 Test Vectors @ Page 38 & Page 35/36
//////////////////////////////////////////////////////////////////////////////////


module aes_tb;
    reg [127:0] plaintext;
    reg [127:0] key;
    reg start;
    reg clk; 
    reg rst; 
    
    wire [127:0] ciphertext;
    wire ready;
    
    // Internal 
    reg [127:0] expected_ciphertext;
    
    aes uut(
        .clk(clk),
        .rst(rst),
        .start(start),
        .plaintext(plaintext),
        .key(key),
        .ciphertext(ciphertext),
        .ready(ready)
    );
    
    initial begin 
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Let's debug the round counter
    //initial begin
    //    $monitor("Time = %0t | Round number register changed to: %h", $time, uut.round_number);
    //    $monitor("Time = %0t | Key register changed to: %h", $time, uut.key_register);
    //    //$monitor("Time = %0t | State register changed to: %h", $time, uut.state_register);
    //end

    initial begin 
        rst = 0;
        start = 0;
        #10;
        rst = 1;
        #10; 
        rst = 0;
        #10;
      
        plaintext = 128'h3243f6a8885a308d313198a2e0370734;
	    key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
	    expected_ciphertext = 128'h3925841d02dc09fbdc118597196a0b32;
        
        #10;
        start = 1;
        #10;
        start = 0;
        wait(ready);
        
        if (ciphertext == expected_ciphertext)
            $display("Test case #1 passed");
        else begin 
            $display("Test case #1 failed");
            $display("Expected ciphertext: %h", expected_ciphertext);
            $display("Actual ciphertext: %h", ciphertext);
        end
        
        plaintext = 128'h00112233445566778899aabbccddeeff;
	    key = 128'h000102030405060708090a0b0c0d0e0f;
	    expected_ciphertext = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;
        
        #10;
        start = 1;
        #10;
        start = 0;
        #10;
        wait(ready);
        
        if (ciphertext == expected_ciphertext)
            $display("Test case #2 passed");
        else begin 
            $display("Test case #2 failed");
            $display("Expected ciphertext: %h", expected_ciphertext);
            $display("Actual ciphertext: %h", ciphertext);
        end
        $finish;
    end   

endmodule