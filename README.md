# Totient Function Counter

- The aim of this Verilog design problem is to design a circuit that calculates Euler’s totient function for the first 16 numbers and display the results on a 7-segment display. Going by the first 16 numbers of Euler’s totient function are [1, 1, 2, 2, 4, 2, 6, 4, 6, 4, 10, 4, 12, 6, 8, 8], the following sequence should be seen in BCD format within the 7-segment display – where 10 is A and 12 is C. An input of R=1 resets the sequence into displaying the first element of the function. Consequently, when a sequence is completed, it displays the function in reverse order.

### Verilog Module Implementation
- The main Verilog implementation of this design problem is divided into three (3) separate modules – EulerTotient, SevenSegDecoder, and TotientValues.

```verilog
module EulerTotient( input R, clk_0, output A, B, C, D, E, F, G );
    wire [3:0] totientValue;    // 4-bit output representing the totient value
    wire [6:0] seg;             // 7-bit output for 7-segment display

    TotientValues totient(.clk(clk_0), .rst(R), .value(totientValue));  // generate the totient values for the first 16 numbers

    SevenSegDecoder decoder(.in(totientValue), .seg(seg));              // decode the 4-bit input to 7-segment display

    assign { A, B, C, D, E, F, G } = seg;                               // assign the 7-bit output to the 7-segment display
endmodule
```

- The first module serves as the main function that takes input from the testbench R, clk_0, and the seven segments needed for the output; whilst also calling upon the
execution of modules TotientValues, which generates the totient values for the first 16 numbers and assigns them correspondingly to the appropriate outputs, which then the SevenSegDecoder module is called upon to display the generated values correctly within a seven-segment display.

```verilog
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
```
- The SevenSegDecoder has a 4-bit input and a 7-bit output of which each bit of the seg output corresponds to a segment on the 7-segment display. An always block encloses a case statement that checks the value of in (input) and sets the seg (segment) accordingly.

```verilog
module TotientValues( input clk, input rst, output reg [3:0] value );
endmodule
```
- The TotientValues module is designed to sequentially display the first 16 values of Euler’s Totient function on a 7-segment display. This module cycles through a predefined set of Totient function values both forwards and backwards, controlled by an external clock signal clk and a reset signal rst. The rising edge of the clk signal updates the displayed Totient value, whilst the reset input, when set to 1, signifies a reset into the sequence of which goes back to the first element within the 16 Euler’s totient function numbers. A 4-bit output value is representative of the values of which the SevenSegDecoder will decode to achieve a proper 7-segment display output.

```verilog
    reg [3:0] values[15:0]; // array of totient values for the first 16 numbers
    reg [4:0] index = 1;    // to be used as an index to the values array
    reg direction = 0;      // 0 for forward, 1 for reverse

    initial begin // totient values for the first 16 numbers
        values[0] = 4'd1; values[1] = 4'd1; values[2] = 4'd2; values[3] = 4'd2; 
        values[4] = 4'd4; values[5] = 4'd2; values[6] = 4'd6; values[7] = 4'd4; 
        values[8] = 4'd6; values[9] = 4'd4; values[10] = 4'd10; values[11] = 4'd4; 
        values[12] = 4'd12; values[13] = 4'd6; values[14] = 4'd8; values[15] = 4'd8; 
    end
```

- This module uses an internal register array named “values” to store the first 16 numbers of Euler’s Totient function. This array is initialized with specific values representing the Totient function’s output for numbers 1 through 16. An index is then employed to traverse the values array of which is controlled by a direction, where 0 indicates a forward traversal of the sequence, and 1 indicates a reverse traversal.

```verilog
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
```

- An always block is then initiated which begins the cycling logic to properly assign the Totient function values with respect to the traversal of the sequence, which is initially set to forward. On each rising edge of clk, the module checks the current direction of traversal. If it’s on a forward traversal, the index will be incremented from 0 to 15, at which point triggers the reverse traversal of the sequence which then decrements from 15 to 0. This traversal will loop through a trigger of forward, reverse, forward, reverse, and so on. The sequence can also be altered by the reset input of which when set to 1, resets the direction of the sequence to a forward traversal and starts assigning to the output once again the first element of the values array.

