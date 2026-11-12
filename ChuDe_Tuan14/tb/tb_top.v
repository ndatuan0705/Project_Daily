`timescale 1ns/1ps

module tb_top;

    localparam WAIT = 5; // Rút ngắn cửa sổ chống dội cho mô phỏng

    reg clk;
    reg rst_n;
    reg btn_in;
    wire [2:0] led;

    integer so_loi;

    top #(.WAIT_CYCLES(WAIT)) u_top (
        .clk(clk),
        .rst_n(rst_n),
        .btn_in(btn_in),
        .led(led)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Nhấn nút một lần rồi kiểm tra LED
    task nhan_nut(input [2:0] mong_doi);
        begin
            @(posedge clk); #1;
            btn_in = 1'b1;
            #100;
            @(posedge clk); #1;
            btn_in = 1'b0;
            #100;
            if (led === mong_doi) begin
                $display("[%7.1f ns] PASS | led = %b", $realtime, led);
            end
            else begin
                so_loi = so_loi + 1;
                $display("[%7.1f ns] FAIL | led = %b, mong doi %b", $realtime, led, mong_doi);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/out/waveform.vcd");
        $dumpvars(0, tb_top);

        so_loi = 0;
        rst_n  = 1'b0;
        btn_in = 1'b0;
        #20;
        rst_n = 1'b1;

        $display("TESTBENCH NUT NHAN + LED  (WAIT_CYCLES = %0d)", WAIT);

        // Nhieu 10 ns truoc lan nhan dau tien, mach chong doi phai bo qua
        @(posedge clk); #1;
        btn_in = 1'b1;
        #10;
        btn_in = 1'b0;
        #10;

        nhan_nut(3'b001);
        nhan_nut(3'b011);
        nhan_nut(3'b111);
        nhan_nut(3'b000);

        if (so_loi == 0) begin
            $display("*** TEST PASSED : 4/4 ***");
        end
        else begin
            $display("*** TEST FAILED : %0d/4 ***", 4 - so_loi);
        end

        $finish;
    end

    initial begin
        #10000;
        $display("*** TEST FAILED : timeout ***");
        $finish;
    end

endmodule
