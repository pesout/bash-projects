#! /bin/bash

# SKRIPT STAHUJE OBSAH WEBU http://boudy.info

ImgGet() # $1...ID stranky; $2...ID obrazku
{
    echo "http://boudy.info/"$(
    curl -s "http://boudy.info/obr.php?txt=cz&id=$1&obr=$2" |
    grep '<img class="obr"' |
    sed 's/.*src="//' |
    sed 's/".*//' )
}

test -e index.html && rm -rf index.html
test -e boudy_data && rm -rf boudy_data
mkdir boudy_data

echo "<!DOCTYPE HTML>" > index.html
echo "<html>" >> index.html
echo "<head>" >> index.html
echo "<meta http-equiv=\"Content-Language\" content=\"cs\">" >> index.html
echo "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">" >> index.html
echo "<title>$NADPIS</title>" >> index.html
echo "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">" >> index.html
echo "<style>" >> index.html
echo "body {background-color:#ecf0f1;font-size:13pt;}" >> index.html
echo "h1,h2,h3 {text-align:center;color:#0c2461;}" >> index.html
echo "h1 {border-bottom: 3px solid #0c2461;padding-bottom:27px;}" >> index.html
echo "a {color:#0c2461;}" >> index.html
echo "</style>" >> index.html
echo "</head>" >> index.html
echo "<body>" >> index.html
echo "<h1>Boudy</h1>" >> index.html
echo "<ul>" >> index.html

