module uart_top #(
    parameter BAUD_RATE = 9600,
    parameter CLK_FREQ = 50000000
) (
    input clk,
    input rst_n,
    input logic[7:0] data_in,
    input logic data_in_valid,
    output logic busy,
    output logic [7:0] data_out,
    output logic data_out_valid
);

logic baud_tick;
logic serial_line;
baud_gen #(
    .BAUD_RATE(BAUD_RATE),
    .CLK_FREQ(CLK_FREQ)) baud_gen_inst(
    .clk(clk),
    .rst_n(rst_n),
    .baud_tick(baud_tick));

uart_tx uart_tx_inst (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .baud_tick(baud_tick),
    .data_valid(data_in_valid),
    .tx(serial_line),
    .busy(busy)
);

uart_rx uart_rx_inst (
    .clk(clk),
    .rst_n(rst_n),
    .rx(serial_line),
    .baud_tick(baud_tick),
    .data_out(data_out),
    .data_valid(data_out_valid)
);

endmodule

