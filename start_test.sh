#!/usr/bin/env bash
#Script created to launch Jmeter rugby-app-tests directly from the current terminal without accessing the jmeter master pod.
#It requires that you supply the path to the jmx file
#After execution, rugby-app-test script jmx file may be deleted from the pod itself but not locally.

namespace="rugby-app-test"

jmx_dir=$(pwd)

kubectl get namespace| grep $namespace >> /dev/null

if [ $? != 0 ];
then
    echo "Namespace does not exist in the kubernetes cluster"
    echo ""
    echo "Below is the list of namespaces in the kubernetes cluster"

    kubectl get namespaces
    echo ""
    echo "Please check and try again"
    exit
fi


#Get Master pod details
master_pod=`kubectl -n $namespace get po | grep jmeter-master | awk '{print $1}'`

# Workaround in exec permission file:
kubectl -n $namespace exec -ti $master_pod -- cp -rf /load_test /jmeter/load_test
kubectl -n $namespace exec -ti $master_pod -- chmod 755 /jmeter/load_test

# JMX deve ser fixo para execucao de inicio de rugby-app-testes independente para cada cenario:
jmx="rugby-score-prediction-app-test.jmx"

if [ ! -f "$jmx" ];
then
    echo "Test script file was not found in PATH"
    echo "Kindly check and input the correct file path"
    exit
fi

test_name="$(basename "$jmx")"

# Copy JMX to Master Pod
kubectl -n $namespace cp "$jmx" "$master_pod:/$test_name"

## Echo Starting Jmeter load rugby-app-test

kubectl -n $namespace exec -ti $master_pod -- /bin/bash /load_test "$test_name"
