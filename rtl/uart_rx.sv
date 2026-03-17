module uart_rx (
    input clk,
    input rst_n,
    input rx,
    input baud_tick,
    output logic [7:0] data_out,
    output logic data_valid
);

    logic [7:0] shift_reg;
    logic [3:0] bit_count;
    typedef enum [1:0] {idle=2'b00, start=2'b01, data=2'b10, stop=2'b11} state_t;
    state_t state;

    always_ff @( posedge clk or negedge rst_n ) begin
        if (!rst_n) begin
            state <= idle;
            bit_count <= 0;
            shift_reg <= 0;
            data_out <= 0;
            data_valid <= 0;
        end

        else begin
            data_valid <= 0;
            if (baud_tick) begin
                case (state)
                    idle: begin
                        if (!rx) begin
                            state <= start;
                        end
                    end
                    start: begin
                        state <= data;
                        bit_count <= 0;
                    end
                    data: begin
                        shift_reg <= {rx, shift_reg[7:1]};
                        if (bit_count == 7) begin
                            state <= stop;
                            bit_count <= 0;
                        end
                        else begin
                            bit_count <= bit_count + 1;
                        end
                    end
                    stop: begin
                        if (rx) begin
                            data_out <= shift_reg;
                            data_valid <= 1;
                        end
                        state<=idle;
                    end
                    default: state <= idle;
                endcase
                
            end
        end
    end

endmodule