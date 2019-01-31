#! /bin/bash

set -e

path=`dirname $0`


docker run --rm --name=kubeadm-version wisecloud/kubeadm-version:v1.11.7 kubeadm config images list --feature-gates=CoreDNS=false > ${path}/k8s-images-list.txt


# version info.
docker_version=1.13.1-75
harbor_version=1.5.1
etcd_version=`cat ${path}/k8s-images-list.txt |grep etcd |awk -F ':' '{print $2}'`
haproxy_version=1.8.14
keepalived_version=1.3.5
kubernetes_version=`cat ${path}/k8s-images-list.txt |grep kube-apiserver |awk -F ':' '{print $2}'`
loadbalancer_version=HAProxy-${haproxy_version}_Keepalived-${keepalived_version}
prometheus_version=2.5.0
prometheus_operator_version=0.26.0


mv ${path}/docker-playbook/version          ${path}/docker-playbook/${docker_version}
mv ${path}/harbor-playbook/version          ${path}/harbor-playbook/v${harbor_version}
mv ${path}/etcd-playbook/version            ${path}/etcd-playbook/${etcd_version}
mv ${path}/kubernetes-playbook/version      ${path}/kubernetes-playbook/${kubernetes_version}
mv ${path}/loadbalancer-playbook/version    ${path}/loadbalancer-playbook/${loadbalancer_version}
mv ${path}/prometheus-playbook/version      ${path}/prometheus-playbook/v${prometheus_version}


echo "Kubernetes Version: ${kubernetes_version}"                  >  ${path}/components-version.txt
echo "Harbor Version: ${harbor_version}"                          >> ${path}/components-version.txt
echo "Docker Version: ${docker_version}"                          >> ${path}/components-version.txt
echo "HAProxy Version: ${haproxy_version}"                        >> ${path}/components-version.txt
echo "Keepalived Version: ${keepalived_version}"                  >> ${path}/components-version.txt
echo "Prometheus Version: ${prometheus_version}"                  >> ${path}/components-version.txt
echo "PrometheusOperator Version: ${prometheus_operator_version}" >> ${path}/components-version.txt

for dir in `ls ${path}`
do
    if [[ ${dir} =~ -playbook$ ]]; then
        for version in `ls ${path}/${dir}`
        do
            echo ${version}
            if [ -f ${path}/${dir}/${version}/init.sh ]; then
                cp ${path}/components-version.txt ${path}/${dir}/${version}/
                bash ${path}/${dir}/${version}/init.sh ${version}
            fi
        done
    fi
done