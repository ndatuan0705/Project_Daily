`timescale 1ns/1ps

module top #(
    parameter WAIT_CYCLES = 500000 // 10 ms @ 50 MHz
)(
    input wire clk,
    input wire rst_n,
    input wire btn_in,
    output wire [2:0] led
);
    wire btn_tick;

    // Gọi module debounce
    debounce #(.WAIT_CYCLES(WAIT_CYCLES)) u_debounce (
        .clk(clk),
        .rst_n(rst_n),
        .btn_in(btn_in),
        .btn_tick(btn_tick)
    );

    // Gọi module FSM
    led_fsm u_fsm (
        .clk(clk),
        .rst_n(rst_n),
        .btn_tick(btn_tick),
        .led(led)
    );
endmodule
