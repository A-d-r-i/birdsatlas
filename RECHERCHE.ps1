#$id = Read-Host -Prompt "Saisir l`'identifiant de la maille "
#$code = ([xml](Get-Content MAILLES.xml)).MAILLES.$id
$list = $list = Get-Content "ID.txt"

foreach ($code in $list) {
#$code = '42510'
$id = ([xml](Get-Content ID.xml)).ID."id$code"

# download of JSON
Invoke-WebRequest -Uri "https://oiseauxdefrance.org/api/v1/area/taxa_list/$code" -OutFile "./SPECIES/TOTAL/JSON/ODF-$id.json"
(Get-Content "./SPECIES/TOTAL/JSON/ODF-$id.json" -Encoding UTF8 | ConvertFrom-Json).all_period.last_obs | Out-File "lastobs.csv" -Encoding UTF8
(Get-Content "./SPECIES/TOTAL/JSON/ODF-$id.json" -Encoding UTF8 | ConvertFrom-Json).all_period.new_count | Out-File "newcount.csv" -Encoding UTF8
(Get-Content "./SPECIES/TOTAL/JSON/ODF-$id.json" -Encoding UTF8 | ConvertFrom-Json).all_period.old_count | Out-File "oldcount.csv" -Encoding UTF8
(Get-Content "./SPECIES/TOTAL/JSON/ODF-$id.json" -Encoding UTF8 | ConvertFrom-Json).common_name_fr | Out-File "name.csv" -Encoding UTF8

$name = Get-Content "name.csv" -Encoding UTF8
$lastobs = Get-Content "lastobs.csv" -Encoding UTF8
$newcount = Get-Content "newcount.csv" -Encoding UTF8
$oldcount = Get-Content "oldcount.csv" -Encoding UTF8

# build of TOTAL CSV
$loop = for ($i = 0; $i -lt $name.Length; ++$i) { $name[$i] + "," + $lastobs[$i] + "," + $newcount[$i] + "," + $oldcount[$i] }
$loop | Out-File "csvtemp.txt" -Encoding UTF8
Import-Csv "csvtemp.txt" -delimiter "," -Header frname , lastobs , newcount , oldcount | Export-Csv "./SPECIES/TOTAL/CSV/ALL-SPECIES-$id.csv" -Delimiter "," -NoTypeInformation -Encoding UTF8
(Get-Content "./SPECIES/TOTAL/CSV/ALL-SPECIES-$id.csv") | % {$_ -replace '"', ''} | Out-File "./SPECIES/TOTAL/CSV/ALL-SPECIES-$id.csv" -Fo -Encoding UTF8

# search for not sighting from 2019
$TOTAL = Import-Csv -Path "./SPECIES/TOTAL/CSV/ALL-SPECIES-$id.csv" -delimiter ","
$result = $TOTAL | Where { $_.newcount -eq 0} 
$result | Out-File "SPECIESTEMP.txt"
$file = Get-Content "SPECIESTEMP.txt"
$file = $file -replace '\x1b\[[0-9;]*m' , ''
$file | Out-File "./SPECIES/2019/TXT/SPECIES-2019-$id.txt" -Encoding UTF8
$result | Export-Csv "SPECIES.csv" -Delimiter "," -NoTypeInformation -Encoding UTF8
(Get-Content "SPECIES.csv") | % {$_ -replace '"', ''} | Out-File "./SPECIES/2019/CSV/SPECIES-2019-$id.csv" -Fo -Encoding UTF8

# compare with blanks
$BLANKS = Import-Csv -Path "BLANKS.csv" -delimiter ","
$BLANKS.Vernaculaire | ?{$TOTAL.frname -notcontains $_} | Out-File "./SPECIES/LIST/SPECIES-BLANKS-$id.txt"
## not found in BLANKS.csv
$TOTAL.frname | ?{$BLANKS.Vernaculaire -notcontains $_} | Out-File "./SPECIES/LIST/SPECIES-NF-$id.txt"

echo $id
#echo ''
#echo '------------------- ESPECES NON OBSERVEES DEPUIS 2019 ----------------------'
#echo $result.frname
#echo '----------------------------------------------------------------------------'
#echo ''

}

Remove-Item "name.csv", "lastobs.csv", "newcount.csv", "oldcount.csv", "csvtemp.txt", "SPECIESTEMP.txt", "SPECIES.csv"

# git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - MAILLES"
git push -f
