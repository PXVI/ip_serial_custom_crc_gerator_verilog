/* -----------------------------------------------------------------------------------
 * Module Name  : -
 * Date Created : 23:22:31 IST, 27 September, 2020 [ Sunday ]
 *
 * Author       : pxvi
 * Description  : Simple testbench for the 7bit CRC module with the degrees [ 7, 3, 1 ]
 * -----------------------------------------------------------------------------------

   MIT License

   Copyright (c) 2020 k-sva

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the Software), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.

 * ----------------------------------------------------------------------------------- */

`include "crc7_h45_script_serial.v"

module top_crc7_h45_serial;

    reg in, enable, clear;
    reg clk, rst;
    wire out;

    reg [127:0] count;
    reg [7:0] var_temp;
    reg [6:0] crc_out;

    crc7_h45_script_serial mod ( .RSTn( rst ), .CLK( clk ), .clear( clear ), .enable( enable ), .in( in ), .crc_out( out ) );
 
    initial
    begin
        count = 0;

        fork
            begin
                clk = 0;
                forever
                begin
                    #5 clk = ~clk;
                end
            end
            begin
                crc_out = 0;
                var_temp = 0;
                rst = 0;
                enable = 0;
                #98 rst = 1;
                repeat( 4 )
                begin
                    count = 0;
                    var_temp = $urandom;

                    @( negedge clk );
                    enable = 0;
                    clear = 1;
                    @( negedge clk );
                    enable = 0;
                    clear = 0;

                    // Shift the Serial DATA inside
                    // ----------------------------
                    repeat( 8 ) // One Byte
                    begin
                        @( negedge clk );
                        enable = 1;
                        in = var_temp[7-count];
                        @( posedge clk );
                        #1;

                        crc_out = { crc_out[5:0], out };
                        $display( "1. INFO -- Random var_tempiable to be given as input : d%d ( b%b, h%h ) ; CRC7 : d%d ( b%b, h%h )", var_temp, var_temp, var_temp, crc_out, crc_out, crc_out );
                        count = count + 1;
                    end

                    // Shift the CRC out
                    // -----------------
                    repeat( 6 ) // 7 Bit - 1 Number of Additional Shifts to pull the CRC out
                    begin
                        @( negedge clk );
                        enable = 0;
                        in = 0;
                        @( posedge clk );
                        #1;

                        crc_out = { crc_out[5:0], out };
                        $display( "2. INFO -- Random var_tempiable to be given as input : d%d ( b%b, h%h ) ; CRC7 : d%d ( b%b, h%h )", var_temp, var_temp, var_temp, crc_out, crc_out, crc_out );
                    end
                    $display( "---------------------------------------------------------------------------------------------------------------------------------------" );
                end
                $finish;
            end
        join
    end

    initial
    begin
        $dumpfile( "default_dump.vcd" );
        $dumpvars( 0, top_crc7_h45_serial );
    end

endmodule
