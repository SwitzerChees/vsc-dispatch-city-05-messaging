param(
    [string]$Target = "."
)

$ErrorActionPreference = "Stop"
$Source = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetPath = (Resolve-Path $Target).Path
$Block4Manifest = Join-Path $TargetPath "deploy/overlays/block-04-ingress/kustomization.yaml"

if (-not (Test-Path $Block4Manifest)) {
    throw "Im Ziel fehlt der Projektstand aus Block 4 (deploy/overlays/block-04-ingress)."
}

$Directories = @("build", "cmd", "docs", "internal", "scripts", "deploy/overlays/block-05-messaging")
foreach ($Directory in $Directories) {
    $Destination = Join-Path $TargetPath $Directory
    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    Copy-Item -Recurse -Force (Join-Path $Source "$Directory/*") $Destination
}

Copy-Item -Force (Join-Path $Source "go.mod") $TargetPath
Copy-Item -Force (Join-Path $Source "go.sum") $TargetPath

Write-Host "Block 5 wurde in $TargetPath installiert."
Write-Host "Naechster Schritt: Images bauen, in teko-k8s importieren und das Block-5-Overlay anwenden."
