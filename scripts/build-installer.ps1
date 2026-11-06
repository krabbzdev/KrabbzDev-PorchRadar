# Builds and signs the Windows installer: dist\Krabbz9999-FlightTracker-Setup.exe
#
# Run it through build-installer.cmd. You only need it when the signed base changes (launcher\, tray\, installer\, or the
# bundled Node.js version). Normal releases are code-only: release.cmd, and GitHub builds the update.
#
#   build-installer.cmd               build and sign
#   build-installer.cmd -Upload       ...and publish it to the "installer" release (needs the GitHub CLI, gh)
#   build-installer.cmd -NoSign       build without signing, to test the install on a PC
#
# Signing uses a code-signing certificate in your Windows certificate store (Current User > Personal). For a cloud
# certificate such as Certum SimplySign, open its desktop app and sign in first, so the certificate is available.
# With one certificate it is picked automatically. With several, set PORCHRADAR_CERT_SHA1 to the one to use
# (its thumbprint; see the list printed below). The thumbprint is not a secret. Never put a PIN or password in this repo.
param([switch]$NoSign, [switch]$Upload, [string]$Thumbprint = $env:PORCHRADAR_CERT_SHA1)

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot)
$Repo = 'krabbzdev/KrabbzDev-PorchRadar'
$Timestamp = 'http://time.certum.pl'   # Certum's timestamp server; the signature stays valid after the certificate expires

function Step($m) { Write-Host "`n== $m" -ForegroundColor Cyan }
function Need($ok, $m) { if (-not $ok) { throw $m } }
function Run($exe, [string[]]$a) { & $exe @a; if ($LASTEXITCODE) { throw "$exe failed (exit $LASTEXITCODE)" } }

