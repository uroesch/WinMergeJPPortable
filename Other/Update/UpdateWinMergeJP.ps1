# -----------------------------------------------------------------------------
# Description: Generic Update Script for PortableApps 
# Author: Urs Roesch <github@bun.ch>
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Globals 
# -----------------------------------------------------------------------------
$AppRoot    = "$PSScriptRoot\..\.."
$AppInfoDir = "$AppRoot\App\AppInfo"
$AppInfoIni = "$AppInfoDir\appinfo.ini"
$UpdateIni  = "$AppInfoDir\update.ini"
$Debug      = $False

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------
Function Debug () { 
  param( [string] $Message )
  If (-Not($Debug)) { return }
  Write-Host $Message
}

# -----------------------------------------------------------------------------
Function Parse-Ini {
  param (
     $IniFile
  )

  $IniContent = Get-Content $IniFile

  $resulttable=@()
  foreach ($line in $IniContent) {
     Debug "Processing $line"
     if ($line[0] -eq ";") {
       Debug "Skip comment line"
     }

     elseif ($line[0] -eq "[") {
       $Section = $line.replace("[","").replace("]","")
       Debug "Found new section: $Section"
     }
     elseif ($line -like "*=*") {
       Debug "Found Keyline"
         $resulttable += @{
           Section  = $Section
           Key      = $line.split("=")[0].Trim()
           Value    = $line.split("=")[1].Trim()
         }
        }
        else {
          Debug "Skip line"
        }
  }
  return $resulttable
}

# -----------------------------------------------------------------------------
Function Fetch-Section() {
  param( [string] $Key )
  $Section = @{}
  Foreach ($Item in $Config) { 
    If ($Item["Section"] -eq $Key) {
      $Section += @{ $Item["Key"] = $Item["Value"] }
    }
  }
  return $Section
} 

# -----------------------------------------------------------------------------
Function Url-Basename {
  param(
    [string] $URL
  )
  $Elements = $URL.split('/')
  $Basename = $Elements[$($Elements.Length-1)]
  return $Basename
}

# -----------------------------------------------------------------------------
Function Download-ZIP { 
  param(
    [string] $URL
  )
  $PathZip = "$PSScriptRoot\$(Url-Basename -URL $URL)"
  If (!(Test-Path $PathZip)) {
    Invoke-WebRequest -Uri $URL -OutFile $PathZip
  }
  return $PathZip
}

# -----------------------------------------------------------------------------
Function Update-Zip {
  param(
    [string] $URL,
    [string] $TargetDir,
    [string] $ExtractDir
  )
  Write-Host $URL
  $ZipFile    = $(Download-ZIP -URL $URL)
  $TargetPath = "$AppRoot\App\$TargetDir"
  Expand-Archive -LiteralPath $ZipFile -DestinationPath $PSScriptRoot -Force
  If (Test-Path $TargetPath) {
    Write-Output "Removing $TargetPath"
    Remove-Item -Path $TargetPath -Force -Recurse
  }
  Move-Item -Path $PSScriptRoot\$ExtractDir -Destination $TargetPath -Force
  Remove-Item $ZipFile
}

# -----------------------------------------------------------------------------
Function Update-Appinfo-Item() {
  param(
    [string] $IniFile,
    [string] $Match,
    [string] $Replace
  )
  If (Test-Path $IniFile) {
    $Content = (Get-Content $IniFile)
    $Content -replace $Match, $Replace | Out-File -FilePath $IniFile
  }
}

# -----------------------------------------------------------------------------
Function Update-Appinfo() {
  $Version = (Fetch-Section "Version")
  Update-Appinfo-Item `
    -IniFile $AppInfoIni `
    -Match '^PackageVersion\s*=.*' `
    -Replace "PackageVersion=$($Version['Package'])"
  Update-Appinfo-Item `
    -IniFile $AppInfoIni `
    -Match '^DisplayVersion\s*=.*' `
    -Replace "DisplayVersion=$($Version['Display'])"
}

# -----------------------------------------------------------------------------
Function Update-Application() {
  $Archive = (Fetch-Section 'Archive')
  $Position = 1
  While ($True) {
    If (-Not ($Archive.ContainsKey("URL$Position"))) {
      Break
    } 
    Update-ZIP `
      -URL $Archive["URL$Position"] `
      -TargetDir $Archive["TargetDir$Position"] `
      -ExtractDir $Archive["ExtractDir$Position"] 
    $Position += 1
  }
}

# -----------------------------------------------------------------------------
Function Windows-Path() {
  param( [string] $Path )
  $Path = $Path -replace ".*drive_(.)", '$1:'  
  $Path = $Path.Replace("/", "\") 
  return $Path
}

# -----------------------------------------------------------------------------
Function Create-Launcher() { 
  Set-Location $AppRoot
  $AppPath  = (Get-Location)
  $Launcher = "..\PortableApps.comLauncher\PortableApps.comLauncherGenerator.exe"
  If ($IsWindows) { 
    Invoke-Expression "$Launcher $AppPath"
  }
  Else {
    Invoke-Expression "wine $Launcher $(Windows-Path $AppPath)"
  }
}

# -----------------------------------------------------------------------------
Function Create-Installer() { 
  Set-Location $AppRoot
  $AppPath   = (Get-Location)
  $Installer = "..\PortableApps.comInstaller\PortableApps.comInstaller.exe"
  If ($IsWindows) { 
    Invoke-Expression "$Installer $AppPath"
  }
  Else {
    Invoke-Expression "wine $Installer $(Windows-Path $AppPath)"
  }
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
$Config = (Parse-Ini $UpdateIni)
Update-Application
Update-Appinfo
Create-Launcher
Create-Installer
