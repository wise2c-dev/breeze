#!/bin/sh

# 添加污点容忍，直接运行即可

cd $(dirname $0)
work_path=$(pwd)

KEYS=("io.wise2c.host.exclusive" "node-role.kubernetes.io/ingress")

cat > ${work_path}/tolerations-patch.yml <<EOF
spec:
  template:
    spec:
      tolerations:
      - key: "node-role.kubernetes.io/master"
        operator: "Exists"
        effect: "NoSchedule"
      - effect: NoExecute
        operator: Exists
        key: "io.wise2c.host.exclusive"
      - effect: NoSchedule
        operator: Exists
        key: "io.wise2c.host.exclusive"
      - effect: NoExecute
        operator: Exists
        key: "node-role.kubernetes.io/ingress"
      - effect: NoSchedule
        operator: Exists
        key: "node-role.kubernetes.io/ingress"
EOF


for DS in `kubectl -n kube-system get ds | awk 'NR>1{print $1}'`; do
    tolerations=`kubectl -n kube-system get ds/$DS -o json | jq -r .spec.template.spec.tolerations`
    if [ "$tolerations" == "null" ]; then
        echo "patch the $DS in kube-system."
        kubectl -n kube-system patch ds $DS -p="$(cat $work_path/tolerations-patch.yml)"
        continue
    fi

    if [[ "0" == `kubectl -n kube-system get ds/$DS -o json | jq -r ".spec.template.spec.tolerations[] | select (.key==\"node-role.kubernetes.io/master\").key" | wc -l` ]]; then
      echo "append the node-role.kubernetes.io/maste --->$DS in kube-system"
      JSON="[{\"op\": \"add\", \"path\": \"/spec/template/spec/tolerations/-\", \"value\": {\"key\":\"node-role.kubernetes.io/master\", \"effect\":\"NoExecute\", \"operator\":\"Exists\"}}]"
      echo $JSON > $work_path/tolerations.json
      kubectl -n kube-system patch ds $DS --type='json' -p="$(cat $work_path/tolerations.json)"
    fi


    for KEY in ${KEYS[@]}; do
        if [[ "0" == `kubectl -n kube-system get ds/$DS -o json | jq -r ".spec.template.spec.tolerations[] | select (.key==\"$KEY\").key" | wc -l` ]]; then
          echo "append the $KEY --->$DS in kube-system"
          JSON="[{\"op\": \"add\", \"path\": \"/spec/template/spec/tolerations/-\", \"value\": {\"key\":\"$KEY\", \"effect\":\"NoExecute\", \"operator\":\"Exists\"}},{\"op\": \"add\", \"path\": \"/spec/template/spec/tolerations/-\", \"value\": {\"key\":\"$KEY\", \"effect\":\"NoSchedule\", \"operator\":\"Exists\"}}]"
          echo $JSON > $work_path/tolerations.json
          kubectl -n kube-system patch ds $DS --type='json' -p="$(cat $work_path/tolerations.json)"
        fi
    done
done