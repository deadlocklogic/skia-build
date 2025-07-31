# scripts/install-deps-windows.ps1
Set-StrictMode -Version Latest
Write-Host "Installing Windows dependencies..."

# Install essential tools sorted alphabetically
choco install -y `
  cmake `
  curl `
  git `
  llvm `
  ninja `
  python `
  unzip `
  zip

Write-Host "Windows dependencies installed."
