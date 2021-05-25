#!/bin/bash

# Stop rugby-app-test and slaves:

namespace="rugby-app-test"

kubectl get namespace| grep $namespace

master_pod=`kubectl -n $namespace get po | grep jmeter-master | awk '{print $1}'`
slave_pod=`kubectl -n $namespace get po | grep jmeter-slave | awk '{print $1}'`


kubectl -n $namespace exec -ti $master_pod -- ls /jmeter/apache-jmeter-5.0/lib/ext
#kubectl -n $namespace exec -ti $slave_pod -- ls /jmeter/apache-jmeter-5.0/bin/ | grep jmeter
# kubectl -n $namespace exec -ti $master_pod -- java -version
#kubectl -n $namespace exec -ti $master_pod -- which java
#kubectl -n $namespace exec -ti $master_pod -- ls -lhart /usr/bin/java
#kubectl -n $namespace exec -ti $master_pod -- cat /load_test

#echo "Slaves: "
#kubectl -n $namespace exec -ti $slave_pod -- ls -lhart /jmeter

