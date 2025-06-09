@echo off
setlocal enabledelayedexpansion

echo Usuario Registrado: %USERNAME% > oo-o34.txt
echo Local do Arquivo (script.txt) Registrado: %CD% >> oo-o34.txt

set "ip="
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    set "ip=%%a"
)

if defined ip (
    call echo IP Registrado: %%ip:~1%% >> oo-o34.txt
) else (
    echo IP Registrado: Não encontrado >> oo-o34.txt
)

echo MACs Registrados: >> oo-o34.txt
for /f "tokens=1 delims=," %%m in ('getmac /fo csv ^| findstr /r "[0-9A-Fa-f][0-9A-Fa-f]-[0-9A-Fa-f][0-9A-Fa-f]-[0-9A-Fa-f][0-9A-Fa-f]-[0-9A-Fa-f][0-9A-Fa-f]-[0-9A-Fa-f][0-9A-Fa-f]-[0-9A-Fa-f][0-9A-Fa-f]"') do (
    echo %%~m >> oo-o34.txt
)

echo Hora Registrada: %TIME% >> oo-o34.txt
echo Data Registrada: %DATE% >> oo-o34.txt

endlocal
