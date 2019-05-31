#! /bin/bash

set -e

path=`dirname $0`

k8s_version=`cat ${path}/components-version.txt |grep "Kubernetes" |awk '{print $3}'`

docker run --rm --name=kubeadm-version wise2c/kubeadm-version:v${k8s_version} kubeadm config images list --kubernetes-version ${k8s_version} > ${path}/k8s-images-list.txt

echo "=== pulling kubernetes images ==="
for IMAGES in $(cat ${path}/k8s-images-list.txt |grep -v etcd); do
  docker pull ${IMAGES}
done
echo "=== kubernetes images are pulled successfully ==="

echo "=== saving kubernetes images ==="
mkdir -p ${path}/file
docker save $(cat ${path}/k8s-images-list.txt |grep -v etcd) -o ${path}/file/k8s.tar
rm ${path}/file/k8s.tar.bz2 -f
bzip2 -z --best ${path}/file/k8s.tar
echo "=== kubernetes images are saved successfully ==="

kubernetes_repo=`cat ${path}/k8s-images-list.txt |grep kube-apiserver |awk -F '/' '{print $1}'`
kubernetes_version=`cat ${path}/k8s-images-list.txt |grep kube-apiserver |awk -F ':' '{print $2}'`
dns_version=`cat ${path}/k8s-images-list.txt |grep coredns |awk -F ':' '{print $2}'`
pause_version=`cat ${path}/k8s-images-list.txt |grep pause |awk -F ':' '{print $2}'`

echo "" >> ${path}/inherent.yaml
echo "version: ${kubernetes_version}" >> ${path}/inherent.yaml

echo ""                                           >> ${path}/yat/all.yml.gotmpl
echo "kubernetes_repo: ${kubernetes_repo}"        >> ${path}/yat/all.yml.gotmpl
echo "kubernetes_version: ${kubernetes_version}"  >> ${path}/yat/all.yml.gotmpl
echo "dns_version: ${dns_version}"                >> ${path}/yat/all.yml.gotmpl
echo "pause_version: ${pause_version}"            >> ${path}/yat/all.yml.gotmpl


flannel_repo="quay.io/coreos"
flannel_version="v0.11.0"
echo "flannel_repo: ${flannel_repo}"              >> ${path}/yat/all.yml.gotmpl
echo "flannel_version: ${flannel_version}-amd64"  >> ${path}/yat/all.yml.gotmpl

#The image tag is incorrect in https://raw.githubusercontent.com/coreos/flannel/v0.11.0/Documentation/kube-flannel.yml
#curl -sSL https://raw.githubusercontent.com/coreos/flannel/${flannel_version}/Documentation/kube-flannel.yml \
#   | sed -e "s,quay.io/coreos,{{ registry_endpoint }}/{{ registry_project }},g" > ${path}/template/kube-flannel.yml.j2

curl -sSL https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml \
   | sed -e "s,quay.io/coreos,{{ registry_endpoint }}/{{ registry_project }},g" > ${path}/template/kube-flannel.yml.j2
   
dashboard_repo=${kubernetes_repo}
dashboard_version="v1.10.1"
echo "dashboard_repo: ${dashboard_repo}"          >> ${path}/yat/all.yml.gotmpl
echo "dashboard_version: ${dashboard_version}"    >> ${path}/yat/all.yml.gotmpl

#curl -sS https://raw.githubusercontent.com/kubernetes/dashboard/${dashboard_version}/src/deploy/recommended/kubernetes-dashboard.yaml \
#    | sed -e "s,k8s.gcr.io,{{ registry_endpoint }}/{{ registry_project }},g" > ${path}/template/kubernetes-dashboard.yml.j2

curl -sSL https://github.com/wise2c-devops/breeze/raw/v1.13/kubernetes-playbook/kubernetes-dashboard-wise2c.yaml.j2 \
    | sed -e "s,k8s.gcr.io,{{ registry_endpoint }}/{{ registry_project }},g" > ${path}/template/kubernetes-dashboard.yml.j2
    
echo "=== pulling kubernetes images ==="
docker pull ${kubernetes_repo}/kube-apiserver-amd64:${kubernetes_version}
docker pull ${kubernetes_repo}/kube-controller-manager-amd64:${kubernetes_version}
docker pull ${kubernetes_repo}/kube-scheduler-amd64:${kubernetes_version}
docker pull ${kubernetes_repo}/kube-proxy-amd64:${kubernetes_version}
docker pull ${kubernetes_repo}/pause:${pause_version}
docker pull ${kubernetes_repo}/k8s-dns-sidecar-amd64:${dns_version}
docker pull ${kubernetes_repo}/k8s-dns-kube-dns-amd64:${dns_version}
docker pull ${kubernetes_repo}/k8s-dns-dnsmasq-nanny-amd64:${dns_version}
#nathon's wise2c-dns. registry.cn-hangzhou.aliyuncs.com/wise2c-dev/k8s-dns-kube-dns-amd64:1.14.16
#zhouyi's wise2c-dns merge 1.14.10 and nathon's code.
docker pull wisecloud/k8s-dns-kube-dns-amd64:1.14.10.1

