function New-ExecutionStep {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [Alias('StepDescription')]
    [ValidateNotNullOrEmpty()]
    [string]$Description,

    [Parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [scriptblock]$ExecutionAction,

    [Parameter(Mandatory = $false)]
    [scriptblock]$Precondition,
    
    [Parameter(Mandatory = $true)]
    [Alias('ErrorMsg')]
    [ValidateNotNullOrEmpty()]
    [string]$ErrorMessage,
    
    [Parameter(Mandatory = $false)]
    [switch]$TerminalError,
    
    [Parameter(Mandatory = $false)]
    [scriptblock]$RecoverAction
  )

  $ExecutionStep = [ExecutionStep]::new()
  
  $ExecutionStep.Description = $Description
  $ExecutionStep.ExecutionAction = $ExecutionAction
  $ExecutionStep.Precondition = $Precondition
  $ExecutionStep.ErrorMessage = $ErrorMessage
  $ExecutionStep.RecoverAction = $RecoverAction
  $ExecutionStep.TerminalError = $TerminalError.IsPresent

  return $ExecutionStep
}