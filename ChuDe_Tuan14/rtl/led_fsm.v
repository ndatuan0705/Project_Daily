`timescale 1ns/1ps

module led_fsm (
    input wire clk,
    input wire rst_n,
    input wire btn_tick,
    output reg [2:0] led
);
    // Định nghĩa các trạng thái
    localparam OFF  = 2'b00;
    localparam LED1 = 2'b01;
    localparam LED2 = 2'b10;
    localparam LED3 = 2'b11;

    reg [1:0] state, next_state;

    // Chuyển trạng thái
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= OFF;
        else state <= next_state;
    end

    // Logic xác định trạng thái tiếp theo
    always @(*) begin
        next_state = state;
        if (btn_tick) begin
            case (state)
                OFF:  next_state = LED1;
                LED1: next_state = LED2;
                LED2: next_state = LED3;
                LED3: next_state = OFF;
                default: next_state = OFF;
            endcase
        end
    end

    // Logic đầu ra điều khiển LED
    always @(*) begin
        case (state)
            OFF:  led = 3'b000;
            LED1: led = 3'b001; // Sáng 1 LED
            LED2: led = 3'b011; // Sáng 2 LED
            LED3: led = 3'b111; // Sáng 3 LED
            default: led = 3'b000;
        endcase
    end
endmodule
