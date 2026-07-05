Set-Location "c:\Users\ASUS\EventKuy"
$result = & flutter analyze --no-pub 2>&1
$result | Out-File -FilePath "c:\Users\ASUS\EventKuy\flutter_errors.txt" -Encoding UTF8
Write-Host "Flutter analyze completed. Results saved to flutter_errors.txt"
