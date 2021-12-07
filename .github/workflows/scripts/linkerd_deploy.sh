#!/usr/bin/env bash

# This script is used to deploy Linkerd on Kubernetes
#
# Also deploys EmojiVoto on Linkerd and exposes the service to Meshery

# See: https://github.com/service-mesh-performance/service-mesh-performance/blob/master/protos/service_mesh.proto
export MESH_NAME='Linkerd'
export SERVICE_MESH='LINKERD'

curl -fsL https://run.linkerd.io/install | sh
export PATH=$PATH:/home/runner/.linkerd2/bin
linkerd version
linkerd check --pre
linkerd install | kubectl apply -f -
linkerd check

curl -fsL https://run.linkerd.io/emojivoto.yml | kubectl apply -f -
# Wait for the application to be ready
sleep 100
kubectl -n emojivoto port-forward svc/web-svc 8080:80 &> /dev/null &
kubectl get -n emojivoto deploy -o yaml | linkerd inject - | kubectl apply -f -
# Wait for the application to be ready
sleep 10

echo "Service Mesh: $MESH_NAME - $SERVICE_MESH"
echo "Endpoint URL: http://localhost:8080"
echo "This is working Navendu. You can relax!"

# Pass the endpoint to be used by Meshery
echo "ENDPOINT_URL=http://localhost:8080" >> $GITHUB_ENV
echo "SERVICE_MESH=$SERVICE_MESH" >> $GITHUB_ENV
