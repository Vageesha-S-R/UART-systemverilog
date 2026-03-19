module uart_rx (
    input clk,
    input rst_n,
    input rx,
    input baud_16x_tick,
    input logic parity_enable,
    input logic parity_odd,
    output logic [7:0] data_out,
    output logic data_valid,
    output logic parity_error
);

    logic [7:0] shift_reg;
    logic [3:0] bit_count;
    logic [3:0] sample_count;
    typedef enum logic[2:0] {idle=3'b000, start=3'b001, data=3'b010, parity=3'b011, stop=3'b100} state_t;
    state_t state;

    always_ff @( posedge clk or negedge rst_n ) begin
        if (!rst_n) begin
            state <= idle;
            bit_count <= 0;
            shift_reg <= 0;
            data_out <= 0;
            data_valid <= 0;
            parity_error <= 0;
            sample_count <= 0;
        end

        else begin
            data_valid <= 0;
            parity_error <= 0;
            if (baud_16x_tick) begin
                if(sample_count == 15) begin
                    sample_count <= 0;
                end
                else begin
                    sample_count <= sample_count + 1;
                end
                case (state)
                    idle: begin
                        if (!rx) begin
                            state <= start;
                        end
                    end
                    start: begin
                        if (sample_count == 8) begin
                            if (!rx) begin
                                state <= data;
                                bit_count <= 0;
                                sample_count <= 0;
                            end
                            else begin
                                state <= idle;
                            end
                        end
                    end
                    data: begin
                        if (sample_count == 8) begin
                            shift_reg <= {rx, shift_reg[7:1]};

                            if (bit_count == 7) begin
                                bit_count <= 0;
                                if (parity_enable) begin
                                    state <= parity;
                                end
                                else begin
                                    state <= stop;
                                end
                            end
                            else begin
                                bit_count <= bit_count + 1;
                            end
                        end
                    end
                    parity: begin
                        if (sample_count == 8) begin
                            parity_error <= ((parity_odd ? ~(^shift_reg) : (^shift_reg)) != rx);
                            state <= stop;
                        end 
                    end
                    stop: begin
                        if (sample_count == 8) begin
                            if (rx) begin
                                data_out <= shift_reg;
                                data_valid <= 1;
                            end
                            state<=idle;
                        end
                    end
                    default: state <= idle;
                endcase
                
            end
        end
    end

endmodule