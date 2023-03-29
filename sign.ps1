$filesToSign = Get-ChildItem .\PS-AutomationHelper -Recurse -Include ('*.ps1', '*.psm1', '*.psd1', '*.cs')
foreach($file in $filesToSign){
  Set-AuthenticodeSignature -Certificate (Get-ChildItem cert:\CurrentUser\my -codesigning) -FilePath $file.FullName
}