$pesterPreference = [PesterConfiguration]::Default
$pesterPreference.Debug.WriteDebugMessages = $false
$pesterPreference.Debug.WriteDebugMessagesFrom = 'Mock'

Write-Output $PesterPreference