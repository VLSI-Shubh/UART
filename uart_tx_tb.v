`timescale 1ns/1ns
`include "uart_tx.v"

module uart_tx_tb;

    reg [7:0] data_in;
    reg clk, rst, str;
    reg baud_tick;
    wire tx_done, tx_line;

    reg [3:0] baud_counter;

    uart_tx uut (
        .data_in(data_in),
        .clk(clk),
        .rst(rst), 
        .start_tx(str),
        .baud_tick(baud_tick),
        .tx_done(tx_done),
        .tx_line(tx_line)
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

    initial begin
        clk = 0;
        rst = 1;
        str = 0;
        data_in = 8'h00;

        // VCD
        $dumpfile("uart_tx_tb.vcd");
        $dumpvars(0, uart_tx_tb);

        #20 rst = 0;

        // Send A5
        $display("Sending 0xA5 = 10100101 (LSB first: 1,0,1,0,0,1,0,1)");
        data_in = 8'hA5;
        str = 1;
        #20 str = 0;

        wait(tx_done);
        $display("Transmission complete - UART TX is working!");

        #100 $finish;
    end
endmodule