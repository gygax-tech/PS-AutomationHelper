Import-Module "$PSScriptRoot\PS-AutomationHelper.psd1" -Force
[ExecutionStep[]]$ExecutionSteps = @()
$MyInvocation.Line
# will not run (precondition not met)
# will not be undone

$myFistInstallStep = @{
  StepDescription = 'My 1st installStep' 
  Precondition    = { 2 -eq 1 }
  ExecutionAction = { Write-Host 'Executing step 1 -> success' -ForegroundColor Green }
  RecoverAction   = { Write-Host 'Recovering step 1' -ForegroundColor Cyan }
  ErrorMsg        = 'Error Message'
}

# will run (no precondition)
# will be undone

$firstStep = New-ExecutionStep @myFistInstallStep
$secondSteop = New-ExecutionStep `
  -StepDescription 'My 2nd InstallStep' `
  -ExecutionAction { Write-Host 'Executing step 2 -> success' -ForegroundColor Green } `
  -RecoverAction { Write-Host 'Recovering step 2' -ForegroundColor Cyan } `
  -ErrorMsg 'Error 2'

$ExecutionSteps += $firstStep
$ExecutionSteps += $secondSteop
# will run, but produce a non temrinal error
# will be undone
$ExecutionSteps = Add-ExecutionStep `
  -ExecutionStepList $ExecutionSteps `
  -Description 'My 3rd installSTeop' `
  -ExecutionAction { Remove-Item c:\doesNotExist } `
  -RecoverAction { Write-Host 'Recovering step 3' -ForegroundColor Cyan } `
  -ErrorMessage 'Could not remove inexisting element'

# will run, but produce a temrinal error
$ExecutionSteps = Add-ExecutionStep `
  -ExecutionStepList $ExecutionSteps `
  -Description 'My 4th installSTeop' `
  -ExecutionAction { Remove-Item c:\doesNotExist } `
  -RecoverAction { Write-Hosts 'Recovering step 4' -ForegroundColor Cyan } `
  -ErrorMessage 'Could not remove inexisting element' `
  -TerminalError

$ExecutionSteps += New-ExecutionStep `
  -StepDescription 'Executes with terminal error | Will be recovered with error.' `
  -ExecutionAction { Write-Hosts 'Executing step 4 -> not run' -ForegroundColor Green } `
  -RecoverAction { Write-Host 'Recovering step 4' -ForegroundColor Cyan } `
  -ErrorMsg 'Error 5 | Will be recovered' `
  -TerminalError

Invoke-Execution -ExecutionSteps $ExecutionSteps
