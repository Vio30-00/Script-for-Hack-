@echo off
setlocal enabledelayedexpansion

echo ===============================
echo Extraindo senhas de redes Wi-Fi
echo ===============================

> senhas_wifi.txt (
    echo ===============================
    echo SENHAS DE REDES WI-FI SALVAS
    echo ===============================
)

:: Lista todos os perfis salvos
for /f "tokens=*" %%i in ('netsh wlan show profiles ^| findstr "Perfil de todos os usuários"') do (
    for /f "tokens=5,* delims=:" %%a in ("%%i") do (
        set "ssid=%%a"
        set "ssid=!ssid:~1!"
        echo.
        echo ============================== >> senhas_wifi.txt
        echo Rede: !ssid! >> senhas_wifi.txt
        netsh wlan show profile name="!ssid!" key=clear | findstr /C:"Conteúdo da chave" >> senhas_wifi.txt
    )
)

echo.
echo ✅ Tudo pronto! Veja o arquivo: senhas_wifi.txt
pause
