module fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input logic clk,
    input logic rst_n,
    input logic write_en,
    input logic read_en,
    input logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out,
    output logic empty,
    output logic full
);

    logic [WIDTH-1:0] mem[DEPTH-1:0];
    logic [$clog2(DEPTH)-1:0] write_ptr;
    logic [$clog2(DEPTH)-1:0] read_ptr;
    logic [$clog2(DEPTH):0] count;

    assign empty = (count == 0);
    assign full = (count == DEPTH);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_ptr <=0;
            read_ptr <=0;
            count <=0;
        end 
        else begin
            if (write_en && !full) begin
                mem[write_ptr] <= data_in;
                write_ptr <= write_ptr + 1;
            end
            if (read_en && !empty) begin
                data_out <= mem[read_ptr];
                read_ptr <= read_ptr + 1;
            end
            case ({write_en && !full, read_en && !empty})
                2'b10:count <= count + 1;
                2'b01:count <= count - 1; 
                default: count <= count;
            endcase
        end
        end
    
endmodule