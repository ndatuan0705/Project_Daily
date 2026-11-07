`timescale 1ns / 1ps

module tb_uart;

    localparam CLK_FREQ_HZ = 50000000;
    localparam BAUD_RATE   = 115200;
    localparam DATA_BITS   = 8;
    localparam STOP_BITS   = 1;

    localparam CLK_NS  = 1000000000 / CLK_FREQ_HZ;     // 20 ns
    localparam DIVISOR = CLK_FREQ_HZ / BAUD_RATE;      // 434 clk / bit
    localparam BIT_NS  = DIVISOR * CLK_NS;             // 8680 ns

    reg                  clk      = 1'b0;
    reg                  rst_n    = 1'b0;
    reg                  tx_start = 1'b0;
    reg  [DATA_BITS-1:0] tx_data  = 8'h00;
    wire                 uart_line, tx_busy, tx_done;
    wire [DATA_BITS-1:0] rx_data;
    wire                 rx_valid, rx_busy, frame_err;

    integer err = 0;
    integer num = 0;

    uart_top #(
        .CLK_FREQ_HZ (CLK_FREQ_HZ), .BAUD_RATE (BAUD_RATE),
        .DATA_BITS   (DATA_BITS),   .STOP_BITS (STOP_BITS)
    ) dut (
        .clk (clk), .rst_n (rst_n),
        .tx_start (tx_start), .tx_data (tx_data),
        .tx_busy (tx_busy), .tx_done (tx_done),
        .uart_txd (uart_line),
        .uart_rxd (uart_line),           // noi vong TXD -> RXD
        .rx_data (rx_data), .rx_valid (rx_valid),
        .rx_busy (rx_busy), .frame_err (frame_err)
    );

    always #(CLK_NS/2) clk = ~clk;

    // Gui 1 byte, giai ma khung tren duong truyen, roi doi ca hai phia:
    //   got     = du lieu doc duoc tu duong truyen (kiem tra bo truyen)
    //   rx_data = du lieu bo nhan giai ma (kiem tra bo nhan)
    task run_test(input [DATA_BITS-1:0] d);
        integer i;
        reg [DATA_BITS-1:0] got;
        begin
            num = num + 1;

            @(posedge clk); #1;
            tx_data  = d;
            tx_start = 1'b1;
            @(posedge clk); #1;          // DUT lay mau -> START bit bat dau
            tx_start = 1'b0;

            #(BIT_NS/2 - 1);             // di den giua START bit
            if (uart_line !== 1'b0) begin
                err = err + 1;
                $display("[%t] FAIL | START bit = %b, mong doi 0", $time, uart_line);
            end

            for (i = 0; i < DATA_BITS; i = i + 1) begin
                #(BIT_NS);               // di den giua bit du lieu thu i
                got[i] = uart_line;      // LSB den truoc
            end

            #(BIT_NS);                   // di den giua STOP bit
            if (uart_line !== 1'b1) begin
                err = err + 1;
                $display("[%t] FAIL | STOP bit = %b, mong doi 1", $time, uart_line);
            end

            wait (tx_busy == 1'b0);
            repeat (5) @(posedge clk);

            if (got === d && rx_data === d && frame_err === 1'b0) begin
                $display("[%t] PASS | gui 0x%02h -> duong truyen 0x%02h -> nhan 0x%02h",
                         $time, d, got, rx_data);
            end
            else begin
                err = err + 1;
                $display("[%t] FAIL | gui 0x%02h -> duong truyen 0x%02h -> nhan 0x%02h | frame_err = %b",
                         $time, d, got, rx_data, frame_err);
            end

            repeat (20) @(posedge clk);
        end
    endtask

    initial begin
        $timeformat(-9, 1, " ns", 12);
        $dumpfile("sim/out/tb_uart.vcd");
        $dumpvars(0, tb_uart);

        $display("TESTBENCH UART  (uart_top, TXD noi vong ve RXD)");
        $display("clk %0d Hz | baud %0d | %0d bit du lieu | %0d stop bit | 1 bit = %0d clk = %0d ns",
                 CLK_FREQ_HZ, BAUD_RATE, DATA_BITS, STOP_BITS, DIVISOR, BIT_NS);

        rst_n = 1'b0;
        repeat (10) @(posedge clk); #1;
        rst_n = 1'b1;
        repeat (5)  @(posedge clk);

        run_test(8'h55);                 // 0101_0101, bit doi dau lien tuc
        run_test(8'hAA);                 // 1010_1010, dao nguoc cua 0x55
        run_test(8'h00);                 // bien: toan 0, STOP bit van phai la 1
        run_test(8'h41);                 // ky tu 'A'

        if (err == 0) $display("*** TEST PASSED : %0d/%0d ***", num, num);
        else          $display("*** TEST FAILED : %0d/%0d ***", err, num);
        $finish;
    end

    initial begin
        #1000000;
        $display("*** TEST FAILED : timeout ***");
        $finish;
    end

endmodule
