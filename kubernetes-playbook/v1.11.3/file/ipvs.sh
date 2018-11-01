#!/bin/bash

kubectl -n kube-system get cm kube-proxy -o yaml|sed 's/mode: ".*"/mode: "ipvs"/g'|kubectl -n kube-system replace -f -
kubectl -n kube-system delete pod $(kubectl -n kube-system get pod | grep 'kube-proxy' | awk '{print $1}')