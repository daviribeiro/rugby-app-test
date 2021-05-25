#!/usr/bin/env bash
# Copy CSV Files 
# Execute before initialize_cluster and after startconfigs.sh

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

printf "Get number of slaves\n"

slave_pods=($(kubectl -n $namespace get po | grep jmeter-slave | awk '{print $1}'))

# for array iteration
slavesnum=${#slave_pods[@]}

# for split command suffix and seq generator
slavedigits="${#slavesnum}"

printf "Number of slaves is %s\n" "${slavesnum}"

# Split and upload csv files

for csvfilefull in "${jmx_dir}"/*.csv

  do

  csvfile="${csvfilefull##*/}"

  printf "Processing %s file..\n" "$csvfile"

  split --suffix-length="${slavedigits}" --additional-suffix=.csv -d --number="l/${slavesnum}" "${jmx_dir}/${csvfile}" "$jmx_dir"/

  j=0
  for i in $(seq -f "%0${slavedigits}g" 0 $((slavesnum-1)))
  do
    printf "Copy %s to %s on %s\n" "${i}.csv" "${csvfile}" "${slave_pods[j]}"
    kubectl -n $namespace cp "${jmx_dir}/${i}.csv" "${slave_pods[j]}":/
    kubectl -n $namespace exec "${slave_pods[j]}" -- mv -v /"${i}.csv" /"${csvfile}"
    rm -v "${jmx_dir}/${i}.csv"

    let j=j+1
  done # for i in "${slave_pods[@]}"

done # for csvfile in "${jmx_dir}/*.csv"