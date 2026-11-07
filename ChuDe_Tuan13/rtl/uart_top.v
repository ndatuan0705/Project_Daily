`timescale 1ns / 1ps

module uart_top #(
    parameter CLK_FREQ_HZ = 50000000,
    parameter BAUD_RATE   = 115200,
    parameter DATA_BITS   = 8,
    parameter STOP_BITS   = 1
)(
    input  wire                 clk,
    input  wire                 rst_n,

    input  wire                 tx_start,
    input  wire [DATA_BITS-1:0] tx_data,
    output wire                 tx_busy,
    output wire                 tx_done,
    output wire                 uart_txd,

    input  wire                 uart_rxd,
    output wire [DATA_BITS-1:0] rx_data,
    output wire                 rx_valid,
    output wire                 rx_busy,
    output wire                 frame_err
);

    uart_tx #(
        .CLK_FREQ_HZ (CLK_FREQ_HZ),
        .BAUD_RATE   (BAUD_RATE),
        .DATA_BITS   (DATA_BITS),
        .STOP_BITS   (STOP_BITS)
    ) u_tx (
        .clk (clk), .rst_n (rst_n),
        .tx_start (tx_start), .tx_data (tx_data),
        .tx (uart_txd), .tx_busy (tx_busy), .tx_done (tx_done)
    );

    // uart_rx khong can STOP_BITS: chi kiem tra stop bit dau tien roi ve IDLE,
    // duong truyen van o muc '1' trong cac stop bit con lai.
    uart_rx #(
        .CLK_FREQ_HZ (CLK_FREQ_HZ),
        .BAUD_RATE   (BAUD_RATE),
        .DATA_BITS   (DATA_BITS)
    ) u_rx (
        .clk (clk), .rst_n (rst_n),
        .rx (uart_rxd),
        .rx_data (rx_data), .rx_valid (rx_valid),
        .rx_busy (rx_busy), .frame_err (frame_err)
    );

endmodule
