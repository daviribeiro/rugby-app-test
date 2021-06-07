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
echo $master_pod

# Copy Jmeter Log to Debug test execution:
#kubectl -n $namespace cp "$master_pod:/jmeter/apache-jmeter-5.0/bin/jmeter.log" ./jmeter.log

kubectl -n $namespace exec -ti $master_pod -- /sbin/killall5 -9 jmeter

