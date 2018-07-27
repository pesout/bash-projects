#! /bin/bash

# ARRAY FROM PATH VARIABLE FOR FURTHER WORK

# Array creation from PATH variable
eval $(echo PATHARRAY=\(\"$PATH\"\) | sed "s/:/\"\ \"/g")

print_array()
{
	for (( i=0; i<${#PATHARRAY[@]}; i++ ))
	do
		echo ${PATHARRAY[i]}
	done
}

# New array NEW
NEW=("a b" "c d" "e" "f")

# Copying array from the first parameter to the second one
array_cp()
{
	eval $(echo "$2"=\(\"\$\{"$2"\[\@\]\}\"\ \"\$\{"$1"\[\@\]\}\"\))
}

# Adding parameter to the end of PATHARRAY array (if it is there now, it is taken out and added to the end)
append() 
{
	exists=0;
	for i in "${!PATHARRAY[@]}"
	do
		if [ "${PATHARRAY[i]}" == "$1" ]; then
			exists=$i
			
		fi
	done
	
	if [ $exists -ne 0 ]; then
		for (( i=$exists; i<${#PATHARRAY[@]}; i++ ))
		do
			PATHARRAY[i]=${PATHARRAY[i+1]}
		done
		PATHARRAY[${#PATHARRAY[@]}-1]="$1";
	else
		PATHARRAY[${#PATHARRAY[@]}]="$1";
	fi
}

# The same as append, but for start of the array
prepend() 
{
	append "$1"
	for (( i=${#PATHARRAY[@]}; i>0; i-- ))
	do
			PATHARRAY[i]=${PATHARRAY[i-1]}
	done
	PATHARRAY[0]="$1"
	unset 'PATHARRAY[${#PATHARRAY[@]}-1]'
}

# Tests
echo '=== print_array ==='
print_array
array_cp NEW PATHARRAY
print_array
echo '=== append "a b"; print_array ==='
append "a b"
print_array
echo '=== prepend "e"; print_array ==='
prepend "e"
print_array
