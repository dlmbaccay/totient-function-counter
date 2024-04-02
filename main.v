module EulerTotient( input R, clk_0, output A, B, C, D, E, F, G );
    wire [3:0] totientValue;    // 4-bit output representing the totient value
    wire [6:0] seg;             // 7-bit output for 7-segment display

    TotientValues totient(.clk(clk_0), .rst(R), .value(totientValue));  // generate the totient values for the first 16 numbers

    SevenSegDecoder decoder(.in(totientValue), .seg(seg));              // decode the 4-bit input to 7-segment display

    assign { A, B, C, D, E, F, G } = seg;                               // assign the 7-bit output to the 7-segment display
endmodule

/**
* Module to decode the 4-bit input to 7-segment display
* @param in: 4-bit input
* @param seg: 7-bit output for 7-segment display
*/
module SevenSegDecoder( input [3:0] in, output reg [6:0] seg );
    always @(in) begin // seven segment display decoder
        case(in)
            4'd1:   seg = 7'b0110000;   // 1
            4'd2:   seg = 7'b1101101;   // 2
            4'd4:   seg = 7'b0110011;   // 4
            4'd6:   seg = 7'b1011111;   // 6
            4'd8:   seg = 7'b1111111;   // 8
            4'd10:  seg = 7'b1110111;   // A
            4'd12:  seg = 7'b1001110;   // C
            default: seg = 7'b0000000;  // 0
        endcase
    end
endmodule

/**
* Module to generate the totient values for the first 16 numbers
* Bonus Approach: The module cycles through the totient values in forward and reverse directions
* @param clk: clock signal
* @param rst: reset signal
* @param value: 4-bit output representing the totient value
*/
module TotientValues( input clk, input rst, output reg [3:0] value );
    reg [3:0] values[15:0]; // array of totient values for the first 16 numbers
    reg [4:0] index = 1;    // to be used as an index to the values array
    reg direction = 0;      // 0 for forward, 1 for reverse

    initial begin // totient values for the first 16 numbers
        values[0] = 4'd1; values[1] = 4'd1; values[2] = 4'd2; values[3] = 4'd2; 
        values[4] = 4'd4; values[5] = 4'd2; values[6] = 4'd6; values[7] = 4'd4; 
        values[8] = 4'd6; values[9] = 4'd4; values[10] = 4'd10; values[11] = 4'd4; 
        values[12] = 4'd12; values[13] = 4'd6; values[14] = 4'd8; values[15] = 4'd8; 
    end

    // cycle through the values array in forward and reverse directions
    always @(posedge clk or posedge rst) begin
        if (rst) begin                  // if reset is 1, reset the index and direction
            index <= 1;                 // reset to 1
            direction <= 0;             // reset to forward (0)
        end
        else begin
            if (!direction) begin       // forward direction
                if (index == 15) begin  // if index is 15, switch from forward to reverse direction
                    direction <= 1;     // switch to reverse direction
                    index <= 15;        // start reverse from the last element
                end
                else begin
                    index <= index + 1;
                end
            end
            else begin                  // reverse direction
                if (index == 0) begin   // if index is 0, switch from reverse to forward direction
                    direction <= 0;     // switch to forward direction
                    index <= 0;         // start forward from the first element
                end     
                else begin              // else, decrement the index
                    index <= index - 1;
                end
            end
        end

        value <= values[index];         // assign corresponding totient value to the output
    end

endmodule