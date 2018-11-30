#! /bin/bash

set -e

path=`dirname $0`


docker run --rm --name=kubeadm-version wisecloud/kubeadm-version:$TRAVIS_BRANCH kubeadm config images list > ${path}/k8s-images-list.txt

# version info.
docker_version="18.06.1.ce"
etcd_version=`cat ${path}/k8s-images-list.txt |grep etcd |awk -F ':' '{print $2}'`
kubernetes_version=`cat ${path}/k8s-images-list.txt |grep kubernetes |awk -F ':' '{print $2}'`
registry_version="v1.5.1"

mv docker-playbook/version     docker-playbook/${docker_version}
mv etcd-playbook/version       etcd-playbook/${etcd_version}
mv kubernetes-playbook/version kubernetes-playbook/${kubernetes_version}
mv registry-playbook/version   registry-playbook/${registry_version}


for dir in `ls ${path}`
do
    if [[ ${dir} =~ -playbook$ ]]; then
        for version in `ls ${path}/${dir}`
        do
            echo ${version}
            if [ -f ${path}/${dir}/${version}/init.sh ]; then
                bash ${path}/${dir}/${version}/init.sh ${version}
            fi
        done
    fi
done