# Signs a draft release with the Certum code signing certificate and publishes it.
# Run through sign-release.cmd after release.cmd, once GitHub has finished building the draft.
# Usage:  sign-release.cmd            (the newest draft release)
#         sign-release.cmd v1.0.69    (a specific one)
# Needs, on this PC:
#   - SimplySign Desktop, logged in (the certificate "Open Source Developer Charles Love" lives in Certum's cloud)
#   - Windows SDK signing tools (signtool.exe)
#   - Inno Setup 6, to rebuild the installer around the signed app
#   - GitHub CLI (gh), signed in once with: gh auth login
# Optional: set SIGN_THUMBPRINT to pick the certificate by thumbprint instead of by name.

param([string]$Tag)
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$appName   = "KrabbzDev's Porch Radar"
$app       = 'Krabbz9999-FlightTracker.exe'
$setup     = 'Krabbz9999-FlightTracker-Setup.exe'
$certName  = 'Open Source Developer Charles Love'
$timestamp = 'http://time.certum.pl'
$repo      = (Get-Content version.json -Raw | ConvertFrom-Json).repo

function Fail([string]$message) {
  Write-Host ''
  Write-Host $message -ForegroundColor Red
  exit 1
}
function Step([string]$message) { Write-Host "`n== $message" -ForegroundColor Cyan }

# ---------- tools ----------
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  Fail 'GitHub CLI not found. Install it from https://cli.github.com, then run once:  gh auth login'
}
$signtool = Get-ChildItem "${env:ProgramFiles(x86)}\Windows Kits\10\bin\*\x64\signtool.exe" -ErrorAction SilentlyContinue |
  Sort-Object FullName -Descending | Select-Object -First 1
if (-not $signtool) {
  Fail 'signtool.exe not found. Install the Windows SDK (https://developer.microsoft.com/windows/downloads/windows-sdk/) and tick "Windows SDK Signing Tools".'
}
$signtool = $signtool.FullName
$iscc = @("${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe", "$env:ProgramFiles\Inno Setup 6\ISCC.exe", "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe") |
  Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $iscc) { Fail 'Inno Setup 6 not found. Install it from https://jrsoftware.org/isdl.php' }

# ---------- certificate (SimplySign Desktop puts it in your personal certificate store) ----------
$thumb = $env:SIGN_THUMBPRINT
if (-not $thumb) {
  $cert = Get-ChildItem Cert:\CurrentUser\My |
    Where-Object { $_.Subject -like "*$certName*" -and $_.NotAfter -gt (Get-Date) } |
    Sort-Object NotAfter -Descending | Select-Object -First 1
  if (-not $cert) {
    Fail "Certificate `"$certName`" not found. Log in to SimplySign Desktop (tray icon, code from the SimplySign phone app) and try again."
  }
  $thumb = $cert.Thumbprint
  if ($cert.NotAfter -lt (Get-Date).AddDays(30)) {
    Write-Host "Note: the certificate expires on $($cert.NotAfter.ToString('yyyy-MM-dd')). Renew it at Certum." -ForegroundColor Yellow
  }
}
$signArgs = @('sign', '/sha1', $thumb, '/fd', 'sha256', '/tr', $timestamp, '/td', 'sha256', '/d', $appName, '/du', "https://github.com/$repo")

# ---------- which release ----------
if (-not $Tag) {
  $drafts = gh release list -R $repo --limit 30 --json tagName,isDraft,createdAt | ConvertFrom-Json |
    Where-Object { $_.isDraft } | Sort-Object createdAt -Descending
  if (-not $drafts) {
    Fail "No draft release found. Run release.cmd first, then wait for GitHub to finish building it:`n  https://github.com/$repo/actions"
  }
  $Tag = @($drafts)[0].tagName
}
Write-Host "Signing $Tag for $repo"

$work = Join-Path $env:TEMP "porchradar-sign-$Tag"
if (Test-Path $work) { Remove-Item $work -Recurse -Force }
New-Item -ItemType Directory -Force $work | Out-Null

# ---------- the app ----------
Step "Downloading $app"
gh release download $Tag -R $repo -p $app -D $work --clobber
if ($LASTEXITCODE) { Fail "Couldn't download $app from release $Tag." }

Step "Signing $app (approve in SimplySign if it asks)"
& $signtool @signArgs "$work\$app"
if ($LASTEXITCODE) { Fail 'Signing failed. Is SimplySign Desktop still logged in?' }
& $signtool verify /pa /q "$work\$app"
if ($LASTEXITCODE) { Fail "$app didn't pass signature verification." }

# ---------- the installer, rebuilt around the signed app, from the same commit as the release ----------
Step 'Rebuilding the installer'
cmd /c "git fetch -q origin tag $Tag 2>nul" # in case the tag was made on another PC
git archive --format=zip -o "$work\src.zip" $Tag installer/FlightTracker.iss version.json
if ($LASTEXITCODE) { Fail "Couldn't read the installer script for $Tag from git." }
Expand-Archive "$work\src.zip" -DestinationPath $work -Force
$v = Get-Content "$work\version.json" -Raw | ConvertFrom-Json
$build = if ($v.patch) { "$($v.build).$($v.patch)" } else { "$($v.build)" }
# Inno Setup signs the setup and its uninstaller with this command ($q is a quote, $f the file)
$signCmd = '$q' + $signtool + '$q ' + (($signArgs | ForEach-Object { if ($_ -match ' ') { '$q' + $_ + '$q' } else { $_ } }) -join ' ') + ' $f'
& $iscc /Q "/Scertum=$signCmd" '/DSignWith=certum' "/DAppVersion=$($v.version).$build" "$work\installer\FlightTracker.iss"
if ($LASTEXITCODE) { Fail 'Installer build failed.' }
& $signtool verify /pa /q "$work\dist\$setup"
if ($LASTEXITCODE) { Fail "$setup didn't pass signature verification." }

# ---------- publish ----------
Step 'Uploading the signed files and publishing'
gh release upload $Tag -R $repo "$work\$app" "$work\dist\$setup" --clobber
if ($LASTEXITCODE) { Fail 'Upload failed. The release is still a draft; run sign-release.cmd again.' }
gh release edit $Tag -R $repo --draft=false --latest
if ($LASTEXITCODE) { Fail "Files uploaded, but publishing failed. Publish the draft by hand: https://github.com/$repo/releases" }

Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "`nPublished $Tag, signed:  https://github.com/$repo/releases/tag/$Tag" -ForegroundColor Green
