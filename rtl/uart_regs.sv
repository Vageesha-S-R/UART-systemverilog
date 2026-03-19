module uart_regs (
    input logic clk,
    input logic rst_n,

    //CPU Interface
    input logic write_en,
    input logic read_en,
    input logic [2:0] addr,
    input logic [7:0] wdata,
    output logic [7:0] rdata,

    // TX FIFO Interface
    output logic tx_fifo_write,
    output logic [7:0] tx_fifo_wdata,
    input logic tx_fifo_full,

    // RX FIFO Interface
    output logic rx_fifo_read,
    input logic [7:0] rx_fifo_rdata,
    input logic rx_fifo_empty,

    // status inputs
    input logic parity_error,

    // control outputs
    output logic parity_enable,
    output logic parity_odd,

    // interrupt
    output logic irq
    
);
    
endmodule