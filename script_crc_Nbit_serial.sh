#  -----------------------------------------------------------------------------------
#  Module Name  : script_crc_Nbit_serial
#  Date Created : 01:01:23 IST, 28 September, 2020 [ Monday ]
# 
#  Author       : pxvi
#  Description  : This is a generic script to generate a simple N bit CRC verilog
#                 with a custom polynomial.
#  -----------------------------------------------------------------------------------
# 
#  MIT License
# 
#  Copyright (c) 2020 k-sva
# 
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the Software), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
# 
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
# 
#  THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.
# 
#  ----------------------------------------------------------------------------------- */

echo "-----------------------------------------------------------------------"
echo "N-bit CRC Module Generattion Script v1.0                   "
echo "-----------------------------------------------------------------------"
echo -n "Enter the width of the CRC Polynomial ( eg. 16,32,64 so on ) : "

read crc_width;
if [ $crc_width -le 1 ]
then
    echo ""
    echo "[E] The width of the CRC cannot be less than 2. Re-run the script & try again."
else
    echo "Please enter the polynomial degree values one after the other. The inputs will be considered as complete as soon as the last degree which is always 1 in CRC plynomial is entered."
    echo "To give a simple example of what a polynomial degree is, consider a 16 bit CRC polynomial x^16 + x^12 + x^5 + 1. Here, the polynomial degrees are listed as 16, 12, 5 and 0 ( 16,12,5,0 )"
    echo "Note : This script is not absolutely error proof. So, as an advice, DO NOT ENTER THE SAME POLYNOMIAL DEGREE VALUES AGAIN! AND PLEASE ENTER THEM IN DECENDING ORDER!"
    echo ""

    echo "Now, one after the other, please enter the degrees of the polynomial in decending order. Note that as soon as the last degree, ie 0 is entered, the script will move to the next stage of module generation"
    echo -n "Enter the positive integer polynomial degree value ( value must be less than or euqal to the width of CRC and must be non zero ) : "
    read degree_val
    i=0;

    if [ $degree_val -le 0 ]
    then
        if [ $degree_val -lt 0 ]
        then
            echo ""
            echo "[E] First polynomial degree entered is less than 0 which is invalid. Re-run the script & try again."
        elif [ $degree_val -gt $crc_width ]
        then
            echo ""
            echo "[E] Polynomial degree cannot be greater than the CRC Width. Re-run the script & try again."
        else
            echo ""
            echo "[E] Invalid polynomial degree provided. Re-run the script & try again."
        fi
    else
        crc_width_minus_one=`expr $crc_width - 1`

        while [ $degree_val -gt 0 -a $degree_val -le $crc_width ]
        do
            ARRAY[$i]=$degree_val;
            i=`expr $i + 1`;

            echo -n "Enter the positive integer polynomial degree value ( value must be less than or euqal to the width of CRC )                      : "
            read degree_val
        done

        if [ $degree_val -eq 0 ]
        then
            ARRAY[$i]=$degree_val;

            # Generate the Verilog Module
            #for i in "${ARRAY[@]}"
            #do
            #    echo "Degree : $i"
            #done

            degree_list="[ "

            binary_list=""
            u=${crc_width}
            bmatch=0
            while [ $u -ge 0 ]
            do
                for j in "${ARRAY[@]}"
                do
                    if [ $u -eq $j ]
                    then
                        binary_list="${binary_list}1"
                        bmatch=1
                        break
                    fi
                done
                if [ $bmatch -ne 1 ]
                then
                    binary_list="${binary_list}0"
                fi
                bmatch=0
                u=`expr $u - 1`
            done

            for i in "${ARRAY[@]}"
            do
                if [ $i -eq 0 ]
                then
                    degree_list="${degree_list} ]"
                else
                    degree_list="${degree_list}${i}, "
                fi
            done

            echo ""
            echo -n "Enter the CRC module suffix ( eg, h44, b1100_0011, 011_1 etc ) : "
            read crc_suf

            xx="$"
            yy="(("
            zz="))"
            aa="'"
            bb='"'
            cc="#"
    
            binary_list_num=`expr ${binary_list}`
            poly_hex_val=`printf '%x\n' "$((2#${binary_list_num}))"`

            if [ "${crc_suf}" != "" ]
            then
                file_name="crc${crc_width}_h${poly_hex_val}_${crc_suf}_serial.v"
                mod_name="crc${crc_width}_h${poly_hex_val}_${crc_suf}_serial"
            else
                echo ""
                echo "Adding the suffix to the file has been skipped."

                file_name="crc${crc_width}_h${poly_hex_val}_serial.v"
                mod_name="crc${crc_width}_h${poly_hex_val}_serial"
            fi

            if [ -f $file_name ]
            then
                echo ""
                echo "[E] File already exists. Remove or rename the file and try re running the script again."
            else
                timestamp=`date "+%H:%M:%S"`;
                TOUCHFULLDATE=`date "+%d %B, %Y [ %A ]"`;
                timezone=`date "+%Z"`
                year=`date "+%Y"`

                touch $file_name;

                echo "/* -----------------------------------------------------------------------------------" >> $file_name;
                echo " * Module Name  : ${mod_name}" >> $file_name;
                echo " * Date Created : ${timestamp} ${timezone}, ${TOUCHFULLDATE}" >> $file_name;
                echo " *" >> $file_name;
                echo " * Author       : pxvi" >> $file_name;
                echo " * Description  : ${crc_width} Bit Serial CRC Module ( Polynomial Degree List : ${degree_list} )" >> $file_name;
                echo " * -----------------------------------------------------------------------------------" >> $file_name;
                echo "" >> $file_name;
                echo "   MIT License" >> $file_name;
                echo "" >> $file_name;
                echo "   Copyright (c) ${year} k-sva" >> $file_name;
                echo "" >> $file_name;
                echo "   Permission is hereby granted, free of charge, to any person obtaining a copy" >> $file_name;
                echo "   of this software and associated documentation files (the "Software"), to deal" >> $file_name;
                echo "   in the Software without restriction, including without limitation the rights" >> $file_name;
                echo "   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell" >> $file_name;
                echo "   copies of the Software, and to permit persons to whom the Software is" >> $file_name;
                echo "   furnished to do so, subject to the following conditions:" >> $file_name;
                echo "" >> $file_name;
                echo "   The above copyright notice and this permission notice shall be included in all" >> $file_name;
                echo "   copies or substantial portions of the Software." >> $file_name;
                echo "" >> $file_name;
                echo "   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR" >> $file_name;
                echo "   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY," >> $file_name;
                echo "   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE" >> $file_name;
                echo "   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER" >> $file_name;
                echo "   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM," >> $file_name;
                echo "   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE" >> $file_name;
                echo "   SOFTWARE." >> $file_name;
                echo "" >> $file_name;
                echo " * ----------------------------------------------------------------------------------- */" >> $file_name;
                echo "" >> $file_name;

                
                echo "module ${mod_name} #(    parameter RST_SEED_VAL = 0 ) ( input RSTn, input CLK, input clear, input enable, input in, output crc_out );" >> $file_name
                echo "" >> $file_name
                echo "    reg [${crc_width}:1] crc_data_p, crc_data_n;" >> $file_name
                echo "    reg temp_crc_xor;" >> $file_name
                echo "" >> $file_name
                echo "    always@( in, enable, clear, CLK, crc_data_p, RSTn )" >> $file_name
                echo "    begin" >> $file_name
                
                match=0
                i=${crc_width}

                while [ $i -gt 1 ]
                do
                    if [ $i -eq ${crc_width} ]
                    then
                        echo "        if( enable )" >> $file_name
                        echo "        begin" >> $file_name
                        echo "            temp_crc_xor = in ^ crc_data_p[${i}];" >> $file_name
                        echo "" >> $file_name
                        echo "            crc_data_n[${i}] = crc_data_p[${i}-1];" >> $file_name
                    #elif [ $i -eq 1 ]
                    #then
                    #    echo "" >> $file_name
                    #    echo "            crc_data_n[${i}] = temp_crc_xor;" >> $file_name
                    #    break
                    else
                        for j in "${ARRAY[@]}"
                        do
                            k=`expr $i - 1`
                            if [ $k -le ${crc_width} -a $k -gt 0 -a $k -eq $j ]
                            then
                                echo "            crc_data_n[$i] = crc_data_p[$i-1] ^ temp_crc_xor;" >> $file_name
                                match=1
                                break
                            fi
                        done
                        if [ $match -ne 1 ]
                        then
                            echo "            crc_data_n[$i] = crc_data_p[$i-1];" >> $file_name
                        fi
                    fi
                    match=0

                    i=`expr $i - 1`
                done
                echo "" >> $file_name
                echo "            crc_data_n[1] = temp_crc_xor;" >> $file_name

                echo "        end" >> $file_name
                echo "        else if( !enable )" >> $file_name
                echo "        begin" >> $file_name
                echo "            crc_data_n = { crc_data_p[${crc_width_minus_one}:1], enable };" >> $file_name
                echo "        end" >> $file_name
                echo "    end" >> $file_name

                echo "" >> $file_name
                echo "    always@( posedge CLK or negedge RSTn )" >> $file_name
                echo "    begin" >> $file_name
                echo "        crc_data_p <= crc_data_p;" >> $file_name
                echo "" >> $file_name
                echo "        if( !RSTn )" >> $file_name
                echo "        begin" >> $file_name
                echo "            crc_data_p <= RST_SEED_VAL;" >> $file_name
                echo "        end" >> $file_name
                echo "        else if( RSTn )" >> $file_name
                echo "        begin" >> $file_name
                echo "            if( clear )" >> $file_name
                echo "            begin" >> $file_name
                echo "                crc_data_p <= RST_SEED_VAL;" >> $file_name
                echo "            end" >> $file_name
                echo "            else if( !clear )" >> $file_name
                echo "            begin" >> $file_name
                echo "                crc_data_p <= crc_data_n;" >> $file_name
                echo "            end" >> $file_name
                echo "        end" >> $file_name
                echo "    end" >> $file_name
                echo "" >> $file_name
                echo "    assign crc_out = crc_data_p[${crc_width}];" >> $file_name
                echo "" >> $file_name
                echo "endmodule" >> $file_name
            fi
            
            if [ -f ${file_name} ]
            then
                echo ""
                echo "[S] The CRC module was generated successfully."

                echo ""
                echo "Note : This module generation script does not create any testbenches as of right now. Please look forward to a future release, which will probably have one."
            else
                echo ""
                echo "[E] Somethig went wrong. PLease delete any additional files created and re-run the script.."
            fi
        elif [ $degree_val -gt $crc_width ]
        then
            echo ""
            echo "[E] Polynomial degree cannot be greater than the CRC Width. Re-run the script & try again."
        else
            echo ""
            echo "[E] Invalid polynimoal degree provided. Re-run the script & try again."
        fi
    fi
fi
