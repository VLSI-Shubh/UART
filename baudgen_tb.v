`timescale 1ns/1ps
`include "baudgen.v"

module baudgen_tb;

    localparam BAUD_RATE   = 9600;
    localparam CLOCK_FREQ  = 50000000;

    reg clk;
    reg rst;

    wire baud_tick;

    // Instantiate DUT
    baudgen #(
        .baud_rate(BAUD_RATE),
        .clock_freq(CLOCK_FREQ)
    ) uut (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick)
    );

    // Clock generation: 50 MHz => 20 ns period
    always #10 clk = ~clk;

    initial begin
        // VCD setup
        $dumpfile("baudgen_tb.vcd");
        $dumpvars(0, baudgen_tb);

        // Init signals
        clk = 0;
        rst = 1;

        // Hold reset for a few cycles
        #100;
        rst = 0;


        #10000; 

        // End simulation
        $finish;
    end

endmodule
