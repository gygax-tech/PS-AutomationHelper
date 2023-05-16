function Invoke-Execution {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
  [CmdletBinding()]
  PARAM(
    [ValidateNotNull()]
    [ExecutionStep[]]$ExecutionSteps
  )
  Process {
    # Kontext in dem die Executeationsschritte ausgefuehrt werden.
    $ExecutionStepContext = [System.Collections.Generic.List[PSVariable]] @()
    $ExecutionStepContext.Add((New-Object PSVariable -ArgumentList 'ErrorActionPreference', 'Stop'))
    $ExecutionStepContext.Add((New-Object PSVariable -ArgumentList 'Error', $null))

    function Execute ([int]$currentStep) {
      $step = $ExecutionSteps[$currentStep]
      $step.Executed = $false
      $exception = $null
      $skipped = $false

      # only execute the step if the precondition is met ($skip --> (-not $execute))
      if ($null -ne $step.Precondition) {
        $skipped = (-not $step.Precondition.Invoke())
      }
      if (-not $skipped) {
        try {
          $result = $step.ExecutionAction.InvokeWithContext($null, $ExecutionStepContext) 
          $step.Success = $true
        }
        catch {
          $exception = $_.Exception
          $step.Success = $false
          $step.ExecutionError = $_

          Write-Warning "$($currentStep) -> '$($step.Description)' produced the following exception:`r`n'$($exception.InnerException.Message)'."
          if ($step.TerminalError) {
            Write-Verbose 'This is error is flagged as terminal. Undoing all changes..'
            $needsRecover = $true
          }
          else {
            Write-Verbose 'Continuing execution as error is non-terminal.'
          }
        }
      }
      else {
        $step.Executed = $false
        $step.Success = $true
        Write-Host "$($currentStep+[int]1). Skipped: $($step.Description) as precondition is met." -ForegroundColor Gray
      }
      if ($needsRecover) {
        Recover ($currentStep) # Undo Execution
      }
        
      else {
        $step.Executed = (-not $skipped)
        if ($currentStep + [int]1 -ge $ExecutionSteps.Count) { 
          Write-Host 'Execution finished successfully.' -ForegroundColor Green ; 
          return 
        } # Last Step
        Execute ($currentStep + [int]1) # Next Step
      }
    }
    function Recover ([int]$currentStep) {
      $step = $ExecutionSteps[$currentStep]
      if ($step.Executed -and $step.RecoverAction) {
        Write-Host "$($currentStep+[int]1). Undo: $($step.Description)" -ForegroundColor Yellow
        try {
          $result = $step.RecoverAction.InvokeWithContext($null, $ExecutionStepContext)
          if (($result -eq $false) -or ($result.length -and $result[0] -eq $false)) {
            throw "The step '$($step.RecoverAction.ToString())' returned an invalid result: ($result)."
          }
          $step.Recovered = $true

        }
        catch {
          Write-Warning 'The automatic recover action failed. Please undo this step manually.'
          $step.Recovered = $false
          Write-Error $_.Exception.Message
        }
      }
      if ($currentStep - [int]1 -lt 0) { Write-Host 'All changes have been undone.'; return } # Last Step
      Recover ($currentStep - [int]1) # Next Step
      return
    }    
    Execute 0
  }
}