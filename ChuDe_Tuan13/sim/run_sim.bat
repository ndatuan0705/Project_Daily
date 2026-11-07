@echo off
REM Lab 6 - UART: bien dich va chay mo phong tren Windows
REM   sim\run_sim.bat          bien dich + chay
REM   sim\run_sim.bat wave     mo waveform bang GTKWave
REM   sim\run_sim.bat clean    xoa sim\out
setlocal
cd /d "%~dp0.."

set RTL=rtl\uart_tx.v rtl\uart_rx.v rtl\uart_top.v
set TB=tb\tb_uart.v
set OUT=sim\out

set TARGET=%~1
if "%TARGET%"=="" set TARGET=run

if /i "%TARGET%"=="wave"  goto WAVE
if /i "%TARGET%"=="clean" goto CLEAN
if /i "%TARGET%"=="run"   goto RUN

echo Dung: sim\run_sim.bat [run^|wave^|clean]
exit /b 1

:CLEAN
if exist "%OUT%" rmdir /s /q "%OUT%"
echo Da xoa %OUT%
exit /b 0

:WAVE
if not exist "%OUT%\tb_uart.vcd" (
    echo Chua co %OUT%\tb_uart.vcd - chay sim\run_sim.bat truoc
    exit /b 1
)
start "" gtkwave "%OUT%\tb_uart.vcd" "sim\wave_uart.gtkw"
exit /b 0

:RUN
if not exist "%OUT%" mkdir "%OUT%"

echo === Bien dich ===
iverilog -o "%OUT%\tb_uart.vvp" -s tb_uart %RTL% %TB%
if errorlevel 1 (
    echo ^>^>^> LOI BIEN DICH
    exit /b 1
)

echo === Chay mo phong ===
vvp "%OUT%\tb_uart.vvp" > "%OUT%\tb_uart.log" 2>&1
set VVPRC=%errorlevel%
type "%OUT%\tb_uart.log"

echo.
if not "%VVPRC%"=="0" (
    echo ^>^>^> vvp ket thuc bat thuong ^(ma thoat %VVPRC%^)
    exit /b 1
)
findstr /C:"*** TEST PASSED" "%OUT%\tb_uart.log" >nul 2>nul
if errorlevel 1 (
    echo ^>^>^> KET QUA: FAILED   ^(xem %OUT%\tb_uart.log^)
    exit /b 1
)
echo ^>^>^> KET QUA: PASSED   ^(log va VCD trong %OUT%\^)
exit /b 0
