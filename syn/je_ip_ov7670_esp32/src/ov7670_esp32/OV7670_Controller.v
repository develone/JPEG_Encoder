/******************************************************************************
Copyright 2018 Gnarly Grey LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
******************************************************************************/
//////////////////////////////////////////////////////////////////////////////////
// OV7670_Controller.v
//
// Author:			Thanh Tien Truong
//
// Description:
// ------------
// - Sending data to OV7670 registers through SCCB interface
//   to configure the mode of the OV7670
//
// - The module has 2 instances:
//   OV7670_Registers    - Like a LUT containing all the registers address 
//                              and data to write into a registers
//   I2C_Interface       - SCCB interface to communicate with OV7670
//	
//////////////////////////////////////////////////////////////////////////////////

module OV7670_Controller (
    input clk,                              // 50Mhz clock signal
    input resend,                           // Reset signal
    output config_finished,                 // Flag to indicate that the configuration is finished
    output sioc,                            // SCCB interface - clock signal
    inout siod,                             // SCCB interface - data signal
    output reset,                           // RESET signal for OV7670
    output pwdn                             // PWDN signal for OV7670
);

    // Internal signals
    wire [15:0] command;
    wire finished;
    wire taken;
    reg send = 0;
   
    // Signal for testing
    assign config_finished = finished;
    
    // Signals for RESET and PWDN OV7670
    assign reset = 1;
    assign pwdn = 0;
    
    // Signal to indicate that the configuration is finshied    
    always @ (finished) begin
        send = ~finished;
    end
    
    // Create an instance of a LUT table 
    OV7670_Registers LUT(
        .clk(clk),                          // 50Mhz clock signal
        .advance(taken),                    // Flag to advance to next register
        .command(command),                  // register value and data for OV7670
        .finished(finished),                // Flag to indicate the configuration is finshed
        .resend(resend)                     // Re-configure flag for OV7670
    );
    
    // Create an instance of a SCCB interface
    I2C_Interface I2C(
        .clk(clk),                          // 50Mhz clock signal
        .taken(taken),                      // Flag to advance to next register
        .siod(siod),                        // Clock signal for SCCB interface
        .sioc(sioc),                        // Data signal for SCCB interface 
        .send(send),                        // Continue to configure OV7670
        .rega(command[15:8]),               // Register address
        .value(command[7:0])                // Data to write into register
    );
    
endmodule
