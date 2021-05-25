#!/bin/bash

# replace namespaces in scripts - in debug
if [ -z $1 ]
then
	echo "Favor informar o nome do namespace a ser criado!"
	exit
	
else
	current_namespace=`grep 'namespace=' startconfigs.sh`
	namespace_value=`grep 'namespace\=' startconfigs.sh |awk -F"=" '{print $2}'| sed 's/\"//g'`
	
	for i in `grep -r -e "namespace\=\"$namespace_value\"" ./* | grep -v jar |awk -F":" '{print $1}'`
	do 
		sed -i "s/namespace\=\"$namespace_value\"/namespace\=\"$1\"/g" $i
	done
fi
