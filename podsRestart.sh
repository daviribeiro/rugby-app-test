#!/bin/bash

if [ -z $1 ]
then
	echo "favor informar a quantidade de pods slaves!!"
	exit
else

	namespace="rugby-app-test"

	# Reseta os pods slaves caso tenha necessidade de reiniciar o teste, setando replicas para 0:
	kubectl -n $namespace scale deployment vho-loadtest-jmeter-slaves --replicas=0

	# Refaz setando o numero de replicas necessario (smoke test usa apenas 1):
	kubectl -n $namespace scale deployment vho-loadtest-jmeter-slaves --replicas=$1

	# Pega novamente o deploy dos slaves:
	kubectl -n $namespace get deployments
fi
