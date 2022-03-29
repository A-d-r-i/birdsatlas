$list = Get-Content "./ID.txt"

foreach ($code in $list) {
#$code = '42510'
$id = ([xml](Get-Content "./ID.xml")).ID."id$code"

# compare with blanks
$TOTAL = Import-Csv -Path "./SPECIES/TOTAL/CSV/ALL-SPECIES-$id.csv" -delimiter ","
$BLANKS = Import-Csv -Path "./BLANKS.csv" -delimiter ","
$BLANKS.Vernaculaire | ?{$TOTAL.frname -notcontains $_} | Out-File "./SPECIES/LIST/SPECIES-BLANKS-$id.txt"
## not found in BLANKS.csv
$TOTAL.frname | ?{$BLANKS.Vernaculaire -notcontains $_} | Out-File "./SPECIES/LIST/SPECIES-NF-$id.txt"

}

# git and create tag
git config --local user.email "a-d-r-i@outlook.fr"
git config --local user.name "A-d-r-i"
git add .
git commit -m "[Bot] Update files - BLANKS"
git push -f
