#!/bin/bash

source_version=v1
target_version=v1.5.0-cmft

if [[ -z $ALIYUN_USERNAME ]] || [[ -z $ALIYUN_PASSWORD ]]; then
    echo "Before push_kuryr.sh, please input dev.aliyun.com username and password"
    echo "export ALIYUN_USERNAME=<<aliyun_username>>"
    echo "export ALIYUN_PASSWORD=<<aliyun_password>>"
    exit 1
fi

#docker login -u ${ALIYUN_USERNAME} -p ${ALIYUN_PASSWORD} registry.cn-hangzhou.aliyuncs.com
echo -n "$ALIYUN_PASSWORD" | docker login --username $ALIYUN_USERNAME --password-stdin registry.cn-hangzhou.aliyuncs.com
if [ $? != 0 ]; then
   echo "docker login failed."
   exit 1
fi

if [[ -z $DOCKER_USERNAME ]] || [[ -z $DOCKER_PASSWORD ]]; then
    echo "Before push_kuryr.sh, please input dev.aliyun.com username and password"
    echo "export DOCKER_USERNAME=<<dockerhub_username>>"
    echo "export DOCKER_PASSWORD=<<dockerhub_password>>"
    exit 1
fi

echo -n "$DOCKER_PASSWORD" | docker login --username $DOCKER_USERNAME --password-stdin

# pull and push
docker pull registry.cn-hangzhou.aliyuncs.com/wise2c-dev/zone_crd:v1.0.2
docker pull registry.cn-hangzhou.aliyuncs.com/wise2c-dev/kuryr-controller:${source_version}
docker pull registry.cn-hangzhou.aliyuncs.com/wise2c-dev/kuryr-cni:${source_version}


docker tag  registry.cn-hangzhou.aliyuncs.com/wise2c-dev/zone_crd:v1.0.2         registry.cn-hangzhou.aliyuncs.com/wise2c-test/zone_crd:${target_version}
docker tag  registry.cn-hangzhou.aliyuncs.com/wise2c-dev/kuryr-controller:${source_version} registry.cn-hangzhou.aliyuncs.com/wise2c-test/kuryr-controller:${target_version}
docker tag  registry.cn-hangzhou.aliyuncs.com/wise2c-dev/kuryr-cni:${source_version}        registry.cn-hangzhou.aliyuncs.com/wise2c-test/kuryr-cni:${target_version}

docker push registry.cn-hangzhou.aliyuncs.com/wise2c-test/zone_crd:${target_version}
docker push registry.cn-hangzhou.aliyuncs.com/wise2c-test/kuryr-controller:${target_version}
docker push registry.cn-hangzhou.aliyuncs.com/wise2c-test/kuryr-cni:${target_version}



docker pull registry.cn-hangzhou.aliyuncs.com/wise2c-test/k8s-dns-kube-dns-amd64:1.14.16

docker tag  registry.cn-hangzhou.aliyuncs.com/wise2c-dev/zone_crd:v1.0.2                     wisecloud/zone_crd:${target_version}
docker tag  registry.cn-hangzhou.aliyuncs.com/wise2c-dev/kuryr-controller:${source_version}  wisecloud/kuryr-controller:${target_version}
docker tag  registry.cn-hangzhou.aliyuncs.com/wise2c-dev/kuryr-cni:${source_version}         wisecloud/kuryr-cni:${target_version}
docker tag  registry.cn-hangzhou.aliyuncs.com/wise2c-test/k8s-dns-kube-dns-amd64:1.14.16     wisecloud/k8s-dns-kube-dns-amd64:1.14.16

docker push wisecloud/zone_crd:${target_version}
docker push wisecloud/kuryr-controller:${target_version}
docker push wisecloud/kuryr-cni:${target_version}
docker push wisecloud/k8s-dns-kube-dns-amd64:1.14.16