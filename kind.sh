#!/bin/bash

if ! command -v kind &> /dev/null; then
    echo "kind is not installed. Installing kind..."
    
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
    
    echo "kind has been installed successfully."
else
    echo "kind is already installed."
fi

if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Installing kubectl..."
    
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
    
    echo "kubectl has been installed successfully."
else
    echo "kubectl is already installed."
fi

if ! command -v kubelet &> /dev/null; then
    echo "kubelet is not installed. Installing kubelet..."
    
    sudo apt-get update
    sudo apt-get install -y kubelet
    
    echo "kubelet has been installed successfully."
else
    echo "kubelet is already installed."
fi

kind create cluster --name maya-cluster --config kind-config.yaml

echo "kind cluster 'maya-cluster' has been created successfully."

echo "<== Take a look at your DockerHub ==>"
echo "What's your Docker Image is give answer in format <dockerhubusername>/<image> --Don't give tag-- ==>>"

read -r $DOCKER_IMAGE

echo "What's your Docker Image Tag? (check on Dockerhub) "
read -r TAG

echo " What's the port number you want to expose? "
read -r PORT

echo "What's the Node Port number you want to expose? "
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

echo "Helm values.yaml file has been created successfully with the provided details."

kubectl use-context kind-maya-cluster
echo "Switched to kind-maya-cluster context."

DIR_COUNT=$(find repos -mindepth 1 -maxdepth 1 -type d | wc -l)
echo "Number of directories in 'repos': $DIR_COUNT"

cd "repos/repo-$((DIR_COUNT))"
mkdir -p Maya-Kind-Manifest
cp -r ../../Maya-Kind/ Maya-Kind-Manifest

echo "Give the branch name :"
read -r BRANCH_NAME
git checkout  "$BRANCH_NAME"
git add .
git commit -m "Added Maya-Kind-Manifest directory with Helm chart and values.yaml"
git push origin "$BRANCH_NAME"
echo "Changes have been committed and pushed to the branch $BRANCH_NAME."
echo "🎉 Done! Your kind cluster is set up and ready to use."

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
    echo "ArgoCD application has been created successfully."
else
    echo "Error: github_link.txt does not exist."
    exit 1
fi

echo "🎉 Done! Your Application is now deployed"
rm -rf github_link.txt

echo "Let's Create a Monitoring Server"

