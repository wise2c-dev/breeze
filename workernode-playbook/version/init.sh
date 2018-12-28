#! /bin/bash

set -e

path=`dirname $0`
version=$1

docker run --rm --name=kubeadm-version wisecloud/kubeadm-version:$TRAVIS_BRANCH kubeadm config images list --feature-gates=CoreDNS=false > ${path}/k8s-images-list.txt

kubernetes_repo=`cat ${path}/k8s-images-list.txt |grep kube-apiserver |awk -F '/' '{print $1}'`
kubernetes_version=`cat ${path}/k8s-images-list.txt |grep kube-apiserver |awk -F ':' '{print $2}'`
dns_version=`cat ${path}/k8s-images-list.txt |grep kube-dns |awk -F ':' '{print $2}'`
pause_version=`cat ${path}/k8s-images-list.txt |grep pause |awk -F ':' '{print $2}'`

echo ""                                           >> ${path}/yat/all.yml.gotmpl
echo "version: ${version}"                        >> ${path}/yat/all.yml.gotmpl
echo "kubernetes_repo: ${kubernetes_repo}"        >> ${path}/yat/all.yml.gotmpl
echo "kubernetes_version: ${kubernetes_version}"  >> ${path}/yat/all.yml.gotmpl
echo "pause_version: ${pause_version}"            >> ${path}/yat/all.yml.gotmpl