echo "=== pull kubernetes images success ==="
echo "=== saving kubernetes images ==="
mkdir -p ${path}/file
docker save ${kubernetes_repo}/kube-apiserver-amd64:${kubernetes_version} \
    ${kubernetes_repo}/kube-controller-manager-amd64:${kubernetes_version} \
    ${kubernetes_repo}/kube-scheduler-amd64:${kubernetes_version} \
    ${kubernetes_repo}/kube-proxy-amd64:${kubernetes_version} \
    ${kubernetes_repo}/pause:${pause_version} \
    ${kubernetes_repo}/k8s-dns-sidecar-amd64:${dns_version} \
    ${kubernetes_repo}/k8s-dns-kube-dns-amd64:${dns_version} \
    ${kubernetes_repo}/k8s-dns-dnsmasq-nanny-amd64:${dns_version} \
    wisecloud/k8s-dns-kube-dns-amd64:1.14.10.1 \
    > ${path}/file/k8s.tar
rm ${path}/file/k8s.tar.bz2 -f
bzip2 -z --best ${path}/file/k8s.tar
echo "=== save kubernetes images success ==="

echo "=== pulling flannel image ==="
docker pull ${flannel_repo}/flannel:${flannel_version}-amd64
echo "=== flannel image is pulled successfully ==="

echo "=== saving flannel image ==="
docker save ${flannel_repo}/flannel:${flannel_version}-amd64 \
    > ${path}/file/flannel.tar
rm ${path}/file/flannel.tar.bz2 -f
bzip2 -z --best ${path}/file/flannel.tar
echo "=== flannel image is saved successfully ==="

echo "=== pulling kubernetes dashboard images ==="
docker pull ${dashboard_repo}/kubernetes-dashboard-amd64:${dashboard_version}
#docker pull k8s.gcr.io/heapster-amd64:v1.5.4
#docker pull k8s.gcr.io/heapster-influxdb-amd64:v1.5.2
#docker pull k8s.gcr.io/heapster-grafana-amd64:v5.0.4
echo "=== kubernetes dashboard images are pulled successfully ==="

echo "=== saving kubernetes dashboard images ==="
docker save ${dashboard_repo}/kubernetes-dashboard-amd64:${dashboard_version} \
    > ${path}/file/dashboard.tar
#docker save k8s.gcr.io/heapster-amd64:v1.5.4 k8s.gcr.io/heapster-influxdb-amd64:v1.5.2 k8s.gcr.io/heapster-grafana-amd64:v5.0.4 -o ${path}/file/heapster.tar
rm ${path}/file/dashboard.tar.bz2 -f
#rm ${path}/file/heapster.tar.bz2 -f
bzip2 -z --best ${path}/file/dashboard.tar
#bzip2 -z --best ${path}/file/heapster.tar
echo "=== kubernetes dashboard images are saved successfully ==="

echo "=== download cfssl tools ==="
export CFSSL_URL=https://pkg.cfssl.org/R1.2
curl -L -o cfssl ${CFSSL_URL}/cfssl_linux-amd64
curl -L -o cfssljson ${CFSSL_URL}/cfssljson_linux-amd64
curl -L -o cfssl-certinfo ${CFSSL_URL}/cfssl-certinfo_linux-amd64
chmod +x cfssl cfssljson cfssl-certinfo
tar zcvf ${path}/file/cfssl-tools.tar.gz cfssl cfssl-certinfo cfssljson
echo "=== cfssl tools is download successfully ==="

helm_repo="gcr.io/kubernetes-helm"
helm_version="v2.13.1"
echo "helm_repo: ${helm_repo}" >> ${path}/yat/all.yml.gotmpl
echo "helm_version: ${helm_version}" >> ${path}/yat/all.yml.gotmpl

echo "=== pulling helm tiller image ==="
docker pull ${helm_repo}/tiller:${helm_version}
echo "=== helm tiller image is pulled successfully ==="

echo "=== saving helm tiller image ==="
docker save ${helm_repo}/tiller:${helm_version} > ${path}/file/tiller.tar
rm ${path}/file/tiller.tar.bz2 -f
bzip2 -z --best ${path}/file/tiller.tar
echo "=== helm tiller image is saved successfully ==="
