# Lab 6 - UART: chay bang  make -f sim/uart.mk [all|wave|clean]

ROOT := $(dir $(lastword $(MAKEFILE_LIST)))..
RTL  := rtl/uart_tx.v rtl/uart_rx.v rtl/uart_top.v
TB   := tb/tb_uart.v
OUT  := sim/out

.PHONY: all wave clean

all:
	@mkdir -p $(ROOT)/$(OUT)
	cd $(ROOT) && iverilog -o $(OUT)/tb_uart.vvp -s tb_uart $(RTL) $(TB)
	cd $(ROOT) && vvp $(OUT)/tb_uart.vvp | tee $(OUT)/tb_uart.log

wave:
	cd $(ROOT) && gtkwave $(OUT)/tb_uart.vcd sim/wave_uart.gtkw &

clean:
	rm -rf $(ROOT)/$(OUT)
	@echo "Da xoa $(OUT)"
