#! /bin/bash

kubectl -n kube-system get cm kube-proxy -o yaml|sed 's/mode: ".*"/mode: "ipvs"/g'|kubectl -n kube-system replace -f -

while true; do
DESIRED=`kubectl -n kube-system get ds kube-proxy | awk 'NR==2{print $2}'`
AVAILABLE=`kubectl -n kube-system get ds kube-proxy | awk 'NR==2{print $6}'`
    if [ "${DESIRED}"x == "${AVAILABLE}"x ]; then
        echo "same"
        break
    fi

    echo "DESIRED=$DESIRED, AVAILABLE=$AVAILABLE"
    sleep 2
done

kubectl -n kube-system delete pod $(kubectl -n kube-system get pod | grep 'kube-proxy' | awk '{print $1}')