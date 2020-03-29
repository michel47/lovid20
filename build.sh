#

pandoc -f markdown -t html index.md -o index.html
surge --domain lovid20.surge.sh .
xdg-open https://lovid20.surge.sh
