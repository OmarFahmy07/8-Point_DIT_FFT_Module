// File : fft.v
// Author : Omar Fahmy
// Date : 8/12/2022
// Version : 1
// Abstract : this file contains the implementation of an 8-point FFT with fully parallel architecture

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// Module ports list, declaration, and data type ///////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////

module fft #(parameter INT_WIDTH = 8,                     // Integer Field Width
             FRACT_WIDTH = 8,                             // Fractional Field Width
             DATA_WIDTH = INT_WIDTH + FRACT_WIDTH)
            (input wire clk,
             input wire rst_n,
             input wire fft_en,
             input wire [DATA_WIDTH - 1 : 0] in0_real,
             input wire [DATA_WIDTH - 1 : 0] in0_imag,
             input wire [DATA_WIDTH - 1 : 0] in1_real,
             input wire [DATA_WIDTH - 1 : 0] in1_imag,
             input wire [DATA_WIDTH - 1 : 0] in2_real,
             input wire [DATA_WIDTH - 1 : 0] in2_imag,
             input wire [DATA_WIDTH - 1 : 0] in3_real,
             input wire [DATA_WIDTH - 1 : 0] in3_imag,
             input wire [DATA_WIDTH - 1 : 0] in4_real,
             input wire [DATA_WIDTH - 1 : 0] in4_imag,
             input wire [DATA_WIDTH - 1 : 0] in5_real,
             input wire [DATA_WIDTH - 1 : 0] in5_imag,
             input wire [DATA_WIDTH - 1 : 0] in6_real,
             input wire [DATA_WIDTH - 1 : 0] in6_imag,
             input wire [DATA_WIDTH - 1 : 0] in7_real,
             input wire [DATA_WIDTH - 1 : 0] in7_imag,
             output wire [DATA_WIDTH - 1 : 0] out0_real,
             output wire [DATA_WIDTH - 1 : 0] out0_imag,
             output wire [DATA_WIDTH - 1 : 0] out1_real,
             output wire [DATA_WIDTH - 1 : 0] out1_imag,
             output wire [DATA_WIDTH - 1 : 0] out2_real,
             output wire [DATA_WIDTH - 1 : 0] out2_imag,
             output wire [DATA_WIDTH - 1 : 0] out3_real,
             output wire [DATA_WIDTH - 1 : 0] out3_imag,
             output wire [DATA_WIDTH - 1 : 0] out4_real,
             output wire [DATA_WIDTH - 1 : 0] out4_imag,
             output wire [DATA_WIDTH - 1 : 0] out5_real,
             output wire [DATA_WIDTH - 1 : 0] out5_imag,
             output wire [DATA_WIDTH - 1 : 0] out6_real,
             output wire [DATA_WIDTH - 1 : 0] out6_imag,
             output wire [DATA_WIDTH - 1 : 0] out7_real,
             output wire [DATA_WIDTH - 1 : 0] out7_imag);
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////// Local Parameters //////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Twiddle Factors
    localparam W_0_R = 'b00000000000000010000000000000000;
    localparam W_1_R = 'b00000000000000001011010100000100;
    localparam W_2_R = 'b00000000000000000000000000000000;
    localparam W_3_R = 'b11111111111111110100101011111011;
    localparam W_4_R = 'b11111111111111110000000000000000;
    localparam W_5_R = 'b11111111111111110100101011111011;
    localparam W_6_R = 'b11111111111111111111111111111111;
    localparam W_7_R = 'b00000000000000001011010100000100;
    localparam W_0_I = 'b00000000000000000000000000000000;
    localparam W_1_I = 'b11111111111111110100101011111011;
    localparam W_2_I = 'b11111111111111110000000000000000;
    localparam W_3_I = 'b11111111111111110100101011111011;
    localparam W_4_I = 'b11111111111111111111111111111111;
    localparam W_5_I = 'b00000000000000001011010100000100;
    localparam W_6_I = 'b00000000000000010000000000000000;
    localparam W_7_I = 'b00000000000000001011010100000100;
    
    // Number of FFT Points
    localparam NFFT      = 8;
    localparam NFFT_BITS = 3;
    
    // Number of Butterfly Units
    localparam NUM_OF_BUTTERFLIES = NFFT/2 * NFFT_BITS;
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////// Registers and Internal Connections ///////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Inputs Registers
    reg [DATA_WIDTH - 1 : 0] in_real_r [NFFT-1 : 0];
    reg [DATA_WIDTH - 1 : 0] in_imag_r [NFFT-1 : 0];
    
    //Butterfly Units Outputs
    wire [DATA_WIDTH - 1 : 0] but_out0_real [NUM_OF_BUTTERFLIES-1 : 0];
    wire [DATA_WIDTH - 1 : 0] but_out0_imag [NUM_OF_BUTTERFLIES-1 : 0];
    wire [DATA_WIDTH - 1 : 0] but_out1_real [NUM_OF_BUTTERFLIES-1 : 0];
    wire [DATA_WIDTH - 1 : 0] but_out1_imag [NUM_OF_BUTTERFLIES-1 : 0];
    
    // Butterfly Units Registers
    reg [DATA_WIDTH - 1 : 0] but_out0_real_r [NUM_OF_BUTTERFLIES-1 : 0];
    reg [DATA_WIDTH - 1 : 0] but_out0_imag_r [NUM_OF_BUTTERFLIES-1 : 0];
    reg [DATA_WIDTH - 1 : 0] but_out1_real_r [NUM_OF_BUTTERFLIES-1 : 0];
    reg [DATA_WIDTH - 1 : 0] but_out1_imag_r [NUM_OF_BUTTERFLIES-1 : 0];
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////// Loop Counter /////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    
    integer i;
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////// Procedural Blocks /////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Register all butterfly units outputs
    always@(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            for(i = 0; i < NUM_OF_BUTTERFLIES; i = i + 1)
            begin
                but_out0_real_r[i] <= 'd0;
                but_out0_imag_r[i] <= 'd0;
                but_out1_real_r[i] <= 'd0;
                but_out1_imag_r[i] <= 'd0;
            end
        end
        else
        begin
            for(i = 0; i < NUM_OF_BUTTERFLIES; i = i + 1)
            begin
                but_out0_real_r[i] <= but_out0_real[i];
                but_out0_imag_r[i] <= but_out0_imag[i];
                but_out1_real_r[i] <= but_out1_real[i];
                but_out1_imag_r[i] <= but_out1_imag[i];
            end
        end
    end
    
    // Register all inputs
    always@(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            for(i = 0; i < NFFT; i = i + 1)
            begin
                in_real_r[i] <= 'd0;
                in_imag_r[i] <= 'd0;
            end
        end
        else
        begin
            if (fft_en)
            begin
                in_real_r[0] <= in0_real;
                in_real_r[1] <= in1_real;
                in_real_r[2] <= in2_real;
                in_real_r[3] <= in3_real;
                in_real_r[4] <= in4_real;
                in_real_r[5] <= in5_real;
                in_real_r[6] <= in6_real;
                in_real_r[7] <= in7_real;
                in_imag_r[0] <= in0_imag;
                in_imag_r[1] <= in1_imag;
                in_imag_r[2] <= in2_imag;
                in_imag_r[3] <= in3_imag;
                in_imag_r[4] <= in4_imag;
                in_imag_r[5] <= in5_imag;
                in_imag_r[6] <= in6_imag;
                in_imag_r[7] <= in7_imag;
            end
        end
    end
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////// Continuous Assignments /////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    assign out0_real = but_out0_real_r[8];
    assign out1_real = but_out0_real_r[9];
    assign out2_real = but_out0_real_r[10];
    assign out3_real = but_out0_real_r[11];
    assign out4_real = but_out1_real_r[8];
    assign out5_real = but_out1_real_r[9];
    assign out6_real = but_out1_real_r[10];
    assign out7_real = but_out1_real_r[11];
    assign out0_imag = but_out0_imag_r[8];
    assign out1_imag = but_out0_imag_r[9];
    assign out2_imag = but_out0_imag_r[10];
    assign out3_imag = but_out0_imag_r[11];
    assign out4_imag = but_out1_imag_r[8];
    assign out5_imag = but_out1_imag_r[9];
    assign out6_imag = but_out1_imag_r[10];
    assign out7_imag = but_out1_imag_r[11];
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////// Instantiations //////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Note: for generate cannot be used here because there is no common pattern between instantiations
    
    butterfly #(.INT_WIDTH(INT_WIDTH), .FRACT_WIDTH(FRACT_WIDTH)) U0_butterfly
    (
    .in0_real(in_real_r[0]),
    .in0_imag(in_imag_r[0]),
    .in1_real(in_real_r[4]),
    .in1_imag(in_imag_r[4]),
    .w_r(W_0_R),
    .w_i(W_0_I),
    .out0_real(but_out0_real[0]),
    .out0_imag(but_out0_imag[0]),
    .out1_real(but_out1_real[0]),
    .out1_imag(but_out1_imag[0])
    );
    
    butterfly #(.INT_WIDTH(INT_WIDTH), .FRACT_WIDTH(FRACT_WIDTH)) U1_butterfly
    (
    .in0_real(in_real_r[2]),
    .in0_imag(in_imag_r[2]),
    .in1_real(in_real_r[6]),
    .in1_imag(in_imag_r[6]),
    .w_r(W_0_R),
    .w_i(W_0_I),
    .out0_real(but_out0_real[1]),
    .out0_imag(but_out0_imag[1]),
    .out1_real(but_out1_real[1]),
    .out1_imag(but_out1_imag[1])
    );
    
    butterfly #(.INT_WIDTH(INT_WIDTH), .FRACT_WIDTH(FRACT_WIDTH)) U2_butterfly
    (
    .in0_real(in_real_r[1]),
    .in0_imag(in_imag_r[1]),
    .in1_real(in_real_r[5]),
    .in1_imag(in_imag_r[5]),
    .w_r(W_0_R),
    .w_i(W_0_I),
    .out0_real(but_out0_real[2]),
    .out0_imag(but_out0_imag[2]),
    .out1_real(but_out1_real[2]),
    .out1_imag(but_out1_imag[2])
    );
    
    butterfly #(.INT_WIDTH(INT_WIDTH), .FRACT_WIDTH(FRACT_WIDTH)) U3_butterfly
    (
    .in0_real(in_real_r[3]),
    .in0_imag(in_imag_r[3]),
    .in1_real(in_real_r[7]),
    .in1_imag(in_imag_r[7]),
    .w_r(W_0_R),
    .w_i(W_0_I),
    .out0_real(but_out0_real[3]),
    .out0_imag(but_out0_imag[3]),
    .out1_real(but_out1_real[3]),
    .out1_imag(but_out1_imag[3])
    );
    
    butterfly #(.INT_WIDTH(INT_WIDTH), .FRACT_WIDTH(FRACT_WIDTH)) U4_butterfly
    (
    .in0_real(but_out0_real_r[0]),
    .in0_imag(but_out0_imag_r[0]),
    .in1_real(but_out0_real_r[1]),
    .in1_imag(but_out0_imag_r[1]),
    .w_r(W_0_R),
    .w_i(W_0_I),
    .out0_real(but_out0_real[4]),
    .out0_imag(but_out0_imag[4]),
    .out1_real(but_out1_real[4]),
    .out1_imag(but_out1_imag[4])
    );
    
    butterfly #(.INT_WIDTH(INT_WIDTH), .FRACT_WIDTH(FRACT_WIDTH)) U5_butterfly
    (
    .in0_real(but_out1_real_r[0]),
    .in0_imag(but_out1_imag_r[0]),
    .in1_real(but_out1_real_r[1]),
    .in1_imag(but_out1_imag_r[1]),
    .w_r(W_2_R),
    .w_i(W_2_I),
    .out0_real(but_out0_real[5]),
    .out0_imag(but_out0_imag[5]),
    .out1_real(but_out1_real[5]),
    .out1_imag(but_out1_imag[5])
    );
    
    butterfly #(.INT_WIDTH(INT_WIDTH), .FRACT_WIDTH(FRACT_WIDTH)) U6_butterfly
    (
    .in0_real(but_out0_real_r[2]),
    .in0_imag(but_out0_imag_r[2]),
    .in1_real(but_out0_real_r[3]),
    .in1_imag(but_out0_imag_r[3]),
    .w_r(W_0_R),
    .w_i(W_0_I),
    .out0_real(but_out0_real[6]),
    .out0_imag(but_out0_imag[6]),
    .out1_real(but_out1_real[6]),
    .out1_imag(but_out1_imag[6])
    );
    
    butterfly #(.INT_WIDTH(INT_WIDTH), .FRACT_WIDTH(FRACT_WIDTH)) U7_butterfly
    (
    .in0_real(but_out1_real_r[2]),
    .in0_imag(but_out1_imag_r[2]),
    .in1_real(but_out1_real_r[3]),
    .in1_imag(but_out1_imag_r[3]),
    .w_r(W_2_R),
    .w_i(W_2_I),
    .out0_real(but_out0_real[7]),
    .out0_imag(but_out0_imag[7]),
    .out1_real(but_out1_real[7]),
    .out1_imag(but_out1_imag[7])
    );
    
    butterfly #(.INT_WIDTH(INT_WIDTH), .FRACT_WIDTH(FRACT_WIDTH)) U8_butterfly
    (
    .in0_real(but_out0_real_r[4]),
    .in0_imag(but_out0_imag_r[4]),
    .in1_real(but_out0_real_r[6]),
    .in1_imag(but_out0_imag_r[6]),
    .w_r(W_0_R),
    .w_i(W_0_I),
    .out0_real(but_out0_real[8]),
    .out0_imag(but_out0_imag[8]),
    .out1_real(but_out1_real[8]),
    .out1_imag(but_out1_imag[8])
    );
    
    butterfly #(.INT_WIDTH(INT_WIDTH), .FRACT_WIDTH(FRACT_WIDTH)) U9_butterfly
    (
    .in0_real(but_out0_real_r[5]),
    .in0_imag(but_out0_imag_r[5]),
    .in1_real(but_out0_real_r[7]),
    .in1_imag(but_out0_imag_r[7]),
    .w_r(W_1_R),
    .w_i(W_1_I),
    .out0_real(but_out0_real[9]),
    .out0_imag(but_out0_imag[9]),
    .out1_real(but_out1_real[9]),
    .out1_imag(but_out1_imag[9])
    );
    
    butterfly #(.INT_WIDTH(INT_WIDTH), .FRACT_WIDTH(FRACT_WIDTH)) U10_butterfly
    (
    .in0_real(but_out1_real_r[4]),
    .in0_imag(but_out1_imag_r[4]),
    .in1_real(but_out1_real_r[6]),
    .in1_imag(but_out1_imag_r[6]),
    .w_r(W_2_R),
    .w_i(W_2_I),
    .out0_real(but_out0_real[10]),
    .out0_imag(but_out0_imag[10]),
    .out1_real(but_out1_real[10]),
    .out1_imag(but_out1_imag[10])
    );
    
    butterfly #(.INT_WIDTH(INT_WIDTH), .FRACT_WIDTH(FRACT_WIDTH)) U11_butterfly
    (
    .in0_real(but_out1_real_r[5]),
    .in0_imag(but_out1_imag_r[5]),
    .in1_real(but_out1_real_r[7]),
    .in1_imag(but_out1_imag_r[7]),
    .w_r(W_3_R),
    .w_i(W_3_I),
    .out0_real(but_out0_real[11]),
    .out0_imag(but_out0_imag[11]),
    .out1_real(but_out1_real[11]),
    .out1_imag(but_out1_imag[11])
    );
    
endmodule
