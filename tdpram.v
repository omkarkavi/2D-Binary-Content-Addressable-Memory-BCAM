////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2014, University of British Columbia (UBC); All rights reserved. //
//                                                                                //
// Redistribution  and  use  in  source   and  binary  forms,   with  or  without //
// modification,  are permitted  provided that  the following conditions are met: //
//   * Redistributions   of  source   code  must  retain   the   above  copyright //
//     notice,  this   list   of   conditions   and   the  following  disclaimer. //
//   * Redistributions  in  binary  form  must  reproduce  the  above   copyright //
//     notice, this  list  of  conditions  and the  following  disclaimer in  the //
//     documentation and/or  other  materials  provided  with  the  distribution. //
//   * Neither the name of the University of British Columbia (UBC) nor the names //
//     of   its   contributors  may  be  used  to  endorse  or   promote products //
//     derived from  this  software without  specific  prior  written permission. //
//                                                                                //
// THIS  SOFTWARE IS  PROVIDED  BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" //
// AND  ANY EXPRESS  OR IMPLIED WARRANTIES,  INCLUDING,  BUT NOT LIMITED TO,  THE //
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE //
// DISCLAIMED.  IN NO  EVENT SHALL University of British Columbia (UBC) BE LIABLE //
// FOR ANY DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY, OR CONSEQUENTIAL //
// DAMAGES  (INCLUDING,  BUT NOT LIMITED TO,  PROCUREMENT OF  SUBSTITUTE GOODS OR //
// SERVICES;  LOSS OF USE,  DATA,  OR PROFITS;  OR BUSINESS INTERRUPTION) HOWEVER //
// CAUSED AND ON ANY THEORY OF LIABILITY,  WHETHER IN CONTRACT, STRICT LIABILITY, //
// OR TORT  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE //
// OF  THIS SOFTWARE,  EVEN  IF  ADVISED  OF  THE  POSSIBILITY  OF  SUCH  DAMAGE. //
////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////
//         tdpram.v: Generic true dual-ported RAM with data flow-through          //
//                                                                                //
//   Author: Ameer M.S. Abdelhadi (ameer@ece.ubc.ca, ameer.abdelhadi@gmail.com)   //
//    SRAM-based 2D BCAM; The University of British Columbia (UBC), April 2014    //
////////////////////////////////////////////////////////////////////////////////////

`include "utils.vh"

module tdpram
 #( parameter MEMD  = 2*1024, // memory depth
    parameter DATAW = 16    , // data width
    parameter IZERO = 0     , // binary / Initial RAM with zeros (has priority over IFILE)
    parameter IFILE = ""    ) // initialization hex file (don't pass extension), optional
  ( input                    clk   ,  // clock
    input                    wEnbA ,  // write enable for port A
    input                    wEnbB ,  // write enable for port B
    input  [`log2(MEMD)-1:0] addrA ,  // write addresses - packed from nWPORTS write ports
    input  [`log2(MEMD)-1:0] addrB ,  // write addresses - packed from nWPORTS write ports
    input  [DATAW      -1:0] wDataA,  // write data      - packed from nRPORTS read ports
    input  [DATAW      -1:0] wDataB,  // write data      - packed from nRPORTS read ports
    output reg [DATAW  -1:0] rDataA,  // read  data      - packed from nRPORTS read ports
    output reg [DATAW  -1:0] rDataB); // read  data      - packed from nRPORTS read ports

  // initialize RAM, with zeros if IZERO or file if IFLE.
  integer i;
  reg [DATAW-1:0] mem [0:MEMD-1]; // memory array
  initial
    if (IZERO)
      for (i=0; i<MEMD; i=i+1) mem[i] = {DATAW{1'b0}};
    else
      if (IFILE != "") $readmemh({IFILE,".hex"}, mem);

  // PORT A
  always @(posedge clk) begin
    // write/read; nonblocking statement to read old data
    if (wEnbA) begin
      mem[addrA] <= wDataA; // Change into blocking statement (=) to read new data
      rDataA     <= wDataA; // flow-through
    end else
      rDataA <= mem[addrA]; //Change into blocking statement (=) to read new data
  end

  // PORT B
  always @(posedge clk) begin
    // write/read; nonblocking statement to read old data
    if (wEnbB) begin
      mem[addrB] <= wDataB; // Change into blocking statement (=) to read new data
      rDataB     <= wDataB; // flow-through
    end else
      rDataB <= mem[addrB]; //Change into blocking statement (=) to read new data
  end

endmodule
