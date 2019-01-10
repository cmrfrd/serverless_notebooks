#!/bin/sh

echo "Setting up and init ..."
kubectl create serviceaccount -n kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account=tiller --tiller-namespace=kube-system

echo "Securing helm..."
kubectl patch deployment tiller-deploy --namespace=kube-system --type=json --patch='[{"op": "add", "path": "/spec/template/spec/containers/0/command", "value": ["/tiller", "--listen=localhost:44134"]}]'

echo "Deploying single user notebook server ..."
kubectl apply -f yml/jupyter.yml

echo "Deploying faas namespace ..."
kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml

echo "Adding openfaas to helm repos ..."
helm repo add openfaas https://openfaas.github.io/faas-netes/

echo "Adding openfaas secret ..."
PASSWORD=$(head -c 12 /dev/urandom | shasum| cut -d' ' -f1)
kubectl -n openfaas create secret generic basic-auth \
	--from-literal=basic-auth-user=admin \
	--from-literal=basic-auth-password="$PASSWORD"

echo "Deploying openfaas ..."
helm repo update && \
helm upgrade openfaas \
	 --install openfaas/openfaas \
	 --namespace openfaas  \
	 --set basic_auth=false \
	 --set functionNamespace=openfaas

echo "Upgrading openfaas image pull policy ..."
helm upgrade openfaas openfaas/openfaas --install --set "faasnetesd.imagePullPolicy=IfNotPresent"
