#!/bin/bash

# Stop rugby-app-test and slaves:

namespace="rugby-app-test"

kubectl get namespace| grep $namespace

master_pod=`kubectl -n $namespace get po | grep jmeter-master | awk '{print $1}'`

kubectl -n $namespace exec -ti $master_pod -- /jmeter/apache-jmeter-5.0/bin/stoptest.sh
