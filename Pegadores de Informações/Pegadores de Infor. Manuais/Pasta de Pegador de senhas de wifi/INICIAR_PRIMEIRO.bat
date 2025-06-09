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

:: Captura só os nomes das redes Wi-Fi salvas corretamente
for /f "tokens=1,* delims=:" %%a in ('netsh wlan show profiles ^| findstr "Todos os Perfis de Usuários"') do (
    set "ssid=%%b"
    set "ssid=!ssid:~1!" 
    echo ============================== >> senhas_wifi.txt
    echo Rede: !ssid! >> senhas_wifi.txt
    netsh wlan show profile name="!ssid!" key=clear | findstr "Conteúdo da chave" >> senhas_wifi.txt
)

echo.
echo ✅ Tudo pronto! Veja o arquivo: senhas_wifi.txt
pause
