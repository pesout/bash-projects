#! /bin/bash

# THIS SCRIPT PROCESSES A CONF FILE AND STORES VARIABLE VALUES FROM THE FILE

CONF_FILE="$1"

# Permissions and existence check (conf file)
if [ ! -r "$CONF_FILE" -o ! -f "$CONF_FILE" ]; then
	echo "CHYBA: Soubor neexistuje nebo nemate dostatecna prava"
	exit 2
fi

# Comments deletion
eval $( sed 's/#.*$//g' "$CONF_FILE" |
# Odstraneni whitespaces, pridani rovnitek; eval pro prirazeni do promennych
sed 's/^[[:blank:]]*//g' | sed 's/[[:blank:]]*$//g' | grep -v '^$' |
sed 's/\ /=" /' | sed -E 's/[[:blank:]]+//' | sed 's/$/"/g'
) 2>/dev/null || err=1

# Conf file format check
if [ $err -eq 1 ] 2>/dev/null; then
	echo "CHYBA: Konfiguracni soubor ma nespravny format!"
	exit 2
fi

# If verbose mode is on
print_conf()
{
	# Parsing variable names from the conf file and parsing it's vaules
	declare -p $(echo $(
	sed 's/#.*$//g' "$CONF_FILE" | sed 's/^[[:blank:]]*//g'	| 
	grep -v '^$' | sed 's/[[:blank:]].*$//g')) |
	# Deletion of the "declare --" string
	cut -c 12-
}

print_conf

exit 0;

