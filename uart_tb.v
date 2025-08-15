`timescale 1ns / 1ps
`include "uart.v"
`include "uart_tx.v"
`include "uart_rx.v"
`include "baudgen.v"

module uart_tb;

    // Parameters
    parameter BAUD_RATE = 9600;
    parameter CLOCK_FREQ = 50000000;

    // Clock period for 50 MHz
    localparam CLK_PERIOD = 20; // ns

    // Testbench Signals
    reg clk = 0;
    reg rst = 1;

    reg [7:0] tx_data_in = 8'h00;
    reg start_tx = 0;
    wire tx_done;

    wire [7:0] rx_data_out;
    wire rx_done;

    wire tx;
    wire rx;

    // UART top module instantiation
    uart #(
        .BAUD_RATE(BAUD_RATE),
        .CLOCK_FREQ(CLOCK_FREQ)
    ) dut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx),
        .tx_data_in(tx_data_in),
        .start_tx(start_tx),
        .tx_done(tx_done),
        .rx_data_out(rx_data_out),
        .rx_done(rx_done)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // Loopback tx -> rx
    assign rx = tx;

    // Test Procedure
    initial begin
        $dumpfile("uart_tb.vcd");
        $dumpvars(0, uart_tb);

        // Reset
        rst = 1;
        #(10 * CLK_PERIOD);
        rst = 0;

        // Send first byte
        @(posedge clk);
        tx_data_in = 8'hA5; // 10100101
        start_tx = 1;
        @(posedge clk);
        start_tx = 0;

        // Wait for TX to complete
        wait (tx_done == 1);
        $display("TX done at %t", $time);

        // Wait for RX to complete
        wait (rx_done == 1);
        $display("RX done at %t", $time);
        $display("Received Byte: %02X", rx_data_out);

        // Done
        #(10 * CLK_PERIOD);
        $finish;
    end

endmodule
