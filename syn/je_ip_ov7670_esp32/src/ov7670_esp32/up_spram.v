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

`timescale 1ns/1ns

module up_spram (
  input           reset_n,
  
  input           wr_clk,
  input  [16:0]   wr_addr,
  input  [7:0]    wr_data,  
  input           wr_en,
  
  input           rd_clk,
  input  [16:0]   rd_addr,
  output [7:0]    rd_data
  );

  wire   [15:0]   ram_rdata;  
  wire   [15:0]   ram_rdata0, ram_rdata1, ram_rdata2, ram_rdata3;  
  wire   [16:0]   w_addr;
  assign          w_addr = wr_en ? wr_addr : rd_addr;
  wire   [3:0]    w_mask;
  //assign          w_mask = w_addr[16] ? 4'b1100 : 4'b0011;
  assign          w_mask = w_addr[0] ? 4'b1100 : 4'b0011;
  wire   [3:0]    wr_ram;
  
  reg    [7:0]    rd_data_reg;
  
  //assign          wr_ram[0] = ~w_addr[15] & ~w_addr[14] & wr_en;
  //assign          wr_ram[1] = ~w_addr[15] &  w_addr[14] & wr_en;
  //assign          wr_ram[2] =  w_addr[15] & ~w_addr[14] & wr_en;
  //assign          wr_ram[3] =  w_addr[15] &  w_addr[14] & wr_en;

  assign          wr_ram[0] = ~w_addr[2] & ~w_addr[1] & wr_en;
  assign          wr_ram[1] = ~w_addr[2] &  w_addr[1] & wr_en;
  assign          wr_ram[2] =  w_addr[2] & ~w_addr[1] & wr_en;
  assign          wr_ram[3] =  w_addr[2] &  w_addr[1] & wr_en;  
  
  //assign          ram_rdata = (w_addr[16:14]==3'd0) ? ram_rdata0[7:0] : 
  //                            (w_addr[16:14]==3'd1) ? ram_rdata1[7:0] : 
  //                            (w_addr[16:14]==3'd2) ? ram_rdata2[7:0] : 
  //                            (w_addr[16:14]==3'd3) ? ram_rdata3[7:0] :
  //                            (w_addr[16:14]==3'd4) ? ram_rdata0[15:8] : 
  //                            (w_addr[16:14]==3'd5) ? ram_rdata1[15:8] : 
  //                            (w_addr[16:14]==3'd6) ? ram_rdata2[15:8] : 
  //                            (w_addr[16:14]==3'd7) ? ram_rdata3[15:8] : 0;
                              
                              
                                                  
  assign          rd_data = rd_data_reg;//ram_rdata[7:0];//
  
  always @ (posedge rd_clk or negedge reset_n)
    begin
      if (!reset_n)
        rd_data_reg <= #1 8'h00;
      else
      if (wr_en)
        rd_data_reg <= #1 8'h00;
      else        
        case (w_addr[2:0])
          3'h0    : rd_data_reg <= #1 ram_rdata0[7:0];
          3'h1    : rd_data_reg <= #1 ram_rdata0[15:8];
          3'h2    : rd_data_reg <= #1 ram_rdata1[7:0];
          3'h3    : rd_data_reg <= #1 ram_rdata1[15:8];
          3'h4    : rd_data_reg <= #1 ram_rdata2[7:0];
          3'h5    : rd_data_reg <= #1 ram_rdata2[15:8];
          3'h6    : rd_data_reg <= #1 ram_rdata3[7:0];
          3'h7    : rd_data_reg <= #1 ram_rdata3[15:8];      
          default : rd_data_reg <= #1 8'h00;
        endcase
    end
    
    
  //RAM instantiations
//SB_SPRAM256KA u_spram0 (
  SP256K u_spram0 (
    //.AD       ( w_addr[13:0 ]       ),
    .AD       ( w_addr[16:3 ]       ),
    .DI       ( {wr_data,wr_data}   ),
    .MASKWE   ( w_mask              ),
    .WE       ( wr_ram[0]           ),
    .CS       ( 1'b1                ),
    .CK       ( rd_clk              ),
    .STDBY    ( 1'b0                ),
    .SLEEP    ( 1'b0                ),
    .PWROFF_N ( 1'b1                ),
    .DO       ( ram_rdata0          )
    );
    
//SB_SPRAM256KA u_spram1 (
  SP256K u_spram1 (
    //.AD       ( w_addr[13:0]        ),
    .AD       ( w_addr[16:3 ]       ),
    .DI       ( {wr_data,wr_data}   ),
    .MASKWE   ( w_mask              ),
    .WE       ( wr_ram[1]           ),
    .CS       ( 1'b1                ),
    .CK       ( rd_clk              ),
    .STDBY    ( 1'b0                ),
    .SLEEP    ( 1'b0                ),
    .PWROFF_N ( 1'b1                ),
    .DO       ( ram_rdata1          )
    );

//SB_SPRAM256KA u_spram2 (
  SP256K u_spram2 (
    //.AD       ( w_addr[13:0]        ),
    .AD       ( w_addr[16:3 ]       ),
    .DI       ( {wr_data,wr_data}   ),
    .MASKWE   ( w_mask              ),
    .WE       ( wr_ram[2]           ),
    .CS       ( 1'b1                ),
    .CK       ( rd_clk              ),
    .STDBY    ( 1'b0                ),
    .SLEEP    ( 1'b0                ),
    .PWROFF_N ( 1'b1                ),
    .DO       ( ram_rdata2          )
    );

//SB_SPRAM256KA u_spram3 (
  SP256K u_spram3 (
    //.AD       ( w_addr[13:0]        ),
    .AD       ( w_addr[16:3 ]       ),
    .DI       ( {wr_data,wr_data}   ),
    .MASKWE   ( w_mask              ),
    .WE       ( wr_ram[3]           ),
    .CS       ( 1'b1                ),
    .CK       ( rd_clk              ),
    .STDBY    ( 1'b0                ),
    .SLEEP    ( 1'b0                ),
    .PWROFF_N ( 1'b1                ),
    .DO       ( ram_rdata3          )
    );  

endmodule  