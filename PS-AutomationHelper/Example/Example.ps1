# This file contains an example Excution sequence to illustrate the usage of the module.

# Install the module

# Install-Module PS-AutomationHelper -Repository PSGallery

# #Import the module
# Import-Module PS-AutomationHelper -Force

Import-Module 'C:\repos\PS-AutomationHelper\PS-AutomationHelper\PS-AutomationHelper.psd1' -Force

# Define an new array of type [ExecutionStep[]]
[ExecutionStep[]]$ExecutionSteps = @()

# ExecutionStep can be created in multiple ways

# 1) Splatting:
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting?view=powershell-7.3
# Create a new execution step with a precondition
# This step will run normally, not be skipped (as Precondition ist $true), not produce any erorrs and be recovered if a later step produces
# a terminal error
$secondStepError

# Define a HashTable
$myFistInstallStep = @{
  Description = 'Will run with precondition -eq $true | Will be recovered' 
  Precondition    = { $true }
  ExecutionAction = { Write-Host 'Executing step 1 -> success' -ForegroundColor Green }
  RecoverAction   = { Write-Host 'Recovering step 1' -ForegroundColor Cyan }
  ErrorMessage        = 'Error Message'
}


# Create the step with New-ExecutionStep
$firstStep = New-ExecutionStep @myFistInstallStep

# Add the step to the array
$ExecutionSteps += $firstStep

# 2) Use parameters with New-ExecutionStep
# This step will run normally, not be skipped (as Precondition has not been set), not produce any erorrs and be recovered if a later step produces
# a terminal error

$secondStep = New-ExecutionStep `
  -Description 'Will run without precondition | Will be recovered.' `
  -ExecutionAction { Write-Host 'Executing step 2 -> success' -ForegroundColor Green } `
  -RecoverAction { Write-Host 'Recovering step 2' -ForegroundColor Cyan } `
  -ErrorMessage 'Error 2'

# Add the step to the array
$ExecutionSteps += $secondStep


# 3) Add directly to the array using Add-ExecutionStep

# This step will run, not be skipped, but produce a non-temrinal error and not be recovered as if a later step produces
# a terminal error as no RecoverAction is defined.

$ExecutionSteps = Add-ExecutionStep `
  -ExecutionStepList $ExecutionSteps `
  -Description 'Will run but produce a non-terminal error | Will not be recovered as no RecoverAction is defined..' `
  -ExecutionAction { Remove-Item c:\doesNotExist } `
  -RecoverAction { Write-Host 'Recovering step 3' -ForegroundColor Cyan } `
  -ErrorMessage 'Could not remove inexisting element'

# This step will be skipped, but would produce a temrinal. It will not be recovered as it was skipped.

$ExecutionSteps = Add-ExecutionStep `
  -Precondition { $false } `
  -ExecutionStepList $ExecutionSteps `
  -Description 'Will be skipped | Will not be recovered as the execution was skipped.' `
  -ExecutionAction { Remove-Item c:\doesNotExist } `
  -RecoverAction { Write-Hosts 'Recovering step 4' -ForegroundColor Cyan } `
  -ErrorMessage 'Could not remove inexisting element' `
  -TerminalError

# This step will run, not be skipped and will produce a terminal error causing the previous steps to be recovered if they have run..
$ExecutionSteps += New-ExecutionStep `
  -Description 'Executes with terminal error | Will be recovered with error.' `
  -ExecutionAction { Write-Host 'Bla' } `
  -RecoverAction { Write-Host 'Recovering step 4' -ForegroundColor Cyan } `
  -ErrorMessage 'Error 5 | Will be recovered' `
  -TerminalError

$stepAdd = @{ 
  Description       = 'Will run with precondition -eq $true | Will be recovered' 
  Precondition = { $true } 
  ExecutionAction = { Write-Host 'Executing step 1 -> success' -ForegroundColor Green } 
  RecoverAction = { Write-Host 'Recovering step 1' -ForegroundColor Cyan } 
  ErrorMessage = 'Error Message' 
  ExecutionStepList = $ExecutionSteps }
Add-ExecutionStep @stepAdd 

Invoke-Execution -ExecutionSteps $ExecutionSteps
