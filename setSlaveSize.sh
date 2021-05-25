#!/bin/bash

# replace namespaces in scripts
if [ -z "$1" ]
then 
	echo "Favor informar a quantidade de pods slaves!"
	exit
else
	echo "Quantidade de pods slaves: $1"
	sed -i "s/slave_size: [0-9][0-9]/slave_size: $1/g" ./jmeter-deploy.yaml
	sed -i "s/\"[0-9][0-9]\"/\"$1\"/g" ./startconfigs.sh
	grep "slave_size" ./jmeter-deploy.yaml
fi
