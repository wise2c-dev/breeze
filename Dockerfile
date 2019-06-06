FROM busybox:latest

WORKDIR /workspace

COPY callback_plugins /workspace/callback_plugins
COPY docker-playbook /workspace/docker-playbook
COPY etcd-playbook /workspace/etcd-playbook
COPY kubernetes-playbook /workspace/kubernetes-playbook
COPY prometheus-playbook /workspace/prometheus-playbook
COPY components_order.conf /workspace
COPY istio-playbook  /workspace/istio-playbook