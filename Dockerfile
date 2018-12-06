FROM alpine:3.8

RUN apk install rsync

WORKDIR /workspace

COPY callback_plugins      /workspace/callback_plugins
COPY docker-playbook       /workspace/docker-playbook
COPY etcd-playbook         /workspace/etcd-playbook
COPY registry-playbook     /workspace/registry-playbook
COPY kubernetes-playbook   /workspace/kubernetes-playbook
COPY workernode-playbook   /workspace/workernode-playbook

COPY components_order.conf /workspace