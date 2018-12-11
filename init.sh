#! /bin/bash

set -e

path=`dirname $0`


# version info.
docker_version="1.13.1"
registry_version="v1.5.1"
etcd_version="3.0.17"
kubernetes_version="v1.8.6"

mv docker-playbook/version     docker-playbook/${docker_version}
mv registry-playbook/version   registry-playbook/${registry_version}
mv etcd-playbook/version       etcd-playbook/${etcd_version}
mv kubernetes-playbook/version kubernetes-playbook/${kubernetes_version}

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