$pConfig = @{
  Run          = @{
    Path = "${env:MODULE_BASE_PATH}\Tests"
  }
  Should       = @{
    ErrorAction = 'Continue'
  }
  CodeCoverage = @{
    Path           = "${env:MODULE_BASE_PATH}\Public"
    OutputFormat   = 'JaCoCo'
    OutputEncoding = 'UTF8'
    OutputPath     = ${env:PESTER_COVERAGE_XML}
    Enabled        = $true
  }
  TestResult   = @{
    OutputPath     = ${env:PESTER_RESULTS_XML}
    OutputFormat   = 'NUnitXml'
    OutputEncoding = 'UTF8'
    Enabled        = $true
  }
}
Write-Output $pConfig