for ID in {1..2000}; do
    ERROR=$(curl -s http://boudy.info/bouda.php?id=$ID | grep -c "^Chyba při vyhledávání v databázi")
    if [ $ERROR -eq 0 ]; then
        echo $ID: OK
        curl -s "http://boudy.info/bouda.php?id=$ID" > /tmp/boudy_source.tmp
        tr '\n' ' ' < /tmp/boudy_source.tmp > /tmp/boudy.tmp

        curl -s "http://boudy.info/bouda.php?txt=cz&id=$ID&par=poz" > /tmp/boudy_pozn.tmp

        # NADPIS
        NADPIS=$( echo $(
        sed 's/.*class="nadpis">//' < /tmp/boudy.tmp |
        sed 's/<\/div>.*/\n/g'
        ))

        # PODNADPIS
        PODNADPIS=$( echo $(
        sed 's/.*class="podnadpis">//' < /tmp/boudy.tmp |
        sed 's/<\/div>.*/\n/g'
        ))

        # GPS
        GPS=$( echo $(
        sed -E 's/.*class="info_gps_." title=".{1,50}">//' < /tmp/boudy.tmp |
        sed 's/<\/span>.*/\n/g'
        ))

        # POSL_UPRAVA
        POSL_UPRAVA=$( echo $(
        grep 'Poslední\ úprava:' < /tmp/boudy_source.tmp |
        sed 's/.*(//' |
        sed 's/)//'
        ))

        # POCET OSOB
        OSOBY=$( echo $(
        sed -E 's/.*class="info_pocet" title=".{1,50}">//' < /tmp/boudy.tmp |
        sed 's/<\/div>.*/\n/g'
        ))

        # POCET OSOB V NOUZI
        OSOBY_NOUZE=$( echo $(
        sed -E 's/.*class="info_pocet_max" title=".{1,50}">//' < /tmp/boudy.tmp |
        sed 's/<\/div>.*/\n/g'
        ))

        # TYP
        TYP=$(
        grep -E 'class="info_ik_[0-9]"' < /tmp/boudy_source.tmp |
        sed 's/.*title="//' |
        sed 's/\.\.\.">//g'
        )

        # INFO
        INFO=$( echo "<ul>" $(
        grep -E 'class="info_ik" src' < /tmp/boudy_source.tmp |
        sed 's/.*title="//' |
        sed 's/\.\.\.">/<\/li>/g' |
        sed 's/^/<li>/g'
        echo "</ul>"
        ))

        # POZNAMKY
        POZNAMKY=$( echo $( echo $(
        nl /tmp/boudy_pozn.tmp |
        grep '[0-9][0-9]\.[0-9][0-9]\.[0-9][0-9][0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]$' |
        cut -c1-7
        ) | tr ' ' '\n' |
        while read line; do
            echo "<p>"
            echo "<strong>"
            head -$line < /tmp/boudy_pozn.tmp |
            tail -1
            echo "</strong> - "

            head -$(($line+3)) < /tmp/boudy_pozn.tmp |
            tail -1
            echo "</p>"
        done ))

        # POPIS
        POPIS=$(
        sed -n '/^Popis$/,/upravit_popis/ { //!p }' /tmp/boudy_source.tmp |
        head -n -1 |
        tail -n +2 |
        sed 's/\ class="popis_ul"//' |
        sed 's/\ class="popis_txt"//'
        )

        # VODA
        VODA=$(
        sed -n '/^Zdroj\ vody$/,/upravit_voda/ { //!p }' /tmp/boudy_source.tmp |
        head -n -1 |
        tail -n +2 |
        sed 's/\ class="popis_ul"//' |
        sed 's/\ class="popis_txt"//'
        )

        # NEJVHODNEJSI_DOBA
        NEJVHODNEJSI_DOBA=$(
        sed -n '/^Nejvhodnější\ doba\ návštěvy$/,/upravit_doba/ { //!p }' /tmp/boudy_source.tmp |
        head -n -1 |
        tail -n +2 |
        sed 's/\ class="popis_ul"//' |
        sed 's/\ class="popis_txt"//'
        )

        # PRISTUP
        PRISTUP=$(
        sed -n '/^Přístup$/,/upravit_pristup/ { //!p }' /tmp/boudy_source.tmp |
        head -n -1 |
        tail -n +2 |
        sed 's/\ class="popis_ul"//' |
        sed 's/\ class="popis_txt"//'
        )

        # OBRAZKY
        ID_OBR=1
        OBRAZKY=""
        IMG_URL=$(ImgGet $ID $ID_OBR)
        while [ true ]; do
            if [ $IMG_URL != "http://boudy.info/" ]; then
                wget --quiet $IMG_URL -P boudy_data
                OBRAZKY="<img src=\"$(echo $IMG_URL | sed 's/.*\///')\"  style=\"width:100%;\"><br> $OBRAZKY"
            else
                break
            fi
            ID_OBR=$(($ID_OBR+1));
            IMG_URL=$(ImgGet $ID $ID_OBR)
        done

        rm /tmp/boudy.tmp
        rm /tmp/boudy_source.tmp
        rm /tmp/boudy_pozn.tmp

        echo "<li><a href=\"boudy_data/$ID.html\">$NADPIS</a> ($TYP)</li>" >> index.html

        echo "<!DOCTYPE HTML>" > boudy_data/$ID.html
        echo "<html>" >> boudy_data/$ID.html
        echo "<head>" >> boudy_data/$ID.html
        echo "<meta http-equiv=\"Content-Language\" content=\"cs\">" >> boudy_data/$ID.html
        echo "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">" >> boudy_data/$ID.html
        echo "<title>$NADPIS</title>" >> boudy_data/$ID.html
        echo "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">" >> boudy_data/$ID.html
        echo "<style>" >> boudy_data/$ID.html
        echo "body {background-color:#ecf0f1;font-size:11pt;}" >> boudy_data/$ID.html
        echo "h1,h2,h3 {text-align:center;color:#0c2461;}" >> boudy_data/$ID.html
        echo "h3 {border-bottom: 2px solid #0c2461; border-top: 6px solid #0c2461; padding:10px;}" >> boudy_data/$ID.html
        echo "strong {color:#0c2461;}" >> boudy_data/$ID.html
        echo "td {padding:3px;}" >> boudy_data/$ID.html
        echo "table {margin-left:auto;margin-right:auto;border-top: 2px solid #0c2461;border-bottom: 2px solid #0c2461;margin-bottom:30px;}" >> boudy_data/$ID.html
        echo "</style>" >> boudy_data/$ID.html
        echo "</head>" >> boudy_data/$ID.html
        echo "<body>" >> boudy_data/$ID.html
        echo "<h1>$NADPIS</h1>" >> boudy_data/$ID.html
        echo "<h2>$PODNADPIS</h2>" >> boudy_data/$ID.html
        echo "<table><tr><td><strong>Typ&nbsp;</strong></td><td>&nbsp;$TYP</td></tr>" >> boudy_data/$ID.html
        echo "<tr><td><strong>Počet osob&nbsp;</strong></td><td>&nbsp;$OSOBY (v nouzi $OSOBY_NOUZE)</td></tr>" >> boudy_data/$ID.html
        echo "<tr><td><strong>GPS Souřadnice&nbsp;</strong></td><td>&nbsp;$GPS</td></tr>" >> boudy_data/$ID.html
        echo "<tr><td><strong>Poslední úprava&nbsp;</strong></td><td>&nbsp;$POSL_UPRAVA</td></tr></table>" >> boudy_data/$ID.html
        echo "<h3>Informace</h3><p>$INFO</p>" >> boudy_data/$ID.html
        echo "<h3>Popis</h3><p>$POPIS</p>" >> boudy_data/$ID.html
        echo "<h3>Zdroj vody</h3><p>$VODA</p>" >> boudy_data/$ID.html
        echo "<h3>Nejvhodnější doba návštěvy</h3><p>$NEJVHODNEJSI_DOBA</p>" >> boudy_data/$ID.html
        echo "<h3>Přístup</h3><p>$PRISTUP</p>" >> boudy_data/$ID.html
        echo "<h3>Poznámky</h3>$POZNAMKY" >> boudy_data/$ID.html
        echo "<br> $OBRAZKY" >> boudy_data/$ID.html
        echo "</body>" >> boudy_data/$ID.html
        echo "</html>" >> boudy_data/$ID.html
    else
        echo $ID: "NENALEZENO"
    fi
done

echo "</ul></body>" >> index.html
echo "</html>" >> index.html
