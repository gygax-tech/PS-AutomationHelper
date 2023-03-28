Write-Verbose 'Importing Functions'
$functionsDirectory = "$PSScriptRoot\public\*.ps1"
$functions = Get-ChildItem $functionsDirectory
$filesToImport = $functions

foreach ($file in ($filesToImport)) {
  Write-Verbose "Importing $($file.Name)."
  . $file.FullName
}

$classes = Get-ChildItem -Path "$PSScriptRoot\Public\Classes\*.cs"
$classes | ForEach-Object {
  $rawText = Get-Content $_.FullName -Raw
  Add-Type -TypeDefinition $rawText
}
$accelerators = [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
$accelerators::Add('ExecutionStep', 'PS.Automation.Helper.ExecutionStep')
