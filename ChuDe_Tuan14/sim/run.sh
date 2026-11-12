#!/usr/bin/env bash
#   ./sim/run.sh          bien dich + chay
#   ./sim/run.sh wave     mo waveform bang GTKWave
#   ./sim/run.sh clean    xoa sim/out
set -u
cd "$(dirname "$0")/.." || exit 1

RTL="rtl/debounce.v rtl/led_fsm.v rtl/top.v"
TB="tb/tb_top.v"
OUT="sim/out"

case "${1:-run}" in
    run)
        mkdir -p "$OUT"
        echo "=== Bien dich ==="
        if ! iverilog -o "$OUT/sim.vvp" -s tb_top $RTL $TB; then
            echo ">>> LOI BIEN DICH"
            exit 1
        fi
        echo "=== Chay mo phong ==="
        vvp "$OUT/sim.vvp" | tee "$OUT/sim.log"
        rc=${PIPESTATUS[0]}
        echo
        if [ "$rc" -ne 0 ]; then
            echo ">>> vvp ket thuc bat thuong (ma thoat $rc)"
            exit 1
        fi
        if grep -q '\*\*\* TEST PASSED' "$OUT/sim.log"; then
            echo ">>> KET QUA: PASSED   (log va VCD trong $OUT/)"
            exit 0
        else
            echo ">>> KET QUA: FAILED   (xem $OUT/sim.log)"
            exit 1
        fi
        ;;
    wave)
        if [ ! -f "$OUT/waveform.vcd" ]; then
            echo "Chua co $OUT/waveform.vcd - chay ./sim/run.sh truoc"
            exit 1
        fi
        gtkwave "$OUT/waveform.vcd" sim/wave.gtkw &
        ;;

    clean)
        rm -rf "$OUT"
        echo "Da xoa $OUT"
        ;;
    *)
        echo "Dung: ./sim/run.sh [run|wave|clean]"
        exit 1
        ;;
esac
