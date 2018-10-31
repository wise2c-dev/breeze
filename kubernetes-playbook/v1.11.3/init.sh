#! /bin/bash

set -e

path=`dirname $0`

#kubernetes_repo="gcr.io/google_containers"
# kubernetes_version=`docker run -it --rm \
#                    -e KUBERNETES_VERSION=${1} \
#                    -e KUBERNETES_COMPONENT=kube-apiserver \
#                    ymian/kube-version:1.11`
# dns_version=`docker run -it --rm \
#                    -e KUBERNETES_VERSION=${1} \
#                    -e KUBERNETES_COMPONENT=kube-dns \
#                    ymian/kube-version:1.11`

kubernetes_repo="k8s.gcr.io"
kubernetes_version="v1.11.3"
dns_version="1.14.10"

pause_version="3.1"
echo "" >> ${path}/yat/all.yml.gotmpl
echo "kubernetes_repo: ${kubernetes_repo}" >> ${path}/yat/all.yml.gotmpl
echo "kubernetes_version: ${kubernetes_version}" >> ${path}/yat/all.yml.gotmpl
echo "dns_version: ${dns_version}" >> ${path}/yat/all.yml.gotmpl
echo "pause_version: ${pause_version}" >> ${path}/yat/all.yml.gotmpl

flannel_repo="quay.io/coreos"
flannel_version="v0.10.0"
echo "flannel_repo: ${flannel_repo}" >> ${path}/yat/all.yml.gotmpl
echo "flannel_version: ${flannel_version}-amd64" >> ${path}/yat/all.yml.gotmpl

curl -sSL https://raw.githubusercontent.com/coreos/flannel/${flannel_version}/Documentation/kube-flannel.yml \
    | sed -e "s,quay.io/coreos,{{ registry_endpoint }}/{{ registry_project }},g" > ${path}/template/kube-flannel.yml.j2

dashboard_repo=${kubernetes_repo}
dashboard_version="v1.8.3"
echo "dashboard_repo: ${dashboard_repo}" >> ${path}/yat/all.yml.gotmpl
echo "dashboard_version: ${dashboard_version}" >> ${path}/yat/all.yml.gotmpl

#curl -sS https://raw.githubusercontent.com/kubernetes/dashboard/${dashboard_version}/src/deploy/recommended/kubernetes-dashboard.yaml \
#    | sed -e "s,k8s.gcr.io,{{ registry_endpoint }}/{{ registry_project }},g" > ${path}/template/kubernetes-dashboard.yml.j2

curl -sSL https://github.com/wise2ck8s/breeze/raw/v1.11/kubernetes-playbook/kubernetes-dashboard-wise2c.yaml.j2 \
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
echo "=== pull flannel image success ==="
echo "=== saving flannel image ==="
docker save ${flannel_repo}/flannel:${flannel_version}-amd64 \
    > ${path}/file/flannel.tar
rm ${path}/file/flannel.tar.bz2 -f
bzip2 -z --best ${path}/file/flannel.tar
echo "=== save flannel image success ==="

echo "=== pulling dashboard image ==="
docker pull ${dashboard_repo}/kubernetes-dashboard-amd64:${dashboard_version}
echo "=== pull dashboard image success ==="
echo "=== saving dashboard image ==="
docker save ${dashboard_repo}/kubernetes-dashboard-amd64:${dashboard_version} \
    > ${path}/file/dashboard.tar
rm ${path}/file/dashboard.tar.bz2 -f
bzip2 -z --best ${path}/file/dashboard.tar
echo "=== save dashboard image success ==="

echo "=== download cfssl tools ==="
export CFSSL_URL=https://pkg.cfssl.org/R1.2
curl -L -o cfssl ${CFSSL_URL}/cfssl_linux-amd64
curl -L -o cfssljson ${CFSSL_URL}/cfssljson_linux-amd64
curl -L -o cfssl-certinfo ${CFSSL_URL}/cfssl-certinfo_linux-amd64
chmod +x cfssl cfssljson cfssl-certinfo
tar zcvf ${path}/file/cfssl-tools.tar.gz cfssl cfssl-certinfo cfssljson
echo "=== cfssl tools is download successfully ==="