`timescale 1ns / 1ps

module uart_tx #(
    parameter CLK_FREQ_HZ = 50000000,
    parameter BAUD_RATE   = 115200,
    parameter DATA_BITS   = 8,
    parameter STOP_BITS   = 1
) (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 tx_start,
    input  wire [DATA_BITS-1:0] tx_data,
    output reg                  tx,
    output reg                  tx_busy,
    output reg                  tx_done
);

    localparam DIVISOR = CLK_FREQ_HZ / BAUD_RATE;  // 434 chu ky clock / bit
    localparam IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;

    reg [1:0] state, next_state;
    reg  [         15:0] clk_cnt;
    reg  [          3:0] bit_idx;
    reg  [          3:0] stop_cnt;
    reg  [DATA_BITS-1:0] shreg;

    wire                 bit_done = (clk_cnt == DIVISOR - 1);
    wire                 last_bit = (bit_idx == DATA_BITS - 1);
    wire                 last_stop = (stop_cnt == STOP_BITS - 1);

    // (1) Thanh ghi trang thai
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // (2) Logic trang thai ke tiep
    always @(*) begin
        next_state = state;
        case (state)
            IDLE:    if (tx_start) next_state = START;
            START:   if (bit_done) next_state = DATA;
            DATA:    if (bit_done && last_bit) next_state = STOP;
            STOP:    if (bit_done && last_stop) next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // (3) Datapath va ngo ra
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx       <= 1'b1;
            tx_busy  <= 1'b0;
            tx_done  <= 1'b0;
            clk_cnt  <= 16'd0;
            bit_idx  <= 4'd0;
            stop_cnt <= 4'd0;
            shreg    <= {DATA_BITS{1'b0}};
        end else begin
            tx_done <= 1'b0;  // chi cao 1 chu ky clock
            case (state)
                IDLE: begin
                    tx      <= 1'b1;
                    tx_busy <= 1'b0;
                    clk_cnt <= 16'd0;
                    if (tx_start) begin
                        shreg   <= tx_data;
                        tx      <= 1'b0;  // phat START bit
                        tx_busy <= 1'b1;
                    end
                end
                START: begin
                    if (bit_done) begin
                        clk_cnt <= 16'd0;
                        tx      <= shreg[0];
                        shreg   <= shreg >> 1;
                        bit_idx <= 4'd0;
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
                DATA: begin
                    if (bit_done) begin
                        clk_cnt <= 16'd0;
                        if (last_bit) begin
                            tx       <= 1'b1;  // chuyen sang STOP bit
                            stop_cnt <= 4'd0;
                        end else begin
                            tx      <= shreg[0];
                            shreg   <= shreg >> 1;
                            bit_idx <= bit_idx + 1'b1;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
                STOP: begin
                    if (bit_done) begin
                        clk_cnt <= 16'd0;
                        if (last_stop) begin
                            tx_busy <= 1'b0;
                            tx_done <= 1'b1;
                        end else begin
                            stop_cnt <= stop_cnt + 1'b1;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
                default: begin
                    tx      <= 1'b1;
                    tx_busy <= 1'b0;
                    clk_cnt <= 16'd0;
                end
            endcase
        end
    end
endmodule
