<#
.SYNOPSIS
  Gera os instaladores Windows a partir de `flutter build windows --release`:
    build\installer\LostTheGame-Setup.exe     Inno Setup, por utilizador
    build\installer\LostTheGame-Windows.msi   WiX 5, para todos os utilizadores
  Nomes fixos (sem versão): o README liga a releases/latest/download/<nome>.

.EXAMPLE
  flutter build windows --release --build-name=0.1.0
  powershell -ExecutionPolicy Bypass -File windows\installer\build-installers.ps1 -Version 0.1.0
#>
param(
  # Versão da app (pode ter sufixo, ex.: 0.2.0-beta.1).
  [Parameter(Mandatory = $true)][string]$Version
)

$ErrorActionPreference = 'Stop'

$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$release = Join-Path $root 'build\windows\x64\runner\Release'
$out = Join-Path $root 'build\installer'
if (-not (Test-Path (Join-Path $release 'iptv_app.exe'))) {
  throw "Falta o build: corre primeiro 'flutter build windows --release'."
}
New-Item -ItemType Directory -Force -Path $out | Out-Null

# O MSI só aceita versões numéricas (maior.menor.patch).
$numericVersion = ($Version -split '[-+]')[0]

# As apps Flutter precisam do runtime do Visual C++; ir com ele evita o
# "VCRUNTIME140.dll em falta" em PCs sem o redistribuível.
foreach ($dll in 'msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll') {
  Copy-Item (Join-Path $env:WINDIR "System32\$dll") $release -Force
}

# --- .exe (Inno Setup 6) ----------------------------------------------------
function Find-Iscc {
  Get-ChildItem "${env:ProgramFiles(x86)}\Inno Setup*\ISCC.exe", "$env:ProgramFiles\Inno Setup*\ISCC.exe" `
    -ErrorAction SilentlyContinue | Select-Object -First 1
}
$iscc = Find-Iscc
if (-not $iscc) {
  choco install innosetup --no-progress -y | Out-Null
  $iscc = Find-Iscc
}
if (-not $iscc) { throw 'ISCC.exe (Inno Setup) não encontrado.' }
& $iscc.FullName "/DAppVersion=$Version" (Join-Path $PSScriptRoot 'iptv.iss')
if ($LASTEXITCODE -ne 0) { throw "Inno Setup falhou ($LASTEXITCODE)" }

# --- .msi (WiX 5) -----------------------------------------------------------
# Fixo na 5.x: a partir da 6 o WiX passou a exigir a "Open Source
# Maintenance Fee".
if (-not (Get-Command wix -ErrorAction SilentlyContinue)) {
  dotnet tool install --global wix --version 5.0.2
  if ($LASTEXITCODE -ne 0) { throw 'Não foi possível instalar o WiX (dotnet tool).' }
  $env:PATH += ";$env:USERPROFILE\.dotnet\tools"
}
& wix build (Join-Path $PSScriptRoot 'lostthegame.wxs') `
  -arch x64 `
  -d "AppVersion=$numericVersion" `
  -bindpath "Release=$release" `
  -o (Join-Path $out "LostTheGame-Windows.msi")
if ($LASTEXITCODE -ne 0) { throw "WiX falhou ($LASTEXITCODE)" }

Get-ChildItem $out -File | Where-Object { $_.Extension -in '.exe', '.msi' } |
  ForEach-Object { '{0}  {1:N1} MB' -f $_.Name, ($_.Length / 1MB) }
