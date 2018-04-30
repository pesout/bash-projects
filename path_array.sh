#! /bin/bash

# SKRIPT VYTVORI Z PROMENNE PATH POLE, SE KTERYM DALE PRACUJE

# Vytvoreni pole z promenne PATH 
eval $(echo CESTA=\(\"$PATH\"\) | sed "s/:/\"\ \"/g")

# Funkce pro vypis pole
print_array()
{
	for (( i=0; i<${#CESTA[@]}; i++ ))
	do
		echo ${CESTA[i]}
	done
}

# Nove pole NEW
NEW=("a b" "c d" "e" "f")

# Kopirovani pole v prvnim parametru do pole v druhem paramestru
array_cp()
{
	eval $(echo "$2"=\(\"\$\{"$2"\[\@\]\}\"\ \"\$\{"$1"\[\@\]\}\"\))
}

# Pridani parametru na konec pole CESTA (pokud jiz v poli parametr je, z pole se vyjme a prida na konec)
append() 
{
	exists=0;
	for i in "${!CESTA[@]}"
	do
		if [ "${CESTA[i]}" == "$1" ]; then
			exists=$i
			
		fi
	done
	
	if [ $exists -ne 0 ]; then
		for (( i=$exists; i<${#CESTA[@]}; i++ ))
		do
			CESTA[i]=${CESTA[i+1]}
		done
		CESTA[${#CESTA[@]}-1]="$1";
	else
		CESTA[${#CESTA[@]}]="$1";
	fi
}

prepend() 
{
	append "$1"
	for (( i=${#CESTA[@]}; i>0; i-- ))
	do
			CESTA[i]=${CESTA[i-1]}
	done
	CESTA[0]="$1"
	unset 'CESTA[${#CESTA[@]}-1]'
}

# Test funkci
echo '=== print_array ==='
print_array
echo '=== array_cp NEW CESTA; print_array ==='
array_cp NEW CESTA
print_array
echo '=== append "a b"; print_array ==='
append "a b"
print_array
echo '=== prepend "e"; print_array ==='
prepend "e"
print_array
