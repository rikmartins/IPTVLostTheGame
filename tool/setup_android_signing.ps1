<#
.SYNOPSIS
  Cria a chave de assinatura Android de release (uma única vez na vida da app).

.DESCRIPTION
  O Android só aceita uma atualização se o APK novo estiver assinado com a
  MESMA chave da versão instalada. Perder esta chave (ou a palavra-passe)
  significa que os utilizadores têm de desinstalar a app para receber a
  versão seguinte. Guarda os dois num gestor de palavras-passe.

  Usa o openssl que vem com o Git for Windows (não é preciso JDK) e gera:
    android\upload-keystore.p12             a chave (PKCS12)
    android\key.properties                  para builds de release locais
    android\upload-keystore.p12.base64.txt  para o secret do GitHub
  Nenhum destes ficheiros vai para o repositório (android\.gitignore).

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tool\setup_android_signing.ps1
#>
param(
  [string]$AndroidDir = (Join-Path $PSScriptRoot '..\android'),
  [string]$Repository = 'rikmartins/IPTVLostTheGame'
)

$ErrorActionPreference = 'Stop'

$openssl = 'C:\Program Files\Git\usr\bin\openssl.exe'
if (-not (Test-Path $openssl)) {
  $cmd = Get-Command openssl -ErrorAction SilentlyContinue
  if (-not $cmd) { throw 'openssl não encontrado (instala o Git for Windows).' }
  $openssl = $cmd.Source
}

function Invoke-OpenSsl([string[]]$Arguments) {
  # No Windows PowerShell 5.1, com ErrorActionPreference=Stop, qualquer
  # linha no stderr (a barra de progresso do `openssl req`) vira erro
  # terminal, mesmo redirecionada. Conta só o código de saída.
  $previous = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try {
    $output = & $openssl @Arguments 2>&1
  } finally {
    $ErrorActionPreference = $previous
  }
  if ($LASTEXITCODE -ne 0) {
    throw "openssl $($Arguments[0]) falhou ($LASTEXITCODE): $($output -join "`n")"
  }
}

$AndroidDir = (Resolve-Path $AndroidDir).Path
$keystore = Join-Path $AndroidDir 'upload-keystore.p12'
$properties = Join-Path $AndroidDir 'key.properties'
$base64File = "$keystore.base64.txt"

if (Test-Path $keystore) {
  throw "Já existe $keystore. Nunca se gera uma chave nova por cima: as atualizações deixariam de funcionar."
}

# Palavra-passe aleatória (só letras e dígitos: o key.properties é um
# ficheiro .properties do Java e não gosta de barras invertidas).
$alphabet = [char[]]'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789'
$bytes = New-Object byte[] 32
[System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
$password = -join ($bytes | ForEach-Object { $alphabet[$_ % $alphabet.Length] })

$work = Join-Path ([IO.Path]::GetTempPath()) ([Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $work | Out-Null
try {
  $keyPem = Join-Path $work 'key.pem'
  $certPem = Join-Path $work 'cert.pem'

  # 30 anos: a Google pede validade para lá de 2033 e a chave não se troca.
  Invoke-OpenSsl @('req', '-x509', '-newkey', 'rsa:4096', '-sha256',
    '-days', '10950', '-nodes', '-subj', '/CN=IPTV/O=rikmartins',
    '-keyout', $keyPem, '-out', $certPem)

  # A palavra-passe passa por variável de ambiente, não pela linha de
  # comandos (que fica visível na lista de processos).
  $env:IPTV_KEYSTORE_PASSWORD = $password
  Invoke-OpenSsl @('pkcs12', '-export', '-inkey', $keyPem, '-in', $certPem,
    '-name', 'upload', '-out', $keystore,
    '-passout', 'env:IPTV_KEYSTORE_PASSWORD')
} finally {
  Remove-Item Env:\IPTV_KEYSTORE_PASSWORD -ErrorAction SilentlyContinue
  # key.pem tem a chave privada sem cifra.
  Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
}

@(
  'storeFile=upload-keystore.p12'
  "storePassword=$password"
  "keyPassword=$password"
  'keyAlias=upload'
) | Set-Content -Path $properties -Encoding ASCII

[Convert]::ToBase64String([IO.File]::ReadAllBytes($keystore)) |
  Set-Content -Path $base64File -Encoding ASCII -NoNewline

Write-Host ''
Write-Host 'Chave criada:' -ForegroundColor Green
Write-Host "  $keystore"
Write-Host "  $properties"
Write-Host ''

$gh = Get-Command gh -ErrorAction SilentlyContinue
if ($gh) {
  Get-Content $base64File -Raw | & gh secret set ANDROID_KEYSTORE_BASE64 --repo $Repository
  $password | & gh secret set ANDROID_KEYSTORE_PASSWORD --repo $Repository
  Remove-Item $base64File
  Write-Host "Secrets definidos em $Repository com o gh." -ForegroundColor Green
} else {
  Set-Clipboard -Value $password
  Write-Host 'Falta criar 2 secrets no GitHub:' -ForegroundColor Yellow
  Write-Host "  https://github.com/$Repository/settings/secrets/actions  ->  New repository secret"
  Write-Host ''
  Write-Host '  ANDROID_KEYSTORE_PASSWORD  = a palavra-passe (já está na área de transferência)'
  Write-Host "  ANDROID_KEYSTORE_BASE64    = o conteúdo de $base64File"
  Write-Host ''
  Write-Host 'Depois de criados, apaga o ficheiro .base64.txt.'
}

Write-Host ''
Write-Host 'IMPORTANTE: guarda upload-keystore.p12 e a palavra-passe (está no key.properties)' -ForegroundColor Red
Write-Host 'num gestor de palavras-passe. Sem eles não há mais atualizações para quem já instalou.' -ForegroundColor Red
