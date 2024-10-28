# WARNING: Due to the limitation that the Python Windows installer only
# supports a single installation per system, this script will uninstall
# versions of Python already present on your system!

$versions = "3.8.10","3.9.13","3.10.11","3.11.9","3.12.7","3.13.0"
$installerargs = "/quiet","/repair","InstallAllUsers=0","Include_doc=0","Include_pip=0","Include_test=0","Include_launcher=0","Include_freethreaded=1","InstallLauncherAllUsers=0","Shortcuts=0","AssociateFiles=0"
$packages = "pytest","pip","setuptools"

$temp = Join-Path ([System.IO.Path]::GetTempPath()) $(New-Guid)
New-Item -Type Directory -Path $temp | Out-Null

$wc = New-Object Net.WebClient

$installersuffix = ""
$dirsuffix = ""
if ($args[0] -match '64$')
{
  $installersuffix = "-amd64"
  $dirsuffix = "-x64"
}

$env:PYTHONDONTWRITEBYTECODE = "1"

foreach ($version in $versions)
{
  $url = "https://www.python.org/ftp/python/$version/python-$version$installersuffix.exe"
  $installer = "$temp\python-$version$installersuffix.exe"
  $minor = "$(([version]$version).Major).$(([version]$version).Minor)"
  $installdir = "$temp\win-python$minor$dirsuffix"
  $destination = "$pwd\win-python$minor$dirsuffix"

  Write-Host "Downloading $url..."
  $wc.DownloadFile($url, $installer)

  Write-Host "Installing to $installdir..."
  Start-Process -Wait $installer -ArgumentList ($installerargs+"TargetDir=$installdir")

  if (-Not (Test-Path $installdir))
  {
    # Didn't work, most likely this version of Python is already installed.
    Write-Host "Uninstalling existing Python $version installation..."
    Start-Process -Wait $installer -ArgumentList "/uninstall","/quiet"
    if (Test-Path $installdir)
    {
      Remove-Item -Recurse -Force $installdir
    }

    Write-Host "Re-installing to $installdir..."
    Start-Process -Wait $installer -ArgumentList ($installerargs+"TargetDir=$installdir")
  }

  Write-Host "Installing pip packages..."
  Start-Process -Wait $installdir\python.exe -NoNewWindow -ArgumentList "-B","-m","ensurepip"
  Start-Process -Wait $installdir\python.exe -NoNewWindow -ArgumentList (@("-B","-m","pip","install")+$packages)

  Write-Host "Deleting __pycache__ directories..."
  Get-ChildItem $installdir -Include __pycache__ -Recurse -Force | Remove-Item -Force -Recurse

  Write-Host "Copying to $destination..."
  if (Test-Path $destination)
  {
    Remove-Item -Recurse -Force $destination
  }
  Copy-Item $installdir -Destination $destination -Recurse

  Write-Host "Running uninstaller..."
  Start-Process -Wait $installer -ArgumentList "/uninstall","/quiet"
}

Remove-Item -Recurse -Force $temp

Write-Host "Done!"
