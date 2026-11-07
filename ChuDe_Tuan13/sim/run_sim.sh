#!/usr/bin/env bash
# Lab 6 - UART: bien dich va chay mo phong
#   ./sim/run_sim.sh          bien dich + chay
#   ./sim/run_sim.sh wave     mo waveform bang GTKWave
#   ./sim/run_sim.sh clean    xoa sim/out
set -u
cd "$(dirname "$0")/.." || exit 1

RTL="rtl/uart_tx.v rtl/uart_rx.v rtl/uart_top.v"
TB="tb/tb_uart.v"
OUT="sim/out"

case "${1:-run}" in

    run)
        mkdir -p "$OUT"
        echo "=== Bien dich ==="
        if ! iverilog -o "$OUT/tb_uart.vvp" -s tb_uart $RTL $TB; then
            echo ">>> LOI BIEN DICH"
            exit 1
        fi

        echo "=== Chay mo phong ==="
        vvp "$OUT/tb_uart.vvp" | tee "$OUT/tb_uart.log"
        rc=${PIPESTATUS[0]}

        echo
        if [ "$rc" -ne 0 ]; then
            echo ">>> vvp ket thuc bat thuong (ma thoat $rc)"
            exit 1
        fi
        if grep -q '\*\*\* TEST PASSED' "$OUT/tb_uart.log"; then
            echo ">>> KET QUA: PASSED   (log va VCD trong $OUT/)"
            exit 0
        else
            echo ">>> KET QUA: FAILED   (xem $OUT/tb_uart.log)"
            exit 1
        fi
        ;;

    wave)
        if [ ! -f "$OUT/tb_uart.vcd" ]; then
            echo "Chua co $OUT/tb_uart.vcd - chay ./sim/run_sim.sh truoc"
            exit 1
        fi
        gtkwave "$OUT/tb_uart.vcd" sim/wave_uart.gtkw &
        ;;

    clean)
        rm -rf "$OUT"
        echo "Da xoa $OUT"
        ;;

    *)
        echo "Dung: ./sim/run_sim.sh [run|wave|clean]"
        exit 1
        ;;

esac
