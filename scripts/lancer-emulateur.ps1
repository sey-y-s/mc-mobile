<#
  Lance l'application MaliCompétences sur un ÉMULATEUR Android et le relie au backend du PC (port 8080).

  Utilisation (dans le dossier mc-mobile) :
    .\emulateur.bat                      -> démarre l'émulateur s'il n'est pas lancé, puis l'application
    .\emulateur.bat -Nom Pixel_8         -> choisit l'émulateur par son nom (voir : flutter emulators)

  L'émulateur joint le PC par l'adresse spéciale 10.0.2.2 (config/emulateur.json) : aucun réglage réseau.
#>
param(
  [string] $Nom = '',
  [int] $Port = 8080
)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

function Fail($msg) { Write-Host "ERREUR : $msg" -ForegroundColor Red; exit 1 }

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { Fail "flutter introuvable dans le PATH." }
if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
  $sdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools'
  if (Test-Path (Join-Path $sdk 'adb.exe')) { $env:Path = "$sdk;$env:Path" }
  else { Fail "adb introuvable. Installez Android SDK Platform-Tools (Android Studio > SDK Manager)." }
}

function Emulateurs-Actifs {
  @(adb devices | Select-String -Pattern "^emulator-\d+\s+device$" | ForEach-Object { ($_ -split "\s+")[0] })
}

$actifs = Emulateurs-Actifs
if ($actifs.Count -eq 0) {
  # Liste des émulateurs créés dans Android Studio (Device Manager)
  $exe = Join-Path $env:LOCALAPPDATA 'Android\Sdk\emulator\emulator.exe'
  if (Test-Path $exe) { $liste = @(& $exe -list-avds | Where-Object { $_ -and $_ -notmatch '^(INFO|WARNING)' }) }
  else { $liste = @(flutter emulators 2>$null | Select-String -Pattern "^(\S+)\s+\S\s+" | ForEach-Object { $_.Matches[0].Groups[1].Value } | Where-Object { $_ -ne 'Id' }) }
  if ($liste.Count -eq 0) {
    Fail @"
Aucun émulateur Android n'existe sur ce PC.
  Android Studio > Device Manager > Create Device > choisissez « Pixel 8 » puis une image système
  (API 34 ou plus, « Google Play » ou « Google APIs »), puis relancez ce script.
"@
  }
  $choix = if ($Nom -and ($liste -contains $Nom)) { $Nom } else { $liste[0] }
  Write-Host "Démarrage de l'émulateur « $choix » (1 à 2 minutes la première fois)..." -ForegroundColor Cyan
  flutter emulators --launch $choix | Out-Null
  $debut = Get-Date
  while ((Emulateurs-Actifs).Count -eq 0) {
    if (((Get-Date) - $debut).TotalSeconds -gt 180) { Fail "L'émulateur n'a pas démarré en 3 minutes." }
    Start-Sleep -Seconds 3
  }
  $actifs = Emulateurs-Actifs
}
$emulateur = $actifs[0]
Write-Host "Attente du démarrage complet d'Android..."
$debut = Get-Date
while ((adb -s $emulateur shell getprop sys.boot_completed 2>$null).Trim() -ne '1') {
  if (((Get-Date) - $debut).TotalSeconds -gt 180) { Fail "Android n'a pas fini de démarrer." }
  Start-Sleep -Seconds 3
}
Write-Host "Émulateur prêt : $emulateur" -ForegroundColor Green

try { Invoke-WebRequest -UseBasicParsing -TimeoutSec 3 "http://localhost:$Port/v3/api-docs" | Out-Null; Write-Host "Backend joignable sur le port $Port." -ForegroundColor Green }
catch { Write-Host "ATTENTION : le backend ne répond pas sur http://localhost:$Port. Démarrez-le dans IntelliJ avant de vous connecter dans l'app." -ForegroundColor Yellow }

flutter run -d $emulateur --dart-define-from-file=config/emulateur.json
