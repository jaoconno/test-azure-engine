$ErrorActionPreference = 'Stop';
$toolsDir     = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$fileLocation = Join-Path $toolsDir 'ManageEngine_AssetExplorer_64bit.exe'
$answerFile   = Join-Path $toolsDir 'setup.iss'
$url           = "https://www.manageengine.com/products/asset-explorer/87652187/ManageEngine_AssetExplorer_64bit.exe"

#Based on InstallShield
$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  softwareName  = 'AssetExplorer*'
  file          = $fileLocation
  fileType      = 'exe'
  silentArgs    = "/s /v`"/qn`" /v`"REBOOT=ReallySuppress`" /sms /f1`"$answerFile`""
  validExitCodes= @(0,1641,3010)
  url           = $url
  checksum      = '4DA09F4C5F3B8410BD4658C056A15F379C09BC0458304075A3E5745017D5046E'
  checksumType  = 'sha256'
  url64bit      = ""
  checksum64    = ''
  checksumType64= 'sha256'
  destination   = $toolsDir
  #installDir   = "" # passed when you want to override install directory - requires licensed editions 1.9.0+
}
Get-ChocolateyWebFile -PackageName $env:ChocolateyPackageName -FileFullPath $fileLocation -Url $url
Install-ChocolateyInstallPackage @packageArgs

