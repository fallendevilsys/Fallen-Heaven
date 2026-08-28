$exe = Join-Path $PSScriptRoot "Fallen-Heaven Discord App.exe"
if (-not (Test-Path -LiteralPath $exe)) { throw "App-EXE nicht gefunden: $exe" }
Start-Process -FilePath $exe -WorkingDirectory $PSScriptRoot
