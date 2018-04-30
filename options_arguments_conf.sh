#! /bin/bash

# SKRIPT ZPRACOVAVA KONFIGURACNI SOUBOR; UKLADA DO PROMENNYCH HODNOTY V NEM UVEDENE

CONF_FILE="$1"

# Overeni prav a existence u konfiguracniho souboru
if [ ! -r "$CONF_FILE" -o ! -f "$CONF_FILE" ]; then
	echo "CHYBA: Soubor neexistuje nebo nemate dostatecna prava"
	exit 2
fi

# Odstraneni komentaru
eval $( sed 's/#.*$//g' "$CONF_FILE" |
# Odstraneni whitespaces, pridani rovnitek; eval pro prirazeni do promennych
sed 's/^[[:blank:]]*//g' | sed 's/[[:blank:]]*$//g' | grep -v '^$' |
sed 's/\ /=" /' | sed -E 's/[[:blank:]]+//' | sed 's/$/"/g'
) 2>/dev/null || err=1

# Overeni formatu konfiguracniho souboru
if [ $err -eq 1 ] 2>/dev/null; then
	echo "CHYBA: Konfiguracni soubor ma nespravny format!"
	exit 2
fi

# Funkce pro prepinac -v (verbose)
print_conf()
{
	# Vytazeni nazvu promennych z konfiguracniho s. a dotaz na jejich hodnoty
	declare -p $(echo $(
	sed 's/#.*$//g' "$CONF_FILE" | sed 's/^[[:blank:]]*//g'	| 
	grep -v '^$' | sed 's/[[:blank:]].*$//g')) |
	#Odstraneni retezce "declare -- "	
	cut -c 12-
}

print_conf

exit 0;

