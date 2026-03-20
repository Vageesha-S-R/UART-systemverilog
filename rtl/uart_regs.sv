module uart_regs (
    input logic clk,
    input logic rst_n,

    //CPU Interface
    input logic write_en,
    input logic read_en,
    input logic [3:0] addr,
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
localparam TX_ADDR      = 4'h0;
localparam RX_ADDR      = 4'h4;
localparam STATUS_ADDR  = 4'h8;
localparam CONTROL_ADDR = 4'hC;

logic [7:0] control_reg;
logic [7:0] status_reg;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        control_reg <= 0;
        tx_fifo_write <= 0;
        tx_fifo_wdata <= 0;
    end
    else begin
        tx_fifo_write <= 0;
        if (write_en) begin
            case (addr)
                TX_ADDR: begin
                    if (!tx_fifo_full) begin
                        tx_fifo_write <= 1;
                        tx_fifo_wdata <= wdata;
                    end
                end
                CONTROL_ADDR: begin
                    control_reg <= wdata;
                end
            endcase
        end
    end
end

always_ff @( posedge clk or negedge rst_n ) begin 
    if(!rst_n) begin
        rdata <= 0;
        rx_fifo_read <= 0;
    end
    else begin
        rx_fifo_read <= 0;
        if(read_en) begin
            case (addr)
                RX_ADDR: begin
                    if(!rx_fifo_empty) begin
                        rdata <= rx_fifo_rdata;
                        rx_fifo_read <= 1;
                    end
                    else rdata <= 0;
                end
                STATUS_ADDR: begin
                    rdata<= status_reg;
                end
                CONTROL_ADDR: begin
                    rdata <= control_reg;
                end 
                default: rdata <= 0;
            endcase
        end
    end
    
end

always_comb begin
    status_reg[0] = !rx_fifo_empty; //rx data available
    status_reg[1] = !tx_fifo_full; //tx fifo not full or ready to accept data
    status_reg[2] = parity_error;
    status_reg[7:3] = 0;
end

assign parity_enable = control_reg[2];
assign parity_odd = control_reg[3];

// control_reg[0] - rx interrupt enable
// control_reg[1] - tx interrupt enable

assign irq = (status_reg[0] && control_reg[0]) || (status_reg[1] && control_reg[1]) || (status_reg[2]);
    
endmodule