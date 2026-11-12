@echo off
REM   sim\run.bat          bien dich + chay
REM   sim\run.bat wave     mo waveform bang GTKWave
REM   sim\run.bat clean    xoa sim\out
setlocal
cd /d "%~dp0.."

set RTL=rtl\debounce.v rtl\led_fsm.v rtl\top.v
set TB=tb\tb_top.v
set OUT=sim\out

set TARGET=%~1
if "%TARGET%"=="" set TARGET=run

if /i "%TARGET%"=="wave"  goto WAVE
if /i "%TARGET%"=="clean" goto CLEAN
if /i "%TARGET%"=="run"   goto RUN

echo Dung: sim\run.bat [run^|wave^|clean]
exit /b 1

:CLEAN
if exist "%OUT%" rmdir /s /q "%OUT%"
echo Da xoa %OUT%
exit /b 0

:WAVE
if not exist "%OUT%\waveform.vcd" (
    echo Chua co %OUT%\waveform.vcd - chay sim\run.bat truoc
    exit /b 1
)
start "" gtkwave "%OUT%\waveform.vcd" sim\wave.gtkw
exit /b 0

:RUN
if not exist "%OUT%" mkdir "%OUT%"

echo === Bien dich ===
iverilog -o "%OUT%\sim.vvp" -s tb_top %RTL% %TB%
if errorlevel 1 (
    echo ^>^>^> LOI BIEN DICH
    exit /b 1
)

echo === Chay mo phong ===
vvp "%OUT%\sim.vvp" > "%OUT%\sim.log" 2>&1
set VVPRC=%errorlevel%
type "%OUT%\sim.log"

echo.
if not "%VVPRC%"=="0" (
    echo ^>^>^> vvp ket thuc bat thuong ^(ma thoat %VVPRC%^)
    exit /b 1
)
findstr /C:"*** TEST PASSED" "%OUT%\sim.log" >nul 2>nul
if errorlevel 1 (
    echo ^>^>^> KET QUA: FAILED   ^(xem %OUT%\sim.log^)
    exit /b 1
)
echo ^>^>^> KET QUA: PASSED   ^(log va VCD trong %OUT%\^)
exit /b 0
