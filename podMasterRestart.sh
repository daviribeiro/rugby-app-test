#!/bin/bash

namespace="rugby-app-test"

# Reseta os pods slaves caso tenha necessidade de reiniciar o teste, setando replicas para 0:
kubectl -n $namespace scale deployment rugby-app-test-loadtest-jmeter-master --replicas=0

# Refaz setando o numero de replicas necessario (smoke test usa apenas 1):
kubectl -n $namespace scale deployment rugby-app-test-loadtest-jmeter-master --replicas=1

# Pega novamente o deploy dos slaves:
kubectl -n $namespace get deployments
