module uart_wb #( 
    parameter BAUD_RATE = 9600,
    parameter CLK_FREQ = 50000000
)(
    input logic clk,
    input logic rst_n,

    input logic wb_cyc,
    input logic wb_stb,
    input logic wb_we,
    input logic [3:0] wb_addr,
    input logic [7:0] wb_wdata,
    output logic [7:0] wb_rdata,
    output logic wb_ack,

    output logic irq
);

logic write_en;
logic read_en;
logic [3:0] addr;
logic [7:0] wdata;
logic [7:0] rdata;

logic [1:0] read_delay;

assign write_en = wb_cyc && wb_stb && wb_we;
assign read_en = wb_cyc && wb_stb && !wb_we;

assign addr = wb_addr;
assign wdata = wb_wdata;
assign wb_rdata = rdata;

always_ff @( posedge clk or negedge rst_n ) begin 
    if (!rst_n) begin
        wb_ack <= 0;
    end
    else begin
        wb_ack <= 0;
        if (wb_cyc && wb_stb && wb_we) begin
            wb_ack <=1;
        end

        else if(wb_cyc && wb_stb && !wb_we) begin
            read_delay <= 2;
        end

        if(read_delay != 0) begin
            read_delay <= read_delay - 1;
            
            if(read_delay == 1) begin
                wb_ack <= 1;
            end
        end

    end
    
end

uart_top #(
    .BAUD_RATE(BAUD_RATE),
    .CLK_FREQ(CLK_FREQ)
) uart_top_inst (
    .clk(clk),
    .rst_n(rst_n),
    .write_en(write_en),
    .read_en(read_en),
    .addr(addr),
    .wdata(wdata),
    .rdata(rdata),
    .irq(irq)
);
    
endmodule