#!/bin/bash

namespace="rugby-app-test"

pod_evicted=`kubectl -n $namespace get po | grep Evicted | awk -F" " '{print $1}'`
pod_terminating=`kubectl -n $namespace get po | grep Terminating | awk -F" " '{print $1}'`

kubectl -n $namespace delete pods $pod_evicted
kubectl -n $namepsace delete pods $pod_terminating
