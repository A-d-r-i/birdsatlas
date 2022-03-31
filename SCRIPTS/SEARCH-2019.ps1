$list = Get-Content "./ID.txt"

foreach ($code in $list) {
#$code = '42510'
$id = ([xml](Get-Content "./ID.xml")).ID."id$code"

# search for not sighting from 2019
$TOTAL = Import-Csv -Path "./SPECIES/TOTAL/CSV/ALL-SPECIES-$id.csv" -delimiter ","
$result = $TOTAL | Where { $_.newcount -eq 0} 
$result | Out-File "SPECIESTEMP.txt"
$file = Get-Content "SPECIESTEMP.txt"
$file = $file -replace '\x1b\[[0-9;]*m' , ''
$file | Out-File "./SPECIES/2019/TXT/SPECIES-2019-$id.txt" -Encoding UTF8
$result | Export-Csv "SPECIES.csv" -Delimiter "," -NoTypeInformation -Encoding UTF8
(Get-Content "SPECIES.csv") | % {$_ -replace '"', ''} | Out-File "./SPECIES/2019/CSV/SPECIES-2019-$id.csv" -Fo -Encoding UTF8

}

$text = Get-Content dates.txt
$date = Get-Date -Format "dd/MM/yyyy"
$text = $text -replace "2019 : ([0-9]+/[0-9]+/[0-9]+)","2019 : $date" | Set-Content -Path dates.txt

Remove-Item "SPECIESTEMP.txt", "SPECIES.csv"

# git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - 2019"
git push -f
