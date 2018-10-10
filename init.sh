#! /bin/bash

set -e

path=`dirname $0`
aliyun_username=$1
aliyun_password=$2

for dir in `ls ${path}`
do
    if [[ ${dir} =~ -playbook$ ]]; then
        for version in `ls ${path}/${dir}`
        do
            echo ${version}
            if [ -f ${path}/${dir}/${version}/init.sh ]; then
                bash ${path}/${dir}/${version}/init.sh ${version} ${aliyun_username} ${aliyun_password}
            fi
        done
    fi
done
