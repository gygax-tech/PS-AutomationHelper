function Add-ExecutionStep {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ParameterSetName = 'newStep')]
    [Parameter(Mandatory = $true, ParameterSetName = 'ExecutionStep')]
    [ValidateNotNull()]
    [ExecutionStep[]]$ExecutionStepList,

    [Parameter(Mandatory = $true, ParameterSetName = 'newStep')]
    [ValidateNotNullOrEmpty()]
    [string]$Description,

    [Parameter(Mandatory = $true, ParameterSetName = 'newStep')]
    [ValidateNotNullOrEmpty()]
    [scriptblock]$ExecutionAction,

    [Parameter(Mandatory = $true, ParameterSetName = 'newStep')]
    [ValidateNotNullOrEmpty()]
    [string]$ErrorMessage,

    [Parameter(Mandatory = $false, ParameterSetName = 'newStep')]
    [ValidateNotNullOrEmpty()]
    [scriptblock]$Precondition,

    [Parameter(Mandatory = $false, ParameterSetName = 'newStep')]
    [ValidateNotNullOrEmpty()]
    [scriptblock]$RecoverAction,

    [Parameter(Mandatory = $false, ParameterSetName = 'newStep')]
    [Parameter(Mandatory = $false, ParameterSetName = 'ExecutionStep')]
    [ValidateNotNullOrEmpty()]
    [switch]$TerminalError,

    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, ParameterSetName = 'ExecutionStep')]
    [ValidateNotNullOrEmpty()]
    [ExecutionStep]$ExecutionStep
  )
  
  begin {
    if($PSCmdlet.ParameterSetName -eq 'newStep'){
      $ExecutionStep = [ExecutionStep]::new($Description, $ExecutionAction, $Precondition, $ErrorMessage, $RecoverAction, ($TerminalError.IsPresent))
    }
  }
  
  process {
    $ExecutionStepList += $ExecutionStep
  }
  
  end {
    return $ExecutionStepList
  }
}
