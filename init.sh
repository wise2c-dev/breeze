#! /bin/bash

set -e

path=`dirname $0`

kubernetes_version=$(cat /tmp/config.yaml    |  yq -r '.branchs[] | select(.branch == "release-1.15")|.kube_version')
docker_version=docker-$(cat /tmp/config.yaml |  yq -r '.branchs[] | select(.branch == "release-1.15")|.docker_version')
haproxy_version=$(cat /tmp/config.yaml       |  yq -r '.branchs[] | select(.branch == "release-1.15")|.haproxy_version')
keepalived_version=$(cat /tmp/config.yaml    |  yq -r '.branchs[] | select(.branch == "release-1.15")|.keepalived_version')
loadbalancer_version=HAProxy-${haproxy_version}_Keepalived-${keepalived_version}
istio_version=$(cat /tmp/config.yaml         |  yq -r '.branchs[] | select(.branch == "release-1.15")|.istio_version')
flannel_version=$(cat /tmp/config.yaml       |  yq -r '.branchs[] | select(.branch == "release-1.15")|.flannel_version')
dashboard_version=$(cat /tmp/config.yaml     |  yq -r '.branchs[] | select(.branch == "release-1.15")|.dashboard_version')


mv ${path}/kubernetes-playbook/version ${path}/kubernetes-playbook/${kubernetes_version}
mv ${path}/docker-playbook/version ${path}/docker-playbook/${docker_version}-CE
mv ${path}/istio-playbook/version-images ${path}/istio-playbook/v${istio_version}

docker run --rm --name=kubeadm-version wisecloud/kubeadm-version:${kubernetes_version} kubeadm config images list --kubernetes-version ${kubernetes_version} > ${path}/k8s-images-list.txt

etcd_version=`cat ${path}/k8s-images-list.txt |grep etcd |awk -F ':' '{print $2}'`
mv etcd-playbook/version-by-kubeadm etcd-playbook/${etcd_version}

echo "ETCD Version: ${etcd_version}" > ${path}/components-version.txt
echo "Kubernetes Version: ${kubernetes_version}" >> ${path}/components-version.txt
echo "Harbor Version: ${harbor_version}" >> ${path}/components-version.txt
echo "Docker Version: ${docker_version}" >> ${path}/components-version.txt
echo "HAProxy Version: ${haproxy_version}" >> ${path}/components-version.txt
echo "Keepalived Version: ${keepalived_version}" >> ${path}/components-version.txt
echo "Dashboard Version: ${dashboard_version}" >> ${path}/components-version.txt
echo "Flannel Version: ${flannel_version}" >> ${path}/components-version.txt
echo "Istio Version: ${istio_version}" >> ${path}/components-version.txt

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
