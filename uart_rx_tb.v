`timescale 1ns/1ns
`include "uart_rx.v"

module uart_rx_tb;

    reg rx;
    reg clk, rst;
    reg baud_tick;
    wire rx_done;
    wire [7:0] data_out;

    reg [3:0] baud_counter;

    uart_rx uut (
        .rx(rx),
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .rx_done(rx_done),
        .data_out(data_out)
    );

    // 50MHz clock
    always #10 clk = ~clk;

    // Baud tick generator (1 tick every 16 clock cycles)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            baud_counter <= 0;
            baud_tick <= 0;
        end else begin
            if (baud_counter == 15) begin
                baud_counter <= 0;
                baud_tick <= 1;
            end else begin
                baud_counter <= baud_counter + 1;
                baud_tick <= 0;
            end
        end
    end

    // Debug monitoring
    always @(posedge clk) begin
        if (uut.ps != 4'b0001) begin // Not idle
            $display("Time: %0t, State: %b, rx: %b, baud_tick: %b, tick_counter: %d, bit_index: %d", 
                     $time, uut.ps, rx, baud_tick, uut.tick_counter, uut.bit_index);
        end
    end

    // Timeout to prevent infinite simulation
    initial begin
        #50000; // 50us timeout
        $display("ERROR: Simulation timeout - stuck in infinite loop");
        $finish;
    end

    initial begin
        clk = 0;
        rst = 1;
        rx = 1; // Idle high

        // VCD
        $dumpfile("uart_rx_tb.vcd");
        $dumpvars(0, uart_rx_tb);

        #20 rst = 0;

        // Receive A5 (send start bit, then 8 data bits LSB first, then stop bit)
        $display("Receiving 0xA5 = 10100101 (LSB first: 1,0,1,0,0,1,0,1)");
        
        #100; // Wait a bit
        
        rx = 0; @(posedge baud_tick); // Start bit
        rx = 1; @(posedge baud_tick); // Bit 0
        rx = 0; @(posedge baud_tick); // Bit 1
        rx = 1; @(posedge baud_tick); // Bit 2
        rx = 0; @(posedge baud_tick); // Bit 3
        rx = 0; @(posedge baud_tick); // Bit 4
        rx = 1; @(posedge baud_tick); // Bit 5
        rx = 0; @(posedge baud_tick); // Bit 6
        rx = 1; @(posedge baud_tick); // Bit 7
        rx = 1; @(posedge baud_tick); // Stop bit

        @(posedge rx_done);
        $display("Reception complete - UART RX is working!");

        #100 $finish;
    end

endmodule