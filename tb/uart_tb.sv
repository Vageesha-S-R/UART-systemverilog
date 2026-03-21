module uart_tb ();

logic clk;
logic rst_n;

logic wb_cyc;
logic wb_stb;
logic wb_we;
logic [3:0] wb_addr;
logic [7:0] wb_wdata;
logic [7:0] wb_rdata;
logic wb_ack;

logic irq;

uart_wb #(
    .BAUD_RATE(9600),
    .CLK_FREQ(50000000)
) uart_wb_inst (
    .clk(clk),
    .rst_n(rst_n),
    .wb_cyc(wb_cyc),
    .wb_stb(wb_stb),
    .wb_we(wb_we),
    .wb_addr(wb_addr),
    .wb_wdata(wb_wdata),
    .wb_rdata(wb_rdata),
    .wb_ack(wb_ack),
    .irq(irq)
);

initial begin
    clk=0;
end

always #10 clk = ~clk; // 50MHz clock

initial begin
    rst_n = 0;
    wb_cyc = 0;
    wb_stb = 0;
    wb_we = 0;
    wb_addr = 0;
    wb_wdata = 0;
    #100;
    rst_n = 1;
end

task wb_write(input [3:0] addr, input [7:0] data);
    begin
        @(posedge clk);
        wb_addr <= addr;
        wb_wdata <= data;
        wb_we <= 1;
        wb_cyc <= 1;
        wb_stb <= 1;

        @(posedge clk);
        wait(wb_ack);

        wb_cyc <= 0;
        wb_stb <= 0;
        wb_we <= 0;
    end
endtask

task wb_read(input [3:0] addr);
    begin
       @(posedge clk);
        wb_addr <= addr;
        wb_we <= 0;
        wb_cyc <= 1;
        wb_stb <= 1;

        @(posedge clk);
        wait(wb_ack);

        $display("Read from address %0h: %0h", addr, wb_rdata);

        wb_cyc <= 0;
        wb_stb <= 0;
    end
endtask

initial begin
    wait(rst_n);

    wb_write(4'hC, 8'h01); 

    wb_write(4'h0, 8'hA5);

    #200000;

    wb_read(4'h8);

    wb_read(4'h4);

    if(irq) 
        $display("IRQ is asserted");
    else
        $display("IRQ is not asserted");

    #1000;
    $finish;


end

initial begin
    $dumpfile("uart_tb.vcd");
    $dumpvars(0, uart_tb);
end

    
endmodule