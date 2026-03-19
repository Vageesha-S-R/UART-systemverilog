module uart_tx (
    input clk,
    input rst_n,
    input logic [7:0] data_in,
    input logic baud_tick,
    input logic data_valid,
    input logic parity_enable,
    input logic parity_odd,
    output logic tx,
    output logic busy
);

logic [7:0] shift_reg;
logic [3:0] bit_count;
logic parity_bit;
typedef enum logic[2:0]{idle=3'b000, start=3'b001, data=3'b010, parity=3'b011, stop=3'b100} state_t;
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
                        parity_bit<=parity_odd ? ~(^data_in) : (^data_in);
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
                        if (parity_enable) begin
                            state<=parity;
                        end
                        else begin
                            state<=stop;
                        end
                    end
                    else begin
                        tx<=shift_reg[0];
                        shift_reg<=shift_reg>>1;
                        bit_count<=bit_count+1;
                    end
                end
                parity: begin
                    tx<=parity_bit;
                    state<=stop;
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

