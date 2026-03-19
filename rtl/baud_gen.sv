module baud_gen #(
    parameter BAUD_RATE = 9600,
    parameter CLK_FREQ = 50000000
) (
    input clk,
    input rst_n,
    output logic baud_tick,
    output logic baud_16x_tick
);
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE; 
    localparam CLKS_PER_BIT_16X = CLK_FREQ / (BAUD_RATE * 16);
    logic [$clog2(CLKS_PER_BIT)-1:0] counter;
    logic [$clog2(CLKS_PER_BIT_16X)-1:0] counter_16x;

    always @(posedge clk or negedge rst_n) begin
       if (!rst_n) begin
            counter<=0;
            counter_16x<=0;
            baud_tick<=0;
            baud_16x_tick<=0;
       end 
       else begin
        if (counter == CLKS_PER_BIT-1) begin
            counter<=0;
            baud_tick<=1;
        end 
        else begin
            counter<=counter+1;
            baud_tick<=0;
        end

        if (counter_16x == CLKS_PER_BIT_16X-1) begin
            baud_16x_tick<=1;
            counter_16x<=0;
        end 
        else begin
            counter_16x<=counter_16x+1;
            baud_16x_tick<=0;           
        end
       end
    end

endmodule