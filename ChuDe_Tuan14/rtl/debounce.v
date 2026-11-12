`timescale 1ns/1ps

module debounce #(
    parameter WAIT_CYCLES = 500000 // 10 ms @ 50 MHz, testbench ghi đè số nhỏ hơn
)(
    input wire clk,
    input wire rst_n,
    input wire btn_in,
    output reg btn_tick // Xung kích báo hiệu đã nhấn nút thành công
);
    reg sync_0, sync_1;
    reg btn_state;
    reg [$clog2(WAIT_CYCLES)-1:0] count;

    // Chống Metastability
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_0 <= 1'b0;
            sync_1 <= 1'b0;
        end else begin
            sync_0 <= btn_in;
            sync_1 <= sync_0;
        end
    end

    // Mạch đếm chống dội
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            btn_state <= 1'b0;
            btn_tick <= 1'b0;
        end else begin
            btn_tick <= 1'b0; // Mặc định là không có xung
            if (sync_1 != btn_state) begin
                count <= count + 1;
                if (count == WAIT_CYCLES - 1) begin
                    btn_state <= sync_1;
                    count <= 0;
                    if (sync_1 == 1'b1) btn_tick <= 1'b1; // Tạo xung khi nhấn
                end
            end else begin
                count <= 0;
            end
        end
    end
endmodule
