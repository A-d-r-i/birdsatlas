$list = Get-Content "./ID.txt"

foreach ($code in $list) {
#$code = '42510'
$id = ([xml](Get-Content "./ID.xml")).ID."id$code"

(Get-Content "./SPECIES/TOTAL/JSON/ODF-$id.json" -Encoding UTF8 | ConvertFrom-Json).common_name_fr | Out-File "name.csv" -Encoding UTF8
(Get-Content "./SPECIES/TOTAL/JSON/ODF-$id.json" -Encoding UTF8 | ConvertFrom-Json).all_period.last_obs | Out-File "lastobs.csv" -Encoding UTF8
(Get-Content "./SPECIES/TOTAL/JSON/ODF-$id.json" -Encoding UTF8 | ConvertFrom-Json).all_period.new_count | Out-File "newcount.csv" -Encoding UTF8
(Get-Content "./SPECIES/TOTAL/JSON/ODF-$id.json" -Encoding UTF8 | ConvertFrom-Json).all_period.old_count | Out-File "oldcount.csv" -Encoding UTF8

$name = Get-Content "name.csv" -Encoding UTF8
$lastobs = Get-Content "lastobs.csv" -Encoding UTF8
$newcount = Get-Content "newcount.csv" -Encoding UTF8
$oldcount = Get-Content "oldcount.csv" -Encoding UTF8

# build of TOTAL CSV
$loop = for ($i = 0; $i -lt $name.Length; ++$i) { $name[$i] + "," + $lastobs[$i] + "," + $newcount[$i] + "," + $oldcount[$i] }
$loop | Out-File "csvtemp.txt" -Encoding UTF8
Import-Csv "csvtemp.txt" -delimiter "," -Header frname , lastobs , newcount , oldcount | Export-Csv "./SPECIES/TOTAL/CSV/ALL-SPECIES-$id.csv" -Delimiter "," -NoTypeInformation -Encoding UTF8
(Get-Content "./SPECIES/TOTAL/CSV/ALL-SPECIES-$id.csv") | % {$_ -replace '"', ''} | Out-File "./SPECIES/TOTAL/CSV/ALL-SPECIES-$id.csv" -Fo -Encoding UTF8

}

Remove-Item "name.csv", "lastobs.csv", "newcount.csv", "oldcount.csv", "csvtemp.txt"

# git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - TOTAL"
git push -f
