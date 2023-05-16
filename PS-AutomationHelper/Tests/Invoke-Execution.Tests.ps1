BeforeAll {
  . $PSCommandPath.Replace('.Tests.ps1', '.ps1').Replace('Tests', 'Public').Replace('Tests', 'Public')
}

Import-Module "$(Split-Path $PSScriptRoot)\PS-AutomationHelper.psd1" -Force

InModuleScope PS-AutomationHelper {
  Describe 'Invoke-Execution.ps1' {
    BeforeEach {
      $testExecutionSteps = @()
      $testExecutionSteps += New-ExecutionStep `
        -Description 'Executes successfully with no precondition | Will be recovered' `
        -ExecutionAction { Write-Host 'Executing step 1 -> success' -ForegroundColor Green } `
        -RecoverAction { Write-Host 'Recovering step 1' -ForegroundColor Cyan } `
        -ErrorMessage 'Error 1'
      
      $testExecutionSteps += New-ExecutionStep `
        -Description 'Executes successfully with precondition equals $true | Will not be recovered (no action defined)' `
        -Precondition { 1 -eq 1 } `
        -ExecutionAction { Write-Host 'Executing step 2 -> success' -ForegroundColor Green } `
        -ErrorMessage 'Error 2'

      $testExecutionSteps += New-ExecutionStep `
        -Description 'Does not execute as precondition is $false | Will not be recovered because skipped.' `
        -Precondition { 1 -eq 2 } `
        -ExecutionAction { Write-Host 'Executing step 3 -> not run' -ForegroundColor Green } `
        -RecoverAction { Writes-Host 'Recovering step 3' -ForegroundColor Cyan } `
        -ErrorMessage 'Error 3'

      $testExecutionSteps += New-ExecutionStep `
        -Description 'Executes correctly with a non terminal error | Will be recovered with error.' `
        -ExecutionAction { Write-Hosts 'Executing step 4 -> not run' -ForegroundColor Green } `
        -RecoverAction { Write-Hosts 'Recovering step 4' -ForegroundColor Cyan } `
        -ErrorMessage 'Error 4 | Will be recovered'
    }

    It 'Correctly executes install steps.' {
      Invoke-Execution -ExecutionSteps $testExecutionSteps 
      $testExecutionSteps[0].Executed | Should -BeTrue 
      $testExecutionSteps[1].Executed | Should -BeTrue 
      $testExecutionSteps[2].Executed | Should -BeFalse 
      $testExecutionSteps[3].Executed | Should -BeTrue
    }

    It 'Handles errors correctly.' {
      Invoke-Execution -ExecutionSteps $testExecutionSteps 
      $testExecutionSteps[0].Success | Should -BeTrue 
      $testExecutionSteps[1].Success | Should -BeTrue 
      $testExecutionSteps[2].Success | Should -BeTrue 
      $testExecutionSteps[3].Success | Should -BeFalse
    }

    It 'Correctly executes recover actions' {
      $testExecutionSteps += New-ExecutionStep `
        -Description 'Executes with terminal error | Will be recovered with error.' `
        -ExecutionAction { Write-Hosts 'Executing step 4 -> not run' -ForegroundColor Green } `
        -RecoverAction { Write-Host 'Recovering step 4' -ForegroundColor Cyan } `
        -ErrorMessage 'Error 5 | Will be recovered' `
        -TerminalError
      Invoke-Execution -ExecutionSteps $testExecutionSteps 
      $testExecutionSteps[0].Recovered | Should -BeTrue
      $testExecutionSteps[1].Recovered | Should -BeFalse
      $testExecutionSteps[2].Recovered | Should -BeFalse
      $testExecutionSteps[3].Recovered | Should -BeFalse

    }
  }
}