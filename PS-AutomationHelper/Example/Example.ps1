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

# SIG # Begin signature block
# MIIPFwYJKoZIhvcNAQcCoIIPCDCCDwQCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCBC+HCpguoKZ2v
# 00UlI5JvAInC3g4pX7RiGkNLSAk7CqCCDBQwggXqMIIE0qADAgECAhBb43g/0Jux
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
# DQEJBDEiBCBE5b3qcfomeILP9ot25adXFgdoRsVn6fer4ENjQH6BsjANBgkqhkiG
# 9w0BAQEFAASCAQALqms5bT7vFAXFG6wMo1Dyfk/sXQ0rycYNN4W4iK3F5xnNAnaz
# i0eequhXm6SkxCfvGrFGUYUgKvn20myqDV4yVF/vfN1nj/dGAo7FHNn0nPw7bYHk
# lSCQKpx8ivKivOROxa3b9m6EWc/k2VX38K2KW7djmqK4heAMxdDh/I52fEiq5Ul2
# XzwZQoEYd90DmmG9GHM67eaIr2wT+rRVslEKTHIIw4+Nagru4gSReE7Nc2wml/f+
# Pu+pwaCuN4r13KWMJ6eNJDv7/qGZ/mDOSSnZDFMQOJYQ792+inbaNvD7CyeoYOPu
# XzlXBJA8vJe0gJJnnAv0W1sBEnZRQUuoSG9V
# SIG # End signature block
