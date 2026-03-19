module uart_top #(
    parameter BAUD_RATE = 9600,
    parameter CLK_FREQ = 50000000
) (
    input clk,
    input rst_n,

    input logic write_en,
    input logic read_en,
    input logic [3:0] addr,
    input logic [7:0] wdata,
    output logic [7:0] rdata,

    output logic irq
);

logic baud_tick;
logic baud_16x_tick;
logic serial_line;

logic [7:0] tx_fifo_data_out;
logic tx_fifo_empty;
logic tx_fifo_full;
logic tx_fifo_read;
logic tx_fifo_write;
logic [7:0] tx_fifo_wdata;
logic tx_busy;

logic [7:0] rx_fifo_data_out;
logic rx_fifo_empty;
logic rx_fifo_read;
logic rx_fifo_write;
logic rx_fifo_full;

logic [7:0] rx_data;
logic rx_data_valid;
logic parity_error;

logic parity_enable;
logic parity_odd;

uart_regs uart_regs_inst (
    .clk(clk),
    .rst_n(rst_n),
    .write_en(write_en),
    .read_en(read_en),
    .addr(addr),
    .wdata(wdata),
    .rdata(rdata),
    .tx_fifo_write(tx_fifo_write),
    .tx_fifo_wdata(tx_fifo_wdata),
    .tx_fifo_full(tx_fifo_full),
    .rx_fifo_read(rx_fifo_read),
    .rx_fifo_rdata(rx_fifo_data_out),
    .rx_fifo_empty(rx_fifo_empty),
    .parity_error(parity_error),
    .parity_enable(parity_enable),
    .parity_odd(parity_odd),
    .irq(irq)
);


baud_gen #(
    .BAUD_RATE(BAUD_RATE),
    .CLK_FREQ(CLK_FREQ)) baud_gen_inst(
    .clk(clk),
    .rst_n(rst_n),
    .baud_tick(baud_tick),
    .baud_16x_tick(baud_16x_tick));

fifo tx_fifo (
    .clk(clk),
    .rst_n(rst_n),
    .write_en(tx_fifo_write),
    .read_en(tx_fifo_read),
    .data_in(tx_fifo_wdata),
    .data_out(tx_fifo_data_out),
    .empty(tx_fifo_empty),
    .full(tx_fifo_full)
);

uart_tx uart_tx_inst (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(tx_fifo_data_out),
    .baud_tick(baud_tick),
    .data_valid(tx_fifo_read),
    .parity_enable(parity_enable),
    .parity_odd(parity_odd),
    .tx(serial_line),
    .busy(tx_busy)
);

uart_rx uart_rx_inst (
    .clk(clk),
    .rst_n(rst_n),
    .rx(serial_line),
    .baud_16x_tick(baud_16x_tick),
    .parity_enable(parity_enable),
    .parity_odd(parity_odd),
    .data_out(rx_data),
    .data_valid(rx_data_valid),
    .parity_error(parity_error)
);

fifo rx_fifo (
    .clk(clk),
    .rst_n(rst_n),
    .write_en(rx_fifo_write),
    .read_en(rx_fifo_read),
    .data_in(rx_data),
    .data_out(rx_fifo_data_out),
    .empty(rx_fifo_empty),
    .full(rx_fifo_full)
);


assign tx_fifo_read  = !tx_fifo_empty && !tx_busy;
assign rx_fifo_write = rx_data_valid && !rx_fifo_full; 

endmodule

