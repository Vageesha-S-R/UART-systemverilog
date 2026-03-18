module baud_gen #(
    parameter BAUD_RATE = 9600,
    parameter CLK_FREQ = 50000000
) (
    input clk,
    input rst_n,
    output logic baud_tick
);
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    logic [$clog2(CLKS_PER_BIT)-1:0] counter;

    always @(posedge clk or negedge rst_n) begin
       if (!rst_n) begin
            counter<=0;
            baud_tick<=0;
       end else begin
        if (counter==CLKS_PER_BIT-1) begin
            counter<=0;
            baud_tick<=1;
        end else begin
            counter<=counter+1;
            baud_tick<=0;           
        end
       end
    end

endmodule