$moduleRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

#Add a new line to the markdown file.
$date = Get-Date -Format 'yyyy-MM-dd'
#Update the manifest file
$nuspec = Import-PowerShellDataFile -Path "$moduleRoot\PS-AutomationHelper.psd1"
$currentVersion = $nuspec.ModuleVersion

$releaseNotesContent = Get-Content '.\ReleaseNotes.md' -Raw
$newVersion = [Version](Get-Content "$PSScriptRoot\version.json" | ConvertFrom-Json).Version
if ($currentVersion -lt $newVersion) {
  # Update the manifest file
  Update-ModuleManifest -Path "$moduleRoot\LocalChocoCommands.psd1" -ModuleVersion $NewVersion
  $nuspec.ModuleVersion = $newVersion
  # Update the Markdown file to have the version update
  Add-Content -Path "$moduleRoot\README.md" -Value "# Version: $($newString.ModuleVersion) by: $($env:USERNAME) on $($date) `n" -Encoding utf8
  Add-Content -Path "$moduleRoot\README.md" -Value "## Release notes: `n" -Encoding utf8
  Add-Content -Path "$moduleRoot\README.md" -Value $releaseNotesContent -Encoding utf8
}
#Find the Nuspec File
$MonolithFile = "$chocoPackageDirectory\$chocoPackageName.nuspec"
#Import the New PSD file
$newString = Import-PowerShellDataFile "$moduleRoot\LocalChocoCommands.psd1"
$xmlFile = New-Object xml
# Load the Nuspec file and modify it
$xmlFile.Load($MonolithFile)
$xmlFile.package.metadata.version = $newString.ModuleVersion

$releaseNotes = ''
$releaseNotes += "Version $($newString.ModuleVersion) was created by $($env:USERNAME) on $($date)"
$releaseNotes += "`r`n"
$releaseNotes += 'Release notes:'
$releaseNotes += "`r`n"
$releaseNotes += $releaseNotesContent
$xmlFile.package.metadata.releaseNotes = $releaseNotes
$xmlFile.Save($MonolithFile)

if (Test-Path "$moduleRoot\Output") {
  Remove-Item "$moduleRoot\Output" -Recurse -Force
}

$null = New-Item "$moduleRoot\Output\$newVersion" -ItemType Directory

Copy-Item -Recurse "$moduleRoot\choco-package" "$moduleRoot\Output"
Copy-Item "$moduleRoot\LocalChocoCommands.psd1" "$moduleRoot\Output\$newVersion"
$null = New-Item "$moduleRoot\Output\$newVersion\LocalChocoCommands.psm1" -ItemType File

$string = @'
if(-not (Test-Path $env:ChocolateyInstall\license\chocolatey.license.xml)){
    throw "A licensed version of Chocolatey For Business is required to import and use this module"
}
'@
$string | Add-Content "$moduleRoot\Output\LocalChocoCommands.psm1"

Get-ChildItem -Path "$moduleRoot\Public\*.ps1" | ForEach-Object {
  Get-Content $_.FullName | Add-Content "$moduleRoot\Output\$newVersion\LocalChocoCommands.psm1" -Encoding utf8
}

Compress-Archive -Path "$moduleroot\Output\$newVersion" -DestinationPath "$moduleroot\Output\choco-package\tools\LocalChocoCommands.zip" -Force