#

set -e
domain=kintm.gq
url=https://www.worldometers.info/coronavirus/index.php
mdfile=lovid20.md
echo ${mdfile%/*}

# -------------------------
# get the data ...
date=$(date +%D)
tic=$(date +%s)
qm0=$(ipfs add -Q -n $url)
echo tic: $tic
echo url: https://ipfs.blockringtm.ml/ipfs/$qm0
# -------------------------
if [ -e lovid.htm ]; then
mtime=$(stat -c "%Y" lovid.htm)
if expr $tic - $mtime \> 21600; then
 echo "info: tic - mtime > 21600"
 rm lovid.htm
else
 echo "reuse: lovid.htm $(stat -c '%y' lovid.htm)"
fi
fi
if [ ! -e lovid.htm ]; then
curl -s $url > lovid.htm
fi
qm=$(ipfs add -Q -n lovid.htm)
echo url: https://localhost:8080/ipfs/$qm
# -------------------------
# extract data
pandoc -f html -t markdown lovid.htm > lovid.md
# old way ...

if grep -q -e '^Switzerland$' lovid.md; then
echo '/Switzerland/+1,/Switzerland/+7p' | ed lovid.md | sed -e 's/,//' > lovid.dat
if tail -1 lovid.dat | grep -q "^[+0-9]" ; then
 tail -1 lovid.dat
  grep -e '^[+0-9]' lovid.dat > lovid.data
  mv lovid.data lovid.dat
fi
# new way (one-line table)
else
grep -e '^  \[*Switzerland' lovid.md | head -1 | sed -e 's/\[\(.*\)][^ ]*/\1/' -e 's/,//g' -e 's/   */\n/g' | tail +3 | tee lovid.dat
fi
n=$(wc -l lovid.dat | cut -d' ' -f1)
echo n: $n
if expr "$n" \< 10 ; then
paste -d' ' - lovid.dat <<EOT | eyml > lovid.yml
cases:
d:
upgraded:
a:
cr:
dy:
dp:
fdate:
nextone:
EOT
else
if expr "$n" = 10 ; then
paste -d' ' - lovid.dat <<EOT | eyml > lovid.yml
cases:
nc:
d:
nd:
upgraded:
a:
cr:
dy:
dp:
fdate:
EOT
else
paste -d' ' - lovid.dat <<EOT | eyml > lovid.yml
cases:
nc:
d:
nd:
upgraded:
a:
cr:
dy:
dp:
fdate:
EOT
fi
fi

eval $(cat lovid.yml)
echo "$tic,$upgraded" >> lovid.csv
kst2 --png lovid.png lovid.kst
qmd=$(ipfs add -Q -w lovid.dat lovid.csv lovid.png)
echo url: https://yoogle.com:8197/ipfs/$qmd
rm lovid.yml
# -------------------------
echo "- \\[$date]: ${upgraded}/${cases} cases [$qm0](https://cloudflare-ipfs.com/ipfs/$qm0) [data](/ipfs/$qmd/lovid.dat),[csv](/ipfs/$qmd/lovid.csv)" >> lovid20u.md
grep -v '^- ' lovid20u.md > $mdfile
grep '^- ' lovid20u.md | sort -r | uniq >> $mdfile
# -------------------------
# filing
#cd ${mdfile%/*}
pandoc -f markdown -t html lovid20.md -o lovid20.html
pandoc -f markdown -t html $HOME/pwiki/myjourney.md -o myjourney.html
qm=$(ipfs add -Q -w lovid20.html lovid.* myjourney.html $HOME/pwiki/myjourney.md)

eval $(perl -S fullname.pl -a $qm | eyml)
git config user.name "$fullname"
git config user.email $user@$domain
echo "gituser: $(git config user.name) <$(git config user.email)>"

git add $mdfile lovid20u.md lovid.md lovid.dat lovid.csv lovid.png
pwd
cat > README.md <<EOF
# README: Humanity Love Upgrade daily status in Switzerland ...

## on $(date +"%D %T") ([snapshot](https://ipfs.io/ipfs/$qm))

 $upgraded souls have been upgraded with the LovID20 download

last update : <https://ipfs.blockringtm.ml/ipfs/$qm/lovid20.html>

<br>
+Michel

--- 

Every Sunday: 1:30pm 1:45pm Meditation & OM chanting ([#OMEKSAATH][OM]) CET
https://www.facebook.com/events/138981234204300

TODAY AND ALL THE FOLLOWING DAYS : AT [12:30H AND 21:00H][CLAP]
to be solidaire and to encourage our medical workers for their protection and service,
lets' get out on our balcony or at our windows and clap to express our immense gratitude
Please pass this message arround and take care of yourself and love ones.

[OM]: https://qwant.com/?q=%26g+%23OMEKSAATH
[CLAP]: https://www.facebook.com/mgcombs/posts/10223045570354511?__cft__[0]=AZU1uoBTRJPo_ZEqs8vur5Vri1R96Mio1M-vFXGeuWxFhfQHMHY6_zYneCuXuez2Ojcj9K2Ph7AHwHYQvsmxphJqN-KWkpAuTph-dTy5h9pGEE-zRT6rqOZx5RfWRscw2vY&__tn__=%2CO%2CP-R

---

 ![charts](lovid.png)

 csv file [lovid.csv](lovid.csv)<br>
 data file [lovid.dat](lovid.dat)

sources:
  - <https://twitter.com/BAG_OFSP_UFSP>
  - <https://michel47.github.io/lovid20>
  - <https://github.com/michel47/lovid20>
  - <https://duckduckgo.com/?q=progression+lovid20>
  - <https://gateway.ipfs.io/ipfs/$qm0>
  - <https://gateway.ipfs.io/ipfs/$qm1>
  - <https://gateway.ipfs.io/ipfs/$qm>
  
EOF
git add README.md myjourney.html
git status -uno .
datetime=$(date +"%D %T")
git commit -a -m "Humanity Love Upgrade status on $datetime"
git push
echo $tic: $qm >> $HOME/etc/mutables/lovid.log
# -------------------------
echo "url: https://michel47.github.io/lovid20"
