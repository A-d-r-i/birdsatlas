#$id = Read-Host -Prompt "Saisir l`'identifiant de la maille "
#$code = ([xml](Get-Content MAILLES.xml)).MAILLES.$id
$list = Get-Content "./ID.txt"

foreach ($code in $list) {
#$code = '42510'
$id = ([xml](Get-Content "./ID.xml")).ID."id$code"

echo $id

# download of JSON
Invoke-WebRequest -Uri "https://oiseauxdefrance.org/api/v1/area/taxa_list/$code" -OutFile "./SPECIES/TOTAL/JSON/ODF-$id.json"

}

$text = Get-Content dates.txt
$date = Get-Date -Format "dd/MM/yyyy"
$text = $text -replace "mailles : ([0-9]+/[0-9]+/[0-9]+)","mailles : $date" | Set-Content -Path dates.txt

# git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - MAILLES"
git push -f
