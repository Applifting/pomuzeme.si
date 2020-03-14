#!/bin/bash

set -e

curl -L https://github.com/a8m/envsubst/releases/download/v1.1.0/envsubst-`uname -s`-`uname -m` -o envsubst
chmod +x envsubst
sudo mv envsubst /usr/local/bin

KUBE_NAMESPACE='pomuzeme-si'

kubectl get namespace "$KUBE_NAMESPACE" || kubectl create namespace "$KUBE_NAMESPACE"
kubectl config set-context --current --namespace $KUBE_NAMESPACE

kubectl create secret docker-registry applifting-gitlab-registry \
  --docker-username devops-deploy \
  --docker-password ${REGISTRY_TOKEN} \
  --docker-server registry.devops.applifting.cz \
  -oyaml --dry-run | kubectl replace --force -f -

envsubst < 00-secret-env.yaml.tpl | kubectl replace --force -f -

helm upgrade --install production charts/pomuzeme-si --version 0.0.1 -f values.yaml
