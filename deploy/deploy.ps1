$FileTypes = @('lua','txt','xml')
$Files = @()
$ModName = "CrownPointerThing"
$ModDir = "$env:USERPROFILE\Documents\Elder Scrolls Online\live\AddOns\$ModName"
Remove-Item -Path $ModDir -Recurse
New-Item -Path $ModDir -itemtype directory -force
foreach($FileType in $FileTypes) {
  $FileName = "./$ModName.$FileType"
  Copy-Item "$FileName" -Destination "$ModDir"
  Write-Host "Copied $FileName to $ModDir"
}
foreach($File in $Files) {
  Copy-Item $File -Destination "$ModDir"
  Write-Host "Copied $File to $ModDir"
}