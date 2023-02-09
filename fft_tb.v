// File : fft_tb.v
// Author : Omar Fahmy
// Date : 9/12/2022
// Version : 1
// Abstract : a testbench for testing an 8-point DIT FFT module

`timescale 1 ns / 1 ps

module fft_tb();
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////// Parameters /////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    
    parameter INT_WIDTH_tb   = 16; // Integer Field
    parameter FRACT_WIDTH_tb = 16; // Fractional Field
    parameter DATA_WIDTH_tb  = INT_WIDTH_tb + FRACT_WIDTH_tb;
    parameter NUM_OF_INPUTS  = 6;  // Number of Test Inputs
    parameter NFFT           = 8; // FFT Number of Points
    parameter CLK_PERIOD     = 10;
    parameter LATENCY        = 4; // Latency Number of Clock Cycles 
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////// DUT Signals ////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    
    reg clk_tb;
    reg rst_n_tb;
    reg fft_en_tb;
    reg [DATA_WIDTH_tb-1 : 0] in_real_tb [NFFT-1 : 0];
    reg [DATA_WIDTH_tb-1 : 0] in_imag_tb [NFFT-1 : 0];
    wire [DATA_WIDTH_tb-1 : 0] out_real_tb [NFFT-1 : 0];
    wire [DATA_WIDTH_tb-1 : 0] out_imag_tb [NFFT-1 : 0];
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////// Memories ///////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Memories for Test Inputs and Outputs
    reg [DATA_WIDTH_tb-1 : 0] inputs_real_rom [NFFT * NUM_OF_INPUTS * 2 : 0];
    reg [DATA_WIDTH_tb-1 : 0] inputs_imag_rom [NFFT * NUM_OF_INPUTS * 2 : 0];
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////// Loop Counters //////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    
    integer i, j;
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////// File Handlers //////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    
    integer f1, f2;
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////// Initial Block ///////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    
    initial
    begin
        $dumpfile("fft.vcd");
        $dumpvars;
        initialize();
        reset();
        test();
        #100
        $finish;
    end
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////// Clock Generation //////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    
    always
    begin
    #(CLK_PERIOD/2.0) clk_tb = ~clk_tb;
    end
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////// Tasks ///////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    
    task initialize;
        begin
            clk_tb    = 1'b0;
            rst_n_tb  = 1'b1;
            fft_en_tb = 1'b0;
            for(i = 0; i < NFFT; i = i + 1)
            begin
                in_real_tb[i] = 'd0;
                in_imag_tb[i] = 'd0;
            end
            $readmemb("Reference_Model/inputs_real.txt", inputs_real_rom);
            $readmemb("Reference_Model/inputs_imag.txt", inputs_imag_rom);
        end
    endtask
    
    task reset;
        begin
            rst_n_tb = 1'b1;
            #1
            rst_n_tb = 1'b0;
            #1
            rst_n_tb = 1'b1;
        end
    endtask
    
    task test;
        begin
            f1 = $fopen("outputs_real.txt", "w");
            f2 = $fopen("outputs_imag.txt", "w");
            @(negedge clk_tb);
            fft_en_tb = 1'b1;
            for(j = 0; j < NUM_OF_INPUTS + LATENCY; j = j + 1)
            begin
                for(i = 0; i < NFFT; i = i + 1)
                begin
                    if (j < NUM_OF_INPUTS)
                    begin
                        in_real_tb[i] = inputs_real_rom[i + NFFT*j];
                        in_imag_tb[i] = inputs_imag_rom[i + NFFT*j];
                    end
                    if (j >= LATENCY)
                    begin
                        $fwrite(f1, "%b\n", out_real_tb[i]);
                        $fwrite(f2, "%b\n", out_imag_tb[i]);
                    end
                end
                @(negedge clk_tb);
            end
            $fclose(f1);
            $fclose(f2);
        end
    endtask
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////// DUT Instantation //////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    
    fft #(.INT_WIDTH(INT_WIDTH_tb), .FRACT_WIDTH(FRACT_WIDTH_tb)) U0_fft
    (
    .clk(clk_tb),
    .rst_n(rst_n_tb),
    .fft_en(fft_en_tb),
    .in0_real(in_real_tb[0]),
    .in0_imag(in_imag_tb[0]),
    .in1_real(in_real_tb[1]),
    .in1_imag(in_imag_tb[1]),
    .in2_real(in_real_tb[2]),
    .in2_imag(in_imag_tb[2]),
    .in3_real(in_real_tb[3]),
    .in3_imag(in_imag_tb[3]),
    .in4_real(in_real_tb[4]),
    .in4_imag(in_imag_tb[4]),
    .in5_real(in_real_tb[5]),
    .in5_imag(in_imag_tb[5]),
    .in6_real(in_real_tb[6]),
    .in6_imag(in_imag_tb[6]),
    .in7_real(in_real_tb[7]),
    .in7_imag(in_imag_tb[7]),
    .out0_real(out_real_tb[0]),
    .out0_imag(out_imag_tb[0]),
    .out1_real(out_real_tb[1]),
    .out1_imag(out_imag_tb[1]),
    .out2_real(out_real_tb[2]),
    .out2_imag(out_imag_tb[2]),
    .out3_real(out_real_tb[3]),
    .out3_imag(out_imag_tb[3]),
    .out4_real(out_real_tb[4]),
    .out4_imag(out_imag_tb[4]),
    .out5_real(out_real_tb[5]),
    .out5_imag(out_imag_tb[5]),
    .out6_real(out_real_tb[6]),
    .out6_imag(out_imag_tb[6]),
    .out7_real(out_real_tb[7]),
    .out7_imag(out_imag_tb[7])
    );
    
endmodule
