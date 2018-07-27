#! /bin/bash

# ARRAY FROM PATH VARIABLE FOR FURTHER WORK

# Array creation from PATH variable
eval $(echo CESTA=\(\"$PATH\"\) | sed "s/:/\"\ \"/g")

print_array()
{
	for (( i=0; i<${#CESTA[@]}; i++ ))
	do
		echo ${CESTA[i]}
	done
}

# New array NEW
NEW=("a b" "c d" "e" "f")

# Copying array from the first parameter to the second one
array_cp()
{
	eval $(echo "$2"=\(\"\$\{"$2"\[\@\]\}\"\ \"\$\{"$1"\[\@\]\}\"\))
}

# Adding parameter to the end of CESTA array (if it is there now, it is taken out and added to the end)
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

# The same as append, but for start of the array
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

# Tests
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
