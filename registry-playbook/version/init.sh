#! /bin/bash

set -e

path=`dirname $0`
version=$1
echo "" >> ${path}/yat/registry.yml.gotmpl
echo "version: ${version}" >> ${path}/yat/registry.yml.gotmpl

echo "download harbor-offline-installer-v1.5.1.tgz"
echo "=== downloading harbor ===="
if [ `docker ps -a | grep wise2c-store | wc -l` -gt 0 ]; then
    docker rm -f wise2c-store
fi
docker run -d --name wise2c-store wisecloud/wise2c-store:v1.11.x
docker cp wise2c-store:/store/harbor-offline-installer-v1.5.1.tgz  ${path}/file/
docker rm -f wise2c-store
echo "==== download harbor ==="

echo "=== downloading harbor cfg ==="
curl -sS https://raw.githubusercontent.com/vmware/harbor/${version}/make/harbor.cfg \
    | sed \
    -e "s,^hostname = reg\.mydomain\.com,hostname = {{ inventory_hostname }},g" \
    -e "s,^harbor_admin_password = Harbor12345,harbor_admin_password = {{ password }},g" \
    > ${path}/template/harbor.cfg.j2
echo "=== download harbor cfg ==="