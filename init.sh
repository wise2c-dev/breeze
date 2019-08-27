#! /bin/bash

set -e

path=`dirname $0`

#curl -sl https://raw.githubusercontent.com/wise2c-dev/wise2c-config/master/config.yaml -o /tmp/config.yaml
kubernetes_version=$(cat /tmp/config.yaml    |  yq -r '.branchs[] | select(.branch == "release-1.13")|.kube_version')
docker_version=docker-$(cat /tmp/config.yaml |  yq -r '.branchs[] | select(.branch == "release-1.13")|.docker_version')
haproxy_version=$(cat /tmp/config.yaml       |  yq -r '.branchs[] | select(.branch == "release-1.13")|.haproxy_version')
keepalived_version=$(cat /tmp/config.yaml    |  yq -r '.branchs[] | select(.branch == "release-1.13")|.keepalived_version')
loadbalancer_version=HAProxy-${haproxy_version}_Keepalived-${keepalived_version}
istio_version=$(cat /tmp/config.yaml         |  yq -r '.branchs[] | select(.branch == "release-1.13")|.istio_version')


mv ${path}/kubernetes-playbook/version ${path}/kubernetes-playbook/${kubernetes_version}
mv ${path}/docker-playbook/version ${path}/docker-playbook/${docker_version}-CE
mv ${path}/istio-playbook/version-images ${path}/istio-playbook/v${istio_version}-images

docker run --rm --name=kubeadm-version wisecloud/kubeadm-version:${kubernetes_version} kubeadm config images list --kubernetes-version ${kubernetes_version:1} > ${path}/k8s-images-list.txt

etcd_version=`cat ${path}/k8s-images-list.txt |grep etcd |awk -F ':' '{print $2}'`
mv etcd-playbook/version-by-kubeadm etcd-playbook/${etcd_version}

echo "Kubernetes Version: ${kubernetes_version:1}" > ${path}/components-version.txt
echo "Harbor Version: ${harbor_version}" >> ${path}/components-version.txt
echo "Docker Version: ${docker_version}" >> ${path}/components-version.txt
echo "HAProxy Version: ${haproxy_version}" >> ${path}/components-version.txt
echo "Keepalived Version: ${keepalived_version}" >> ${path}/components-version.txt
echo "Istio Version: ${istio_version}"  >> ${path}/components-version.txt

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
