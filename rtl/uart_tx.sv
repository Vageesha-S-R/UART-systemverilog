module uart_tx (
    input clk,
    input rst_n,
    input logic [7:0] data_in,
    input logic baud_tick,
    input logic data_valid,
    output logic tx,
    output logic busy
);

logic [7:0] shift_reg;
logic [3:0] bit_count;
typedef enum logic[1:0]{idle=2'b00, start=2'b01, data=2'b10, stop=2'b11} state_t;
state_t state;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        state<=idle;
        bit_count<=0;
        shift_reg<=0;
        tx<=1;
        busy<=0;
    end
    else begin
        if (baud_tick) begin
            case (state)
                idle: begin
                    tx<=1;
                    busy<=0;
                    if (data_valid) begin
                        shift_reg<=data_in;
                        state<=start;
                        busy<=1;
                    end
                end
                start: begin
                    tx<=0;
                    state<=data;
                end
                data: begin
                    if (bit_count==7) begin
                        tx<=shift_reg[0];
                        shift_reg<=shift_reg>>1;
                        bit_count<=0;
                        state<=stop;
                    end
                    else begin
                        tx<=shift_reg[0];
                        shift_reg<=shift_reg>>1;
                        bit_count<=bit_count+1;
                    end
                end
                stop: begin
                    tx<=1;
                    busy<=0;
                    state<=idle;
                end
                default: state<=idle;
            endcase            
        end
    end
end
    
endmodule