### Verilog Testbench Implementation

- In testing the correct display of the sequence within the 7-segment display, a total of 3 complete loops were done to test the forward and reverse trigger of the sequence, and 1 reset to test the module’s behavior when a reset is initiated. Presented below is the resulting output of the compiled .vvp Verilog testbench file. The test initially starts with a forward sequence, with the first three R inputs are 1, resetting the sequence each instance. After such, a full forward sequence is tested of which resulted in the correct output of [1, 1, 2, 2, 4, 2, 6, 4,6,4,A,4,C,6, 8, 8], where the reverse sequence is triggered as the first loop through the sequence is completed, which again correctly outputs [8, 8, 6, C, 4, A, 4, 6, 4, 6, 2, 4, 2, 2, 1, 1]. Another test of the forward trigger sequence is then tested to ensure that the cycle works as intended.

```terminal
R=1 clk_0=1 ABCDEFG = 0110000
R=1 clk_0=1 ABCDEFG = 0110000
R=1 clk_0=1 ABCDEFG = 0110000 -- START
R=0 clk_0=1 ABCDEFG = 0110000
R=0 clk_0=1 ABCDEFG = 1101101
R=0 clk_0=1 ABCDEFG = 1101101
R=0 clk_0=1 ABCDEFG = 0110011
R=0 clk_0=1 ABCDEFG = 1101101
R=0 clk_0=1 ABCDEFG = 1011111
R=0 clk_0=1 ABCDEFG = 0110011
R=0 clk_0=1 ABCDEFG = 1011111
R=0 clk_0=1 ABCDEFG = 0110011
R=0 clk_0=1 ABCDEFG = 1110111
R=0 clk_0=1 ABCDEFG = 0110011
R=0 clk_0=1 ABCDEFG = 1001110
R=0 clk_0=1 ABCDEFG = 1011111
R=0 clk_0=1 ABCDEFG = 1111111
R=0 clk_0=1 ABCDEFG = 1111111 -- END
R=0 clk_0=1 ABCDEFG = 1111111 -- START
R=0 clk_0=1 ABCDEFG = 1111111
R=0 clk_0=1 ABCDEFG = 1011111
R=0 clk_0=1 ABCDEFG = 1001110
R=0 clk_0=1 ABCDEFG = 0110011
R=0 clk_0=1 ABCDEFG = 1110111
R=0 clk_0=1 ABCDEFG = 0110011
R=0 clk_0=1 ABCDEFG = 1011111
R=0 clk_0=1 ABCDEFG = 0110011
R=0 clk_0=1 ABCDEFG = 1011111
R=0 clk_0=1 ABCDEFG = 1101101
R=0 clk_0=1 ABCDEFG = 0110011
R=0 clk_0=1 ABCDEFG = 1101101
R=0 clk_0=1 ABCDEFG = 1101101
R=0 clk_0=1 ABCDEFG = 0110000
R=0 clk_0=1 ABCDEFG = 0110000 -- END
R=0 clk_0=1 ABCDEFG = 0110000 -- START
R=0 clk_0=1 ABCDEFG = 0110000
R=0 clk_0=1 ABCDEFG = 1101101
R=0 clk_0=1 ABCDEFG = 1101101
R=0 clk_0=1 ABCDEFG = 0110011
R=0 clk_0=1 ABCDEFG = 1101101
R=0 clk_0=1 ABCDEFG = 1011111
R=0 clk_0=1 ABCDEFG = 0110011
R=0 clk_0=1 ABCDEFG = 1011111
R=0 clk_0=1 ABCDEFG = 0110011
R=0 clk_0=1 ABCDEFG = 1110111
R=0 clk_0=1 ABCDEFG = 0110011
R=0 clk_0=1 ABCDEFG = 1001110
R=0 clk_0=1 ABCDEFG = 1011111
R=0 clk_0=1 ABCDEFG = 1111111
R=0 clk_0=1 ABCDEFG = 1111111 -- END
```