module uart #(
    parameter BAUD_RATE = 9600,
    parameter CLOCK_FREQ = 50000000
)(
    input clk,
    input rst,

    // Serial I/O
    input rx,
    output tx,

    // Transmit interface
    input [7:0] tx_data_in,
    input start_tx,
    output tx_done,

    // Receive interface
    output [7:0] rx_data_out,
    output rx_done
);

    wire baud_tick;

    // Baud generator instantiation
    baudgen #(
        .baud_rate(BAUD_RATE),
        .clock_freq(CLOCK_FREQ)
    ) baud_generator (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick)
    );

    // UART Transmitter instantiation
    uart_tx transmitter (
        .clk(clk),
        .rst(rst),
        .start_tx(start_tx),
        .baud_tick(baud_tick),
        .data_in(tx_data_in),
        .tx_done(tx_done),
        .tx_line(tx)
    );

    // UART Receiver instantiation
    uart_rx receiver (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .rx(rx),
        .rx_done(rx_done),
        .data_out(rx_data_out)
    );

endmodule
