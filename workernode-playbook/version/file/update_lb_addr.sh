#! /bin/bash

endpoint=$1

for i in {1..30}; do
    if [ -f /etc/kubernetes/kubelet.conf ]; then
        sed -i "s/.*server:.*/    server: https:\/\/${endpoint}/g" /etc/kubernetes/kubelet.conf
        break
    else
        echo "wait...$i"
        sleep 1
    fi
done;