#!/bin/bash

if ! command -v kind &> /dev/null; then
    echo "kind is not installed. Installing kind..."
    
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
    
    echo "🛠️ kind has been installed successfully."
else
    echo "🛠️ kind is already installed."
fi

if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Installing kubectl..."
    
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
    
    echo "🛠️ kubectl has been installed successfully."
else
    echo "🛠️ kubectl is already installed."
fi

if ! command -v kubelet &> /dev/null; then
    echo "kubelet is not installed. Installing kubelet..."
    
    sudo apt-get update
    sudo apt-get install -y kubelet
    
    echo "🛠️ kubelet has been installed successfully."
else
    echo "🛠️ kubelet is already installed."
fi

kind create cluster --name maya-cluster --config kind-config.yaml

echo "kind cluster 'maya-cluster' has been created successfully."

echo "<== Take a look at your DockerHub 👨‍💻  ==>"
echo "🧿 🧐🔍 What's your Docker Image is give answer in format <dockerhubusername>/<image> --Don't give tag-- ==>> 🧿 "

read -r $DOCKER_IMAGE

echo "🧐🔍 What's your Docker Image Tag? (check on Dockerhub) 👨‍💻 "
read -r TAG

echo " What's the port number you want to expose? 🧪"
read -r PORT

echo "What's the Node Port number you want to expose? 🧪"
read -r NODE_PORT


# touch Maya-Kind/image.txt
# echo $DOCKER_IMAGE > Maya-Kind/image.txt

# echo "Docker image $DOCKER_IMAGE has been saved to Maya-Kind/image.txt"

cat > Maya-Kind/Helm/values.yaml << EOL
image:
  repository: ${DOCKER_IMAGE}
  tag: ${TAG:-latest}
  pullPolicy: IfNotPresent

replicaCount: 1

service:
  type: NodePort
  port: ${PORT}
  targetPort: ${PORT}
  nodePort: ${NODE_PORT}
EOL

echo "✅ Helm values.yaml file has been created successfully with the provided details."

kubectl use-context kind-maya-cluster
echo "🧐🔍 Switched to kind-maya-cluster context."

curl -sSLo k9s_Linux_amd64.tar.gz https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
tar -xzf k9s_Linux_amd64.tar.gz
sudo mv k9s /usr/local/bin/
echo "✅ k9s has been installed successfully."


DIR_COUNT=$(find repos -mindepth 1 -maxdepth 1 -type d | wc -l)
echo "Number of directories in 'repos': $DIR_COUNT"

cd "repos/repo-$((DIR_COUNT))"
mkdir -p Maya-Kind-Manifest
cp -r ../../Maya-Kind/Helm Maya-Kind-Manifest

echo "Give the branch name :"
read -r BRANCH_NAME
git checkout  "$BRANCH_NAME"
git add .
git commit -m "Added Maya-Kind-Manifest directory with Helm chart and values.yaml"
git push origin "$BRANCH_NAME"
echo "Changes have been committed and pushed to the branch $BRANCH_NAME."
echo "🎉 Done! Your kind cluster is set up and ready to use."

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "🎉 ArgoCD is installed"

if [ -f github_link.txt ]; then
    GITHUB_LINK=$(cat github_link.txt)
    echo "GitHub Link: $GITHUB_LINK"
    
    # Create ArgoCD application manifest
    cat > argocd-app.yaml << EOL
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: maya-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: ${GITHUB_LINK}
    targetRevision: ${BRANCH_NAME}
    path: Maya-Kind-Manifest
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOL

    # Apply the ArgoCD application
    kubectl apply -f argocd-app.yaml
    echo "✅ ArgoCD application has been created successfully."
else
    echo "Error: github_link.txt does not exist."
    exit 1
fi

echo "🎉 Done! Your Application is now deployed ✅"
rm -rf github_link.txt

echo "🎯 Let's Create a Monitoring Server"

echo "🧑‍🔧 Listen You have to add the metrics you have to setup in index.js file 🧑‍🔧"
echo "🧑‍🔧 Listen Maya Can Only Deploy the Monitoring Server 🧑‍🔧"
echo "🧑‍🔧 You have to manually create the grafana dashboards and prometheus alerts 🧑‍🔧"

echo "🎯 Do you want to create a monitoring server? (yes/no)"
read -r CREATE_MONITORING_SERVER
if [ "$CREATE_MONITORING_SERVER" == "yes" ]; then
    echo "⚙️ Creating monitoring server..."
    helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring -f ./custom_kube_prometheus_stack.yml
    echo "✅ Monitoring server has been created successfully."
    cp -r ../../svcmonitor.yaml ./Maya-Kind-Manifest/svcmonitor.yaml
    git add .
    git commit -m "Added svcmonitor.yaml for monitoring server"
    git push origin "$BRANCH_NAME"
    echo "✅ svcmonitor.yaml has been added and pushed to the branch $BRANCH_NAME."
else
    echo "✅ Skipping monitoring server creation."
fi

echo "🎯 Do you want to create a tunnel to expose your service? (yes/no)"
read -r CREATE_TUNNEL

if [ "$CREATE_TUNNEL" == "yes" ]; then
  if ! command -v ngrok &> /dev/null; then
    echo "🧐🔍 ngrok is not installed. Installing ngrok..."

    curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
    sudo apt-get update
    sudo apt-get install -y ngrok
    echo "🧐🔍 Go to ngrok website login/signup to get the ngrok auth token"
    echo "Please enter your ngrok auth token:"
    read -r NGROK_AUTH_TOKEN
    ngrok authtoken $NGROK_AUTH_TOKEN

    echo "✅ ngrok has been installed successfully."
  else
    echo "✅ ngrok is already installed."
  fi

  echo "Give the WORKER Node Ip of your kind cluster"
  read -r "NODE_IP"

  echo "We are almost done! Let's create a tunnel to expose your service."
  ngrok http $NODE_IP:$NODE_PORT
  echo "✅ Enjoy your ngrok tunnel!"

  echo "✅ Ngrok tunnel has been created successfully."
else 
  echo "✅ Skipping tunnel creation."
  echo "✅ Done! Your Cluster is up and running."
fi

echo "🎉 Done! Your kind cluster is set up and ready to use."