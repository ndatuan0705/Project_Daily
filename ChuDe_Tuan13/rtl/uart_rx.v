`timescale 1ns / 1ps

module uart_rx #(
    parameter CLK_FREQ_HZ = 50000000,
    parameter BAUD_RATE   = 115200,
    parameter DATA_BITS   = 8
) (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 rx,
    output reg  [DATA_BITS-1:0] rx_data,
    output reg                  rx_valid,
    output reg                  rx_busy,
    output reg                  frame_err
);

    localparam DIVISOR = CLK_FREQ_HZ / BAUD_RATE;  // 434 chu ky clock / bit
    localparam HALF_BIT = DIVISOR / 2;  // 217

    localparam IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;

    reg [1:0] state, next_state;
    reg [         15:0] clk_cnt;
    reg [          3:0] bit_idx;
    reg [DATA_BITS-1:0] shreg;

    // Dong bo chan rx bang 2 flip-flop de chong metastability
    reg rx_ff1, rx_ff2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_ff1 <= 1'b1;
            rx_ff2 <= 1'b1;
        end else begin
            rx_ff1 <= rx;
            rx_ff2 <= rx_ff1;
        end
    end

    wire rx_sync = rx_ff2;
    wire half_done = (clk_cnt == HALF_BIT - 1);
    wire bit_done = (clk_cnt == DIVISOR - 1);
    wire last_bit = (bit_idx == DATA_BITS - 1);

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
            IDLE:    if (tx_start)              next_state = START;
            START:   if (bit_done)              next_state = DATA;
            DATA:    if (bit_done && last_bit)  next_state = STOP;
            STOP:    if (bit_done && last_stop) next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // (3) Datapath va ngo ra
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_cnt   <= 16'd0;
            bit_idx   <= 4'd0;
            shreg     <= {DATA_BITS{1'b0}};
            rx_data   <= {DATA_BITS{1'b0}};
            rx_valid  <= 1'b0;
            rx_busy   <= 1'b0;
            frame_err <= 1'b0;
        end else begin
            rx_valid <= 1'b0;  // chi cao 1 chu ky clock

            case (state)

                IDLE: begin
                    clk_cnt <= 16'd0;
                    rx_busy <= 1'b0;
                    if (rx_sync == 1'b0) begin
                        rx_busy   <= 1'b1;
                        frame_err <= 1'b0;
                    end
                end
                START: begin
                    if (half_done) begin
                        clk_cnt <= 16'd0;
                        if (rx_sync == 1'b0) begin
                            bit_idx <= 4'd0;  // tu day moi lan dem du
                        end                            // 1 bit la mot diem lay mau
                        else begin
                            rx_busy <= 1'b0;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
                DATA: begin
                    if (bit_done) begin
                        clk_cnt <= 16'd0;
                        shreg   <= {rx_sync, shreg[DATA_BITS-1:1]};  // LSB den truoc
                        if (!last_bit) begin
                            bit_idx <= bit_idx + 1'b1;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
                STOP: begin
                    if (bit_done) begin
                        clk_cnt   <= 16'd0;
                        rx_data   <= shreg;
                        rx_valid  <= 1'b1;
                        rx_busy   <= 1'b0;
                        frame_err <= ~rx_sync;  // STOP bit phai bang '1'
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
                default: begin
                    clk_cnt <= 16'd0;
                    rx_busy <= 1'b0;
                end
            endcase
        end
    end
endmodule
