#! /bin/bash

set -e

path=`dirname $0`

k8s_version=`cat ${path}/components-version.txt |grep "Kubernetes" |awk '{print $3}'`

docker run --rm --name=kubeadm-version wisecloud/kubeadm-version:${k8s_version} kubeadm config images list --kubernetes-version ${k8s_version} --config=kube-dns.yaml > ${path}/k8s-images-list.txt

kubernetes_repo=`cat ${path}/k8s-images-list.txt |grep kube-apiserver |awk -F '/' '{print $1}'`
kubernetes_version=`cat ${path}/k8s-images-list.txt |grep kube-apiserver |awk -F ':' '{print $2}'`
dns_version=`cat ${path}/k8s-images-list.txt |grep kube-dns |awk -F ':' '{print $2}'`
pause_version=`cat ${path}/k8s-images-list.txt |grep pause |awk -F ':' '{print $2}'`

echo "=== pulling kubernetes images ==="
for IMAGES in $(cat ${path}/k8s-images-list.txt |grep -v etcd); do
  docker pull ${IMAGES}
done
docker pull wisecloud/k8s-dns-kube-dns-amd64:1.14.10.1
docker tag wisecloud/k8s-dns-kube-dns-amd64:1.14.10.1 k8s.gcr.io/k8s-dns-kube-dns:${dns_version}
echo "=== kubernetes images are pulled successfully ==="

echo "=== saving kubernetes images ==="
mkdir -p ${path}/file
docker save $(cat ${path}/k8s-images-list.txt |grep -v etcd) -o ${path}/file/k8s.tar
rm ${path}/file/k8s.tar.bz2 -f
bzip2 -z --best ${path}/file/k8s.tar
echo "=== kubernetes images are saved successfully ==="


echo "" >> ${path}/inherent.yaml
echo "version: ${kubernetes_version}" >> ${path}/inherent.yaml

echo "" >> ${path}/yat/all.yml.gotmpl
echo "kubernetes_repo: ${kubernetes_repo}" >> ${path}/yat/all.yml.gotmpl
echo "kubernetes_version: ${kubernetes_version}" >> ${path}/yat/all.yml.gotmpl
echo "dns_version: ${dns_version}" >> ${path}/yat/all.yml.gotmpl
echo "pause_version: ${pause_version}" >> ${path}/yat/all.yml.gotmpl

flannel_repo="quay.io/coreos"
flannel_version=`cat ${path}/components-version.txt |grep "Flannel" |awk '{print $3}'`

echo "flannel_repo: ${flannel_repo}" >> ${path}/yat/all.yml.gotmpl
echo "flannel_version: ${flannel_version}-amd64" >> ${path}/yat/all.yml.gotmpl
echo "flannel_version_short: ${flannel_version}" >> ${path}/yat/all.yml.gotmpl

curl -sSL https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml \
   | sed -e "s,quay.io/coreos,{{ registry_endpoint }}/{{ registry_project }},g" > ${path}/template/kube-flannel.yml.j2

    
echo "=== pulling flannel image ==="
docker pull ${flannel_repo}/flannel:${flannel_version}-amd64
echo "=== flannel image is pulled successfully ==="

echo "=== saving flannel image ==="
docker save ${flannel_repo}/flannel:${flannel_version}-amd64 \
    > ${path}/file/flannel.tar
rm ${path}/file/flannel.tar.bz2 -f
bzip2 -z --best ${path}/file/flannel.tar
echo "=== flannel image is saved successfully ==="

echo "=== download cfssl tools ==="
export CFSSL_URL=https://pkg.cfssl.org/R1.2
curl -L -o cfssl ${CFSSL_URL}/cfssl_linux-amd64
curl -L -o cfssljson ${CFSSL_URL}/cfssljson_linux-amd64
curl -L -o cfssl-certinfo ${CFSSL_URL}/cfssl-certinfo_linux-amd64
chmod +x cfssl cfssljson cfssl-certinfo
tar zcvf ${path}/file/cfssl-tools.tar.gz cfssl cfssl-certinfo cfssljson
echo "=== cfssl tools is download successfully ==="
