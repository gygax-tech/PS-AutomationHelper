param (
  [Parameter(ParameterSetName = 'Default', Mandatory = $true)]
  [Parameter(ParameterSetName = 'Publish', Mandatory = $true)]
  [string]
  $ModulePath,

  [Parameter(ParameterSetName = 'Publish')]
  [switch]
  $Publish,
    
  [Parameter(ParameterSetName = 'Publish', Mandatory = $true)]
  [string]
  $PublishPath,
    
  [Parameter(ParameterSetName = 'Default')]
  [Parameter(ParameterSetName = 'Publish')]
  [hashtable]
  $Configuration
)
Write-Information 'Running Pester tests'

# Module stuff
Write-Debug 'Looking for Pester module on worker...'
$pesterModule = Get-Module -Name Pester -ListAvailable | Where-Object { $_.Version -like '5.*' }
if (!$pesterModule) { 
  Write-Debug 'Did not find module on worker. Trying to install it...'
  try {
    Install-Module -Name Pester -Scope CurrentUser -Force -SkipPublisherCheck -MinimumVersion '5.0'
    $pesterModule = Get-Module -Name Pester -ListAvailable | Where-Object { $_.Version -like '5.*' }
  }
  catch {
    Write-Host '##vso[task.logissue type=error]Failed to install the Pester module.'
  }
}

#Pester configuration
if ($null -eq $Configuration) {
  Write-Debug "Pester configuration not in arguments. Using file: '$PSScriptRoot\pesterConfig.ps1'"
  $Configuration = . "$PSScriptRoot\pesterConfig.ps1"
}
$pesterConfiguration = New-PesterConfiguration -Hashtable $Configuration

#Pester preference
$pesterPreference = . "$PSScriptRoot\pesterPreference.ps1"


Write-Information "Pester version: $($pesterModule.Version.Major).$($pesterModule.Version.Minor).$($pesterModule.Version.Build)"
$pesterModule | Import-Module

# Handle publishing 
if ($Publish) {
  if (!(Test-Path -Path $PublishPath)) {
    Write-Debug 'Publish folder does not exist. Creating...'
    New-Item -Path $PublishPath -ItemType Directory -Force | Out-Null
  }
}

# Import Module to test
Write-Debug 'Looking for module manifest...'
$moduleManifest = Get-ChildItem -Path $ModulePath | Where-Object { $_.Name -like '*.psd1' }
Write-Debug "Module manifest found: '$moduleManifest'."

Write-Information 'Importing module manifest.'
Import-Module $moduleManifest.FullName -Force

Write-Information 'Invoke Pester.'
Invoke-Pester -Configuration $pesterConfiguration

