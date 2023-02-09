// File : butterfly.v
// Author : Omar Fahmy
// Date : 2/11/2022
// Version : 2
// Modifications: replaced the "multiply" function by a "multiply" module
// Abstract : this file contains the architecture of a DIT butterfly unit


//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// Module ports list, declaration, and data type ///////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////

module butterfly #(parameter INT_WIDTH = 8,                    // Integer Field Width
                   FRACT_WIDTH = 8,                            // Fractional Field Width
                   DATA_WIDTH = INT_WIDTH + FRACT_WIDTH)
                  (input wire [DATA_WIDTH - 1 : 0] in0_real,
                   input wire [DATA_WIDTH - 1 : 0] in0_imag,
                   input wire [DATA_WIDTH - 1 : 0] in1_real,
                   input wire [DATA_WIDTH - 1 : 0] in1_imag,
                   input wire [DATA_WIDTH - 1 : 0] w_r,
                   input wire [DATA_WIDTH - 1 : 0] w_i,
                   output reg [DATA_WIDTH - 1 : 0] out0_real,
                   output reg [DATA_WIDTH - 1 : 0] out0_imag,
                   output reg [DATA_WIDTH - 1 : 0] out1_real,
                   output reg [DATA_WIDTH - 1 : 0] out1_imag);
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////// Signals and Internal Connections ///////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    
    wire [DATA_WIDTH - 1 : 0] prod0, prod1, prod2, prod3;
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////// Procedural Blocks /////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    always@(*)
    begin
        out0_real = in0_real + prod0 - prod1;
        out0_imag = in0_imag + prod2 + prod3;
        out1_real = in0_real + prod1 - prod0;
        out1_imag = in0_imag - prod2 - prod3;
    end
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////// Instantiations //////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    multiply #(.INT_WIDTH(INT_WIDTH), .FRACT_WIDTH(FRACT_WIDTH)) U0_multiply (
    .operand1(in1_real),
    .operand2(w_r),
    .result(prod0)
    );
    
    multiply #(.INT_WIDTH(INT_WIDTH), .FRACT_WIDTH(FRACT_WIDTH)) U1_multiply (
    .operand1(in1_imag),
    .operand2(w_i),
    .result(prod1)
    );
    
    multiply #(.INT_WIDTH(INT_WIDTH), .FRACT_WIDTH(FRACT_WIDTH)) U2_multiply (
    .operand1(in1_real),
    .operand2(w_i),
    .result(prod2)
    );
    
    multiply #(.INT_WIDTH(INT_WIDTH), .FRACT_WIDTH(FRACT_WIDTH)) U3_multiply (
    .operand1(in1_imag),
    .operand2(w_r),
    .result(prod3)
    );
    
endmodule
    
