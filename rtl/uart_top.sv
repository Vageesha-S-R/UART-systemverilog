module uart_top #(
    parameter BAUD_RATE = 9600,
    parameter CLK_FREQ = 50000000
    parameter PARITY_ENABLE = 1'b0,
    parameter PARITY_ODD = 1'b0
) (
    input clk,
    input rst_n,
    input logic[7:0] data_in,
    input logic data_in_valid,
    input logic read_en,
    output logic [7:0] data_out,
    output logic data_out_valid,
    output logic tx_fifo_full,
    output logic rx_fifo_empty
);

logic baud_tick;
logic serial_line;

logic [7:0] tx_fifo_data_out;
logic tx_fifo_empty;
logic tx_fifo_read;
logic tx_busy;

logic [7:0] rx_data;
logic rx_data_valid;
logic rx_fifo_write;




baud_gen #(
    .BAUD_RATE(BAUD_RATE),
    .CLK_FREQ(CLK_FREQ)) baud_gen_inst(
    .clk(clk),
    .rst_n(rst_n),
    .baud_tick(baud_tick));

fifo tx_fifo (
    .clk(clk),
    .rst_n(rst_n),
    .write_en(data_in_valid),
    .read_en(tx_fifo_read),
    .data_in(data_in),
    .data_out(tx_fifo_data_out),
    .empty(tx_fifo_empty),
    .full(tx_fifo_full)
);

uart_tx #(
    .PARITY_ENABLE(PARITY_ENABLE),
    .PARITY_ODD(PARITY_ODD)
) uart_tx_inst (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(tx_fifo_data_out),
    .baud_tick(baud_tick),
    .data_valid(tx_fifo_read),
    .tx(serial_line),
    .busy(tx_busy)
);

uart_rx #(
    .PARITY_ENABLE(PARITY_ENABLE),
    .PARITY_ODD(PARITY_ODD)
) uart_rx_inst (
    .clk(clk),
    .rst_n(rst_n),
    .rx(serial_line),
    .baud_tick(baud_tick),
    .data_out(rx_data),
    .data_valid(rx_data_valid)
);

fifo rx_fifo (
    .clk(clk),
    .rst_n(rst_n),
    .write_en(rx_fifo_write),
    .read_en(read_en),
    .data_in(rx_data),
    .data_out(data_out),
    .empty(rx_fifo_empty),
    .full()
);


assign tx_fifo_read  = !tx_fifo_empty && !tx_busy;
assign rx_fifo_write = rx_data_valid; 

assign data_out_valid = !rx_fifo_empty;

endmodule

