#! /bin/bash

set -e

path=`dirname $0`


# version info.
#docker_version=1.13.1-96
#kubernetes_version=1.11.8
#curl -sl https://raw.githubusercontent.com/wise2c-dev/wise2c-config/master/config.yaml -o /tmp/config.yaml
kubernetes_version=$(cat /tmp/config.yaml    |  yq -r '.branchs[] | select(.branch == "release-1.11")|.kube_version')
docker_version=$(cat /tmp/config.yaml |  yq -r '.branchs[] | select(.branch == "release-1.11")|.docker_version')

docker run --rm --name=kubeadm-version wisecloud/kubeadm-version:${kubernetes_version} kubeadm config images list --feature-gates=CoreDNS=false > ${path}/k8s-images-list.txt
etcd_version=`cat ${path}/k8s-images-list.txt |grep etcd |awk -F ':' '{print $2}'`


mv ${path}/docker-playbook/version          ${path}/docker-playbook/${docker_version}
mv ${path}/etcd-playbook/version            ${path}/etcd-playbook/${etcd_version}
mv ${path}/kubernetes-playbook/version      ${path}/kubernetes-playbook/${kubernetes_version:1}


echo "Kubernetes Version: ${kubernetes_version}"                  >  ${path}/components-version.txt
echo "Docker Version: ${docker_version}"                          >> ${path}/components-version.txt

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