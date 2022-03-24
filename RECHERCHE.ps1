#$id = Read-Host -Prompt "Saisir l`'identifiant de la maille "
#$code = ([xml](Get-Content MAILLES.xml)).MAILLES.$id
$list = $list = Get-Content ID.txt

#foreach ($code in $list) {
$code = '42510'
$id = ([xml](Get-Content ID.xml)).ID."id$code"

Invoke-WebRequest -Uri "https://oiseauxdefrance.org/api/v1/area/taxa_list/$code" -OutFile "odf.json"
(Get-Content 'odf.json' -Encoding UTF8 | ConvertFrom-Json).all_period.last_obs | Out-File lastobs.csv -Encoding UTF8
(Get-Content 'odf.json' -Encoding UTF8 | ConvertFrom-Json).all_period.new_count | Out-File newcount.csv -Encoding UTF8
(Get-Content 'odf.json' -Encoding UTF8 | ConvertFrom-Json).all_period.old_count | Out-File oldcount.csv -Encoding UTF8
(Get-Content 'odf.json' -Encoding UTF8 | ConvertFrom-Json).common_name_fr | Out-File name.csv -Encoding UTF8

$name = Get-Content name.csv -Encoding UTF8
$lastobs = Get-Content lastobs.csv -Encoding UTF8
$newcount = Get-Content newcount.csv -Encoding UTF8
$oldcount = Get-Content oldcount.csv -Encoding UTF8

$loop = for ($i = 0; $i -lt $name.Length; ++$i) { $name[$i] + "," + $lastobs[$i] + "," + $newcount[$i] + "," + $oldcount[$i] }
$loop | Out-File csvtemp.txt -Encoding UTF8
Import-Csv "csvtemp.txt" -delimiter "," -Header frname , lastobs , newcount , oldcount | Export-Csv SPECIESTEMP.csv -Delimiter "," -NoTypeInformation -Encoding UTF8
$search = Import-Csv -Path 'SPECIESTEMP.csv' -delimiter ","
$result = $search | Where { $_.newcount -eq 0} 
$result | Out-File ./SPECIES/TXT/SPECIES-$id.txt -Encoding UTF8
$result | Export-Csv ./SPECIES/CSV/SPECIES-$id.csv -Delimiter "," -NoTypeInformation -Encoding UTF8

echo $id
#echo ''
#echo '------------------- ESPECES NON OBSERVEES DEPUIS 2019 ----------------------'
#echo $result.frname
#echo '----------------------------------------------------------------------------'
#echo ''

#}

Remove-Item odf.json, name.csv, lastobs.csv, newcount.csv, oldcount.csv, csvtemp.txt, SPECIESTEMP.csv

# git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - MAILLES"
git push -f