# ---------- tools ----------
Step 'Looking for tools'
$csc = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
Need (Test-Path $csc) 'The .NET Framework C# compiler (csc.exe) was not found.'
$iscc = @("${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe", "$env:ProgramFiles\Inno Setup 6\ISCC.exe", "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
Need $iscc 'Inno Setup 6 was not found. Install it from https://jrsoftware.org/isinfo.php'
$node = (Get-Command node -ErrorAction SilentlyContinue).Source
Need $node 'Node.js was not found. Install it from https://nodejs.org (the version you install is the one inside the installer).'
$signtool = $null
if (-not $NoSign) {
  $signtool = Get-ChildItem "${env:ProgramFiles(x86)}\Windows Kits\10\bin\*\x64\signtool.exe" -ErrorAction SilentlyContinue | Sort-Object FullName -Descending | Select-Object -First 1 -ExpandProperty FullName
  Need $signtool 'signtool.exe was not found. Install the Windows SDK (only the "Signing Tools for Desktop Apps" part is needed).'
}
Write-Host "csc:      $csc`nInno:     $iscc`nNode:     $node ($(& $node --version))"
if ($signtool) { Write-Host "signtool: $signtool" }

# The runtime goes into the installer unmodified, so its own signature is what keeps it trusted. Refuse anything else.
$nodeSig = Get-AuthenticodeSignature $node
Need ($nodeSig.Status -eq 'Valid') "node.exe at $node does not have a valid signature ($($nodeSig.Status)). Install Node.js from https://nodejs.org."
Write-Host "Node.js is signed by: $($nodeSig.SignerCertificate.Subject)"

# ---------- certificate ----------
if (-not $NoSign) {
  Step 'Finding the code-signing certificate'
  $certs = @(Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert | Where-Object { $_.NotAfter -gt (Get-Date) -and $_.HasPrivateKey })
  $certs | ForEach-Object { Write-Host ("  {0}  {1}  (expires {2:yyyy-MM-dd})" -f $_.Thumbprint, $_.Subject, $_.NotAfter) }
  if ($Thumbprint) {
    $Thumbprint = ($Thumbprint -replace '\s', '').ToUpper()
    Need ($certs | Where-Object Thumbprint -eq $Thumbprint) "No usable code-signing certificate with thumbprint $Thumbprint is in the certificate store."
  } else {
    Need ($certs.Count -ge 1) 'No code-signing certificate found. Open the code-signing app (for Certum: SimplySign Desktop), sign in so the certificate is available, then run this again.'
    Need ($certs.Count -eq 1) 'More than one code-signing certificate found. Set PORCHRADAR_CERT_SHA1 to the thumbprint of the one to use (listed above).'
    $Thumbprint = $certs[0].Thumbprint
  }
  Write-Host "Signing with certificate $Thumbprint"
}
function Sign($file) {
  if ($NoSign) { return }
  Run $signtool @('sign', '/sha1', $Thumbprint, '/fd', 'sha256', '/tr', $Timestamp, '/td', 'sha256', '/d', "KrabbzDev's Porch Radar", $file)
  Run $signtool @('verify', '/pa', $file)
}

# ---------- stage the base ----------
Step 'Building the launcher and tray helper'
$base = 'build\base'
if (Test-Path build\base) { Remove-Item build\base -Recurse -Force }
New-Item -ItemType Directory -Force "$base\runtime", "$base\app" | Out-Null
Run $csc @('-nologo', '-target:winexe', '-optimize+', '-out:build\base\Krabbz9999-FlightTracker.exe', 'launcher\Launcher.cs', 'launcher\AssemblyInfo.cs')
Run $csc @('-nologo', '-target:winexe', '-optimize+', '-r:System.Web.Extensions.dll', '-out:build\base\Krabbz9999-FlightTracker-Tray.exe', 'tray\Tray.cs', 'launcher\AssemblyInfo.cs')

Step 'Copying the runtime and the app code'
Copy-Item $node "$base\runtime\node.exe"
foreach ($f in 'server.js', 'index.html') { Copy-Item $f "$base\app\$f" }
# version.json gets the commit stamped in, like GitHub's build does. Written without a byte-order mark, which Node can't parse.
$v = Get-Content version.json -Raw | ConvertFrom-Json
# (from a downloaded ZIP there is no git, so the commit is left out)
$commit = $null
if (Get-Command git -ErrorAction SilentlyContinue) { try { $commit = (git rev-parse --short=7 HEAD 2>$null | Out-String).Trim() } catch {} }
if ($commit) { $v | Add-Member -NotePropertyName commit -NotePropertyValue $commit -Force }
[IO.File]::WriteAllText((Join-Path (Get-Location) "$base\app\version.json"), ($v | ConvertTo-Json -Compress), (New-Object Text.UTF8Encoding $false))
if ((Get-Command git -ErrorAction SilentlyContinue) -and (git status --porcelain 2>$null)) { Write-Warning 'You have uncommitted changes; the installer contains them, but GitHub does not have them yet.' }

Step 'Signing the launcher and tray helper'
Sign (Resolve-Path "$base\Krabbz9999-FlightTracker.exe").Path
Sign (Resolve-Path "$base\Krabbz9999-FlightTracker-Tray.exe").Path

# ---------- the installer ----------
Step 'Building the installer'
$build = if ($v.patch) { "$($v.build).$($v.patch)" } else { "$($v.build)" }
$args2 = @('/Q', "/DAppVersion=$($v.version).$build")
if (-not $NoSign) {
  # Inno's placeholders: $q is a quote mark and $f the file to sign
  $args2 += '/DSigned=1'
  $args2 += ('/Sstsign=$q' + $signtool + '$q sign /sha1 ' + $Thumbprint + ' /fd sha256 /tr ' + $Timestamp + ' /td sha256 $f')
}
$args2 += 'installer\FlightTracker.iss'
Run $iscc $args2
$setup = Resolve-Path 'dist\Krabbz9999-FlightTracker-Setup.exe'
if (-not $NoSign) { Run $signtool @('verify', '/pa', '/v', $setup.Path) | Out-Null }

Step 'Done'
$sig = Get-AuthenticodeSignature $setup.Path
Write-Host "File:      $($setup.Path)"
Write-Host "Signature: $($sig.Status)  $($sig.SignerCertificate.Subject)"
Write-Host "SHA-256:   $((Get-FileHash $setup.Path -Algorithm SHA256).Hash.ToLower())"
if (-not $NoSign) { Need ($sig.Status -eq 'Valid') "The installer's signature is not valid: $($sig.Status)" }

# ---------- publish ----------
if ($Upload) {
  Step 'Publishing to the installer release'
  Need (Get-Command gh -ErrorAction SilentlyContinue) 'The GitHub CLI (gh) is needed for -Upload. Install it from https://cli.github.com and run: gh auth login'
  Need (-not $NoSign) 'Refusing to publish an unsigned installer. Run without -NoSign.'
  # a pre-release, so GitHub's "latest release" (what installed copies update from) is never this one
  & gh release view installer --repo $Repo 2>$null | Out-Null
  if ($LASTEXITCODE) {
    Run gh @('release', 'create', 'installer', '--repo', $Repo, '--prerelease', '--title', 'Windows installer (signed)',
      '--notes', 'The signed Windows installer for KrabbzDev''s Porch Radar. It is replaced only when the launcher, tray helper or bundled Node.js changes. The app updates its own code from the normal releases.')
  }
  Run gh @('release', 'upload', 'installer', $setup.Path, '--repo', $Repo, '--clobber')
  Write-Host "Published: https://github.com/$Repo/releases/download/installer/Krabbz9999-FlightTracker-Setup.exe"
} else {
  Write-Host "`nNot published. Run again with -Upload, or attach the file to the 'installer' release on GitHub by hand."
}
