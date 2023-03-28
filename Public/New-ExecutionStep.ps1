function New-ExecutionStep {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$StepDescription,

    [Parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [scriptblock]$ExecutionAction,

    [Parameter(Mandatory = $false)]
    [scriptblock]$Precondition,
    
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Errormsg,
    
    [Parameter(Mandatory = $false)]
    [switch]$TerminalError,
    
    [Parameter(Mandatory = $false)]
    [scriptblock]$RecoverAction
  )

  $ExecutionStep = [ExecutionStep]::new()
  
  $ExecutionStep.StepDescription = $StepDescription
  $ExecutionStep.ExecutionAction = $ExecutionAction
  $ExecutionStep.Precondition = $Precondition
  $ExecutionStep.ErrorMsg = $ErrorMsg
  $ExecutionStep.RecoverAction = $RecoverAction
  $ExecutionStep.TerminalError = $TerminalError.IsPresent

  return $ExecutionStep
}