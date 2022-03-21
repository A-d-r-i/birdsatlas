#$id = Read-Host -Prompt "Saisir l`'identifiant de la maille "
#$code = ([xml](Get-Content MAILLES.xml)).MAILLES.$id
$list = $list = Get-Content ID.txt

#foreach ($code in $list) {
$code = '42510'
$id = ([xml](Get-Content ID.xml)).ID."id$code"

Invoke-WebRequest -Uri "https://oiseauxdefrance.org/api/v1/area/taxa_list/$code" -OutFile "odf.json"
(Get-Content 'odf.json' -Encoding UTF8 | ConvertFrom-Json).all_period.new_count | Out-File count.csv -Encoding UTF8
(Get-Content 'odf.json' -Encoding UTF8 | ConvertFrom-Json).common_name_fr | Out-File name.csv -Encoding UTF8

$count = Get-Content count.csv -Encoding UTF8
$name = Get-Content name.csv -Encoding UTF8

$loop = for ($i = 0; $i -lt $count.Length; ++$i) { $count[$i] + ";" + $name[$i] }
$loop | Out-File csvtemp1.txt -Encoding UTF8
Import-Csv csvtemp1.txt -delimiter ";" -Header newcount , frname | Export-Csv csvtemp2.csv -Delimiter ";" -NoTypeInformation -Encoding UTF8
$search = Import-Csv -Path 'csvtemp2.csv' -delimiter ";"
$result = $search | Where { $_.newcount -eq 0} 
$result | Out-File ./SPECIES/TXT/SPECIES-$id.txt -Encoding UTF8
echo ''
echo '------------------- ESPECES NON OBSERVEES DEPUIS 2019 ----------------------'
echo $result.frname
echo '----------------------------------------------------------------------------'
echo ''

$txt = Get-Content -path ./SPECIES/TXT/SPECIES-$id.txt -Raw
$txt = $txt -replace '([0-9]+)        ','$1;'
$txt = $txt -replace 'newcount frname',''
$txt = $txt -replace '\n-------- -------',''
$txt = $txt -replace '^$',''

$txt | Out-File SPECIES1.txt -Encoding UTF8 
Import-Csv SPECIES1.txt -delimiter ";" -Header newcount , frname | Export-Csv ./SPECIES/CSV/SPECIES-$id.csv -Delimiter ";" -NoTypeInformation -Encoding UTF8
#}

# git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - MAILLES"
git push -f

Remove-Item odf.json, count.csv, name.csv, csvtemp1.txt, csvtemp2.csv, SPECIES1-$id.txt

