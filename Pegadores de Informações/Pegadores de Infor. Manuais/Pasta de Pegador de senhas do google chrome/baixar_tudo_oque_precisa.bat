@echo off
setlocal

set "PYSCRIPTS=%APPDATA%\Python\Python312\Scripts"

echo Tirando erros...
where pip >nul 2>&1
if %errorlevel% NEQ 0 (
    echo PIP não encontrado. Instalando...
    curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py
    python get-pip.py
    del get-pip.py
) else (
    echo PIP já está instalado.
)

echo Adicionando %PYSCRIPTS% ao PATH se necessário...
reg query "HKCU\Environment" | findstr /C:"%PYSCRIPTS%" >nul
if %errorlevel%==1 (
    setx PATH "%PATH%;%PYSCRIPTS%"
    echo Caminho adicionado. Reinicie o PC ou reabra o terminal para aplicar.
)

echo Instalando dependências...
pip install --user pywin32 pycryptodome pycryptodomex
echo Tudo instalado!

pause
