"Usuario Registrado: $env:USERNAME" | Out-File -Encoding UTF8 gps.txt
Add-Type -AssemblyName System.Device
$sensor = [System.Device.Location.GeoCoordinateWatcher]::new()
$sensor.Start()
Start-Sleep -Seconds 5
$location = $sensor.Position.Location
if ($location.IsUnknown) {
    "Localização desconhecida" | Out-File -Encoding UTF8 -Append gps.txt
} else {
    "Latitude: $($location.Latitude)`nLongitude: $($location.Longitude)" | Out-File -Encoding UTF8 -Append gps.txt
}
$sensor.Stop()
