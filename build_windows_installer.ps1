param(
  [ValidateSet("debug", "profile", "release")]
  [string]$Configuration = "release"
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$pubspecPath = Join-Path $projectRoot "pubspec.yaml"
$issPath = Join-Path $projectRoot "windows_installer.iss"
$cmakePath = Join-Path $projectRoot "windows\CMakeLists.txt"

if (-not (Test-Path $pubspecPath)) {
  throw "pubspec.yaml not found: $pubspecPath"
}

if (-not (Test-Path $issPath)) {
  throw "Inno Setup script not found: $issPath"
}

if (-not (Test-Path $cmakePath)) {
  throw "Windows CMake file not found: $cmakePath"
}

$nameLine = Select-String -Path $pubspecPath -Pattern '^name:\s*(.+)$' | Select-Object -First 1
$versionLine = Select-String -Path $pubspecPath -Pattern '^version:\s*([0-9A-Za-z\.\-\+]+)$' | Select-Object -First 1

if (-not $nameLine -or -not $versionLine) {
  throw "Unable to read app name or version from pubspec.yaml."
}

$binaryLine = Select-String -Path $cmakePath -Pattern 'set\(BINARY_NAME\s+"([^"]+)"\)' | Select-Object -First 1
if (-not $binaryLine) {
  throw "Unable to read BINARY_NAME from windows/CMakeLists.txt."
}

$binaryName = $binaryLine.Matches[0].Groups[1].Value
$packageName = $nameLine.Matches[0].Groups[1].Value.Trim()
$appName = if ($packageName -and $packageName -ne "app") { $packageName } else { $binaryName }
$appVersion = ($versionLine.Matches[0].Groups[1].Value.Trim() -split "\+")[0]
$exeName = "$binaryName.exe"
$configurationName = (Get-Culture).TextInfo.ToTitleCase($Configuration.ToLowerInvariant())
$buildOutputDir = Join-Path $projectRoot "build\windows\x64\runner\$configurationName"

Write-Host "Building Windows $configurationName..."
flutter build windows "--$Configuration"

if (-not (Test-Path $buildOutputDir)) {
  throw "Build output directory not found: $buildOutputDir"
}

$isccCommand = Get-Command ISCC.exe -ErrorAction SilentlyContinue
if ($isccCommand) {
  $isccPath = $isccCommand.Source
} else {
  $candidatePaths = @(
    (Join-Path $env:LOCALAPPDATA "Programs\Inno Setup 6\ISCC.exe"),
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
    "C:\Program Files\Inno Setup 6\ISCC.exe"
  )
  $isccPath = $candidatePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
}

if (-not $isccPath) {
  throw "ISCC.exe not found. Please install Inno Setup 6 first."
}

Write-Host "Compiling installer with Inno Setup..."
& $isccPath `
  "/DMyAppName=$appName" `
  "/DMyAppVersion=$appVersion" `
  "/DMyAppPublisher=$appName" `
  "/DMyAppExeName=$exeName" `
  "/DMySourceDir=$buildOutputDir" `
  $issPath

Write-Host "Installer build completed: build\windows_installer"
