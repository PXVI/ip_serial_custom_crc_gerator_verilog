/* -----------------------------------------------------------------------------------
 * Module Name  : crc7_h45_serial
 * Date Created : 22:47:37 IST, 27 September, 2020 [ Sunday ]
 *
 * Author       : pxvi
 * Description  : CRC module for a 7bit wiht the degrees [ 7, 3, 1 ]
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

module crc7_h45_serial #(    parameter RST_SEED_VAL = 0 ) ( input RSTn, input CLK, input clear, input enable, input in, output out );

    reg [7:1] crc_data_p, crc_data_n;
    reg temp_crc_xor;

    always@( in, enable, crc_data_p, RSTn, CLK, clear )
    begin
        if( enable )
        begin
            temp_crc_xor = in ^ crc_data_p[7];

            crc_data_n[7] = crc_data_p[7-1];
            crc_data_n[6] = crc_data_p[6-1];
            crc_data_n[5] = crc_data_p[5-1];
            crc_data_n[4] = crc_data_p[4-1] ^ temp_crc_xor;
            crc_data_n[3] = crc_data_p[3-1];
            crc_data_n[2] = crc_data_p[2-1];

            crc_data_n[1] = temp_crc_xor;
        end
        else if( !enable )
        begin
            crc_data_n = { crc_data_p[6:1], enable };
        end
    end

    always@( posedge CLK or negedge RSTn )
    begin
        crc_data_p <= crc_data_p;

        if( !RSTn )
        begin
            crc_data_p <= RST_SEED_VAL;
        end
        else if( RSTn )
        begin
            if( clear )
            begin
                crc_data_p <= RST_SEED_VAL;
            end
            else if( !clear )
            begin
                crc_data_p <= crc_data_n;
            end
        end
    end

    assign out = crc_data_p[7];

endmodule
