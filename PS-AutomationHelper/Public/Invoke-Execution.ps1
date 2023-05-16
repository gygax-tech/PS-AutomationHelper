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
# SIG # Begin signature block
# MIIPFwYJKoZIhvcNAQcCoIIPCDCCDwQCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCqkouQD/qRisQD
# jmNAYWnKnU6uINqDvCDmCEoQb3MEHKCCDBQwggXqMIIE0qADAgECAhBb43g/0Jux
# +D5VsO4a+HT+MA0GCSqGSIb3DQEBCwUAMIGRMQswCQYDVQQGEwJHQjEbMBkGA1UE
# CBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQK
# ExFDT01PRE8gQ0EgTGltaXRlZDE3MDUGA1UEAxMuQ09NT0RPIFJTQSBFeHRlbmRl
# ZCBWYWxpZGF0aW9uIENvZGUgU2lnbmluZyBDQTAeFw0yMTAxMjcwMDAwMDBaFw0y
# NDAxMjcyMzU5NTlaMIHnMRgwFgYDVQQFEw9DSEUtMTA0LjY5NS4zNDExEzARBgsr
# BgEEAYI3PAIBAxMCQ0gxHTAbBgNVBA8TFFByaXZhdGUgT3JnYW5pemF0aW9uMQsw
# CQYDVQQGEwJDSDENMAsGA1UEEQwEODU3NTEQMA4GA1UECAwHVGh1cmdhdTEUMBIG
# A1UEBwwLQsO8cmdsZW4gVEcxHTAbBgNVBAkMFFdlaW5mZWxkZXJzdHJhc3NlIDMy
# MRkwFwYDVQQKDBBSby1vdCBTZXJ2aWNlIEFHMRkwFwYDVQQDDBBSby1vdCBTZXJ2
# aWNlIEFHMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvjqYw0hZgADB
# btihqrXsaYCmSYXKrTjtqMNGZKFE4l8p653Y6N8v2UynGcGbNJDLmI6I9hwiOEFS
# 1LjDdTvYFPZA7MiJYODo/5s7qk2DxjFQLQWx+rGbjKwZLrYe1hJYonwMSnk8haiE
# hIegTkbRXS0+Vyi9fq71wbgJN6p2RWgHDzhcH5hHo4Qg2FWhI6vOn2jwjZboRlDf
# +99ZIwzhfLuTdMI8umO+dukqjXQyvW63DF8ttA9DWK1i0nhksFglYi0xBGKnv9FQ
# Egpc6Oz7qRa6hK4cra1CdZKJtbx3Hr4zgL4XYgjIVeYbZiXKNMNd2I8ivvmXazMK
# sCy6aGoXMwIDAQABo4IB5DCCAeAwHwYDVR0jBBgwFoAU34/zIAzpyqYE2FtYNyo9
# q0bcg0kwHQYDVR0OBBYEFAtZUwulecqcvH0JlDR1vpsOelAfMA4GA1UdDwEB/wQE
# AwIHgDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMBEGCWCGSAGG
# +EIBAQQEAwIEEDBJBgNVHSAEQjBAMDUGDCsGAQQBsjEBAgEGATAlMCMGCCsGAQUF
# BwIBFhdodHRwczovL3NlY3RpZ28uY29tL0NQUzAHBgVngQwBAzBVBgNVHR8ETjBM
# MEqgSKBGhkRodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9DT01PRE9SU0FFeHRlbmRl
# ZFZhbGlkYXRpb25Db2RlU2lnbmluZ0NBLmNybDCBhgYIKwYBBQUHAQEEejB4MFAG
# CCsGAQUFBzAChkRodHRwOi8vY3J0LmNvbW9kb2NhLmNvbS9DT01PRE9SU0FFeHRl
# bmRlZFZhbGlkYXRpb25Db2RlU2lnbmluZ0NBLmNydDAkBggrBgEFBQcwAYYYaHR0
# cDovL29jc3AuY29tb2RvY2EuY29tMC0GA1UdEQQmMCSgIgYIKwYBBQUHCAOgFjAU
# DBJDSC1DSEUtMTA0LjY5NS4zNDEwDQYJKoZIhvcNAQELBQADggEBAFsHocKyhiZL
# bXE+5oeBXlNH7qA6JxnsGQMBwbL/niiOMqkenpmFhl7vEVkyT/Ci/MrGHwGj6S1r
# X9unl2dMlwsElV/IkZNGn0xDNZAyN0bNd2M9zT2TFHyKKg/p8yY7N8WSGAh+Dokv
# 2Ca6dpLKsQ7btkAlztc26nkKgjxWdIrIpLY/im2EuGD/CMSkRKEYtXSAuDMUsMH1
# T36RVR93flXA9Q02scFZdXeIlFAlFTr4zPit6IK9UCbWbRynjzwUq+ik9RbyiYYY
# 5tRkS0mDgAgg0XY73wcxwBW2jW6GczcUa+LNyp/fHRTZJTeiF11KQLMSdZQHstXM
# eOD0cz+RuGYwggYiMIIECqADAgECAhBt1HLrAq4EBuPdhD9f4UXhMA0GCSqGSIb3
# DQEBDAUAMIGFMQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVz
# dGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRl
# ZDErMCkGA1UEAxMiQ09NT0RPIFJTQSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTAe
# Fw0xNDEyMDMwMDAwMDBaFw0yOTEyMDIyMzU5NTlaMIGRMQswCQYDVQQGEwJHQjEb
# MBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRow
# GAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDE3MDUGA1UEAxMuQ09NT0RPIFJTQSBF
# eHRlbmRlZCBWYWxpZGF0aW9uIENvZGUgU2lnbmluZyBDQTCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBAIr9vUPwPchVH/NZivBatNyT0WQVSoqEpS3LJvjg
# RTijuQHFTxMIWdAxVMrNkGGjPizyTRVc1O7DaiKXSNEGQzQJmcnPMMSfRP1WnO7M
# 54O5gc3I2gscEkj/b6LsxHXLCXDPUeW7i5+qvXgGfZXWYYH22lPHrJ2zALoe1L5A
# YgmZgz1F3U1llQTM/PrHW3riLgw9VTVXNUiJifK5VqVLUBsc3piQvfMu3Iip8XWb
# qD6iBdlBte93rRfAWvWj202f0cSxe4O17hCUKy5yrr7vlSmcUmLFLG0i931EehBf
# Y5NpTdl9spqxTrVZv/+F+72s7OErpuMsLOjZbttfTRd4y1MCAwEAAaOCAX4wggF6
# MB8GA1UdIwQYMBaAFLuvfgI9+qbxPISOre44mOzZMjLUMB0GA1UdDgQWBBTfj/Mg
# DOnKpgTYW1g3Kj2rRtyDSTAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB
# /wIBADATBgNVHSUEDDAKBggrBgEFBQcDAzA+BgNVHSAENzA1MDMGBFUdIAAwKzAp
# BggrBgEFBQcCARYdaHR0cHM6Ly9zZWN1cmUuY29tb2RvLmNvbS9DUFMwTAYDVR0f
# BEUwQzBBoD+gPYY7aHR0cDovL2NybC5jb21vZG9jYS5jb20vQ09NT0RPUlNBQ2Vy
# dGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwcQYIKwYBBQUHAQEEZTBjMDsGCCsGAQUF
# BzAChi9odHRwOi8vY3J0LmNvbW9kb2NhLmNvbS9DT01PRE9SU0FBZGRUcnVzdENB
# LmNydDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuY29tb2RvY2EuY29tMA0GCSqG
# SIb3DQEBDAUAA4ICAQBmTuy3FndvEegbXWpO2fKLbLFWKECLwDHEmUgjPfgO6ICX
# 720gCx8TxIb7FzQV4Y5U98K4AHMV4CjZ2rr6glTC9+u/wzbQMJ/loRyU3+986PYs
# eKKszyZqFaEVMdYxNJi9U0/EhIOjxJZcPdj+1vlU/2eTbfg+K2ssogh8VkiBMhiy
# bqyQwdvk3jmLhuXHGEBZpN+WR7qyf7H4Vw+FgHQ4DjpYYh7+UuPmrlMJhv6Pm9tW
# VswHsInBBPFTC2xvd+yyH+z2W0BDYA8bqxhUtBAEjvgO6cuDsXryNE5qVEzpgyrp
# sDAlHM5ijg7rheYp/rFK4/KuPJH1TKG+yBcOXLtCTeMaipLNPiB+3el1seofdFye
# VMKUN7Jh3QcWWX+WgBbgmbXSbrDJIwYVrNEj9DOLznXwwYbT/+Eu+pBP/kb5u9tP
# u7f+0Q0rBPHS0ZWFLIouuIVW8sOEUqHpM7HrUMihsJ/jw4s6h57nVdPTbTQXMA1o
# IgvVue1zNXLD7ac3zeNDrkXNNL8oyodi7UOkr/rLMcshWGFGXrbGeqYeUyqo+FxR
# HzpaEA8owOR0i3TGBKr4SyYoCjKJ250qYHFqw5ZOFrljv2GVZ4xLLruwToPpTTHl
# jici9Twme0SR09Ra8NN89Di+FJqZDouxW+rkiw8RnXdCghxcOtTaq4gvjVcwVDGC
# AlkwggJVAgEBMIGmMIGRMQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBN
# YW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0Eg
# TGltaXRlZDE3MDUGA1UEAxMuQ09NT0RPIFJTQSBFeHRlbmRlZCBWYWxpZGF0aW9u
# IENvZGUgU2lnbmluZyBDQQIQW+N4P9Cbsfg+VbDuGvh0/jANBglghkgBZQMEAgEF
# AKCBhDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgor
# BgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqGSIb3
# DQEJBDEiBCATgMV0INCPlCOR9y1WrQWLDVZVYmaOiqCvheND+aAR0TANBgkqhkiG
# 9w0BAQEFAASCAQC7JhUZaH2Zppz7w0tVPAI6UTRJVFFmIznS31donp05JwR0lLAy
# aTJeTPIGqOv/IgTgJmjnPdDugbBjmWKE2ikc/kcQJIJogF+EbumbaH8LI2NmhOfP
# NF9aC+dJqHjL+XZbFX0D/XhPR+Tq23DIqrJ1fJTIemKopS+hrIWdCg3ctBkXEUZz
# AREWfAZn+Tk5VJ8QLgpl17ygqAsk7CgKpfMic33ckbbmhW6IBpYBPyZl13WEOSJm
# 8diHUdmzqx0sNtbgY+mamoKwNnauhZPu6UNSXPv72uE+ke64SSMizWiG6syqCa8t
# a13PbaFnoRseQ/1uQDhTusYKGkkBg7KTX5Ru
# SIG # End signature block
