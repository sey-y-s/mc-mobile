<#
  Lance l'application MaliCompétences sur un téléphone Android connecté SANS FIL (débogage Wi-Fi)
  et le relie au backend qui tourne sur ce PC (port 8080).

  Utilisation (dans le dossier mc-mobile) :
    .\telephone.bat                                        -> mode ADB (recommandé), connexion automatique
    .\scripts\lancer-telephone.bat -Mode wifi              -> mode adresse IP du PC
    .\scripts\lancer-telephone.bat -Connecter 192.168.1.20:37099   -> connecte d'abord le téléphone

  Mode "adb"  : le téléphone joint le PC par le tunnel ADB (adb reverse). Aucune adresse IP ni pare-feu
                à régler, fonctionne même si l'adresse IP du PC change.
  Mode "wifi" : le téléphone appelle directement l'adresse IP du PC sur le réseau Wi-Fi
                (PC et téléphone sur le même réseau, port 8080 ouvert dans le pare-feu Windows).
#>
param(
  [ValidateSet('adb', 'wifi')] [string] $Mode = 'adb',
  [string] $Connecter = '',
  [int] $Port = 8080
)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

function Fail($msg) { Write-Host "ERREUR : $msg" -ForegroundColor Red; exit 1 }

if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
  $sdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools'
  if (Test-Path (Join-Path $sdk 'adb.exe')) { $env:Path = "$sdk;$env:Path" }
  else { Fail "adb introuvable. Installez Android SDK Platform-Tools (Android Studio > SDK Manager)." }
}
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { Fail "flutter introuvable dans le PATH." }

$fichierMemoire = Join-Path $PSScriptRoot '.dernier-telephone.txt'

function Telephones-Connectes {
  @(adb devices | Select-String -Pattern "\tdevice$" | ForEach-Object { ($_ -split "`t")[0] } | Where-Object { $_ -notlike 'emulator-*' })
}

# 1. Adresse donnée en paramètre, sinon dernière adresse utilisée
if ($Connecter) {
  Write-Host "Connexion au téléphone $Connecter ..."
  adb connect $Connecter | Write-Host
} elseif ((Telephones-Connectes).Count -eq 0 -and (Test-Path $fichierMemoire)) {
  $derniere = (Get-Content $fichierMemoire -Raw).Trim()
  if ($derniere) { Write-Host "Reconnexion à $derniere ..."; adb connect $derniere | Out-Null }
}

# 2. Détection automatique du téléphone sur le Wi-Fi (débogage sans fil déjà associé)
if ((Telephones-Connectes).Count -eq 0) {
  Write-Host "Recherche du téléphone sur le Wi-Fi..."
  $services = @(adb mdns services 2>$null | Select-String -Pattern "_adb-tls-connect\._tcp\s+(\d{1,3}(?:\.\d{1,3}){3}:\d+)")
  foreach ($m in $services) { adb connect $m.Matches[0].Groups[1].Value | Out-Null }
}

# 3. Première fois : association guidée avec le code affiché sur le téléphone
if ((Telephones-Connectes).Count -eq 0) {
  Write-Host ""
  Write-Host "Première connexion : association du téléphone (une seule fois)." -ForegroundColor Cyan
  Write-Host "Sur le téléphone : Options pour les développeurs > Débogage sans fil > activer,"
  Write-Host "puis « Associer l'appareil avec un code d'association »."
  $assoc = Read-Host "Adresse d'association affichée (ex. 192.168.1.20:41234)"
  $code  = Read-Host "Code à 6 chiffres"
  if ($assoc -and $code) { adb pair $assoc $code | Write-Host }
  $adr = Read-Host "Adresse affichée sur l'écran « Débogage sans fil » (ex. 192.168.1.20:37099)"
  if ($adr) { adb connect $adr | Write-Host }
}

$telephones = Telephones-Connectes
if ($telephones.Count -eq 0) {
  Fail @"
Aucun téléphone connecté. Vérifiez que le téléphone et le PC sont sur le MÊME Wi-Fi,
que « Débogage sans fil » est activé, puis relancez : telephone.bat
"@
}
$telephone = $telephones[0]
Write-Host "Téléphone : $telephone" -ForegroundColor Green
if ($telephone -match "^\d{1,3}(\.\d{1,3}){3}:\d+$") { Set-Content -Path $fichierMemoire -Value $telephone }

try { Invoke-WebRequest -UseBasicParsing -TimeoutSec 3 "http://localhost:$Port/v3/api-docs" | Out-Null; Write-Host "Backend joignable sur le port $Port." -ForegroundColor Green }
catch { Write-Host "ATTENTION : le backend ne répond pas sur http://localhost:$Port. Démarrez-le dans IntelliJ avant de vous connecter dans l'app." -ForegroundColor Yellow }

if ($Mode -eq 'adb') {
  adb -s $telephone reverse "tcp:$Port" "tcp:$Port" | Out-Null
  Write-Host "Tunnel actif : le port $Port du téléphone mène au port $Port du PC."
  $config = 'config/telephone-adb.json'
} else {
  $ip = Get-NetIPAddress -AddressFamily IPv4 |
        Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' -and $_.PrefixOrigin -in 'Dhcp','Manual' } |
        Sort-Object -Property @{ Expression = { if ($_.InterfaceAlias -match 'Wi-?Fi|WLAN|Sans fil') { 0 } else { 1 } } } |
        Select-Object -First 1 -ExpandProperty IPAddress
  if (-not $ip) { Fail "Adresse IP du PC introuvable. Êtes-vous connecté au Wi-Fi ?" }
  $config = 'config/telephone.json'
  @{ APP_ENV = 'dev'; USE_MOCKS = $false; API_BASE_URL = "http://${ip}:$Port" } | ConvertTo-Json | Set-Content -Encoding UTF8 $config
  Write-Host "Adresse du backend pour le téléphone : http://${ip}:$Port"
  $regle = Get-NetFirewallRule -DisplayName "MaliCompetences backend $Port" -ErrorAction SilentlyContinue
  if (-not $regle) {
    Write-Host "Si l'app n'arrive pas à joindre le serveur, ouvrez le port dans un PowerShell ADMINISTRATEUR :" -ForegroundColor Yellow
    Write-Host "  New-NetFirewallRule -DisplayName 'MaliCompetences backend $Port' -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow -Profile Private,Domain"
  }
}

flutter run -d $telephone --dart-define-from-file=$config
