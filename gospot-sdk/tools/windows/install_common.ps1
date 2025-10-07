# install_common.ps1 - Windows helper (PowerShell)
# Requires running in elevated session for choco install actions
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
  Write-Host "Chocolatey not found. Follow https://chocolatey.org/install"
} else {
  choco install -y curl wget git
}
