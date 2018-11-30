#! /bin/bash

kubectl -n kube-system get cm kube-proxy -o yaml|sed 's/mode: ".*"/mode: "ipvs"/g'|kubectl -n kube-system replace -f -

for i in {1..30}; do
DESIRED=`kubectl -n kube-system get ds kube-proxy | awk 'NR==2{print $2}'`
AVAILABLE=`kubectl -n kube-system get ds kube-proxy | awk 'NR==2{print $6}'`
    if [ "${DESIRED}"x == "${AVAILABLE}"x ]; then
        echo "same"
        break
    fi

    echo "DESIRED=$DESIRED, AVAILABLE=$AVAILABLE"
    sleep 1
done

#kubectl -n kube-system delete pod $(kubectl -n kube-system get pod | grep 'kube-proxy' | awk '{print $1}')
# -r  no-run-if-empty
kubectl -n kube-system get pod  | grep 'kube-proxy' | awk '{print $1}' | xargs -r -I % sh -c 'echo "delete pod "%;kubectl -n kube-system delete pod %;'