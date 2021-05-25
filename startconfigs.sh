#!/bin/bash

# Starts configs gcloud (id do project no GCP):
# Para cada repositorio de dados deve subir a quantidade de nos adequada, respeitando o limite de ""0 threads(VU´s) por node

# Variaveis:
REGION=southamerica-east1
ZONE=${REGION}-b
PROJECT=$(gcloud config get-value project)
CLUSTER=rugby-app-test
NODES=5
TARGET=${PROJECT}.appspot.com
SCOPE="https://www.googleapis.com/auth/cloud-platform"
namespace="rugby-app-test"

gcloud config set compute/zone ${ZONE}
gcloud config set project ${PROJECT}

# Configuracao dos conteineres
gcloud container clusters create $CLUSTER --zone $ZONE --scopes $SCOPE --enable-autoscaling --min-nodes "28" --max-nodes "28" --machine-type=n1-standard-4 --scopes=logging-write,cloud-platform --addons HorizontalPodAutoscaling,HttpLoadBalancing

gcloud container clusters get-credentials $CLUSTER --zone $ZONE --project $PROJECT

# Resizing pool - 5 para dois slaves - sempre adicionar dois a mais para o Elastic:
#gcloud container clusters resize rugby-app-test --node-pool default-pool --zone $ZONE --num-nodes $NODES
#gcloud container clusters resize $CLUSTER --node-pool default-pool --num-nodes $NODES

kubectl apply -f ./deploy/crds/loadtest_v1alpha1_jmeter_crd.yaml

kubectl get crd | grep jmeter

kubectl describe crd jmeters.loadrugby-app-test.jmeter.com

kubectl apply -f ./deploy/

# ELK GKE Logging - logara status do cluster + status do JMeter de rugby-app-testes - formatacao do database do k8s logging:
# kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"

kubectl -n kube-system get pods | grep jmeter

# Cada projeto (executor) deve ter seu proprio namespace:
kubectl create namespace $namespace

# Para cada executor deve ter seu proprio yaml de deploy, assim como no namespace:
kubectl create -f jmeter-deploy.yaml

# Elastic GKE:
# kubectl create -f elastic-gke-logging-1.yaml
# kubectl create -f elastic-gke-service.yaml
# kubectl create -f elastic-gke-app.yaml
# kubectl create -f kibana-gke-service.yaml
# kubectl create -f kibana-gke-app.yaml

# Incluir o namespace referente as execucoes no start:
kubectl -n $namespace get jmeter
