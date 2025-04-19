#!/bin/bash 

# asking for github link
echo "→ Enter the GitHub link for the repository:"
read -r GITHUB_LINK

touch github_link.txt
echo $GITHUB_LINK > github_link.txt

mkdir -p repos
DIR_COUNT=$(find repos -mindepth 1 -maxdepth 1 -type d | wc -l)
echo "Number of directories in 'repos': $DIR_COUNT"

git clone "$GITHUB_LINK" "repos/repo-$((DIR_COUNT+1))"
cd repos/"repo-$((DIR_COUNT+1))" 



DIR_COUNT=$((DIR_COUNT+1))

# asking for the project have frontend or backend

echo "→ Does the project have a frontend? (yes/no):"
read -r FRONTEND
if [[ "$FRONTEND" == "yes" ]]; then
    echo "Only React or Node Based Frontend are allowed for now."
    echo "Frontend Directory Name:"
    read -r FRONTEND_DIR
    echo "Frontend Port Number:"
    read -r FR_PORT
    export "MAYA_NEW_${DIR_COUNT}_FR_PORT=$FR_PORT"
    
    echo "You have Dockerfile in the frontend directory? (yes/no):"
    read -r DOCKERFILE_EXISTS
    if [[ "$DOCKERFILE_EXISTS" == "no" ]]; then
        mkdir -p "$FRONTEND_DIR"
        echo "Creating a new Dockerfile..."
        cp ../../Frontend-Dockerfile/Dockerfile "./$FRONTEND_DIR/Dockerfile"
        echo "→ Dockerfile created successfully."
    fi
else
    echo "→ Does the project have a backend? (yes/no):"
    read -r BACKEND
    if [[ "$BACKEND" == "yes" ]]; then
        echo "Only Node Based Backend are allowed for now."
        echo "Backend Directory Name:"
        read -r BACKEND_DIR
        echo "Backend Port Number:"
        read -r BK_PORT
        export "MAYA_NEW_${DIR_COUNT}_BK_PORT=$BK_PORT"
        
        echo "You have Dockerfile in the backend directory? (yes/no):"
        read -r DOCKERFILE_EXISTS
        if [[ "$DOCKERFILE_EXISTS" == "no" ]]; then
            mkdir -p "$BACKEND_DIR"
            echo "Creating a new Dockerfile..."
            cp ../../Backend-Dockerfile/Dockerfile "./$BACKEND_DIR/Dockerfile"
            echo "→ Dockerfile created successfully."
        fi
    fi
fi

# now pipeline time
echo "Do you have already setup a github action pipeline? (yes/no):"
read -r GITHUB_ACTION
if [[ "$GITHUB_ACTION" == "no" ]]; then
  echo "Creating a new GitHub Action Pipeline..."
  mkdir -p .github/workflows
  cp ../../ci-pipeline\ /pipeline.yaml ./.github/workflows/pipeline.yaml
  echo "→ GitHub Action pipeline created successfully."
fi

echo "ALERT SETUP YOUR DOCKERHUB_PAT and DOCKERHUB_USERNAME in the GitHub Secrets."

echo "Give the branch name :"
read -r BRANCH_NAME
git checkout "$BRANCH_NAME"

git add .
git commit -m "Added Dockerfile and GitHub Action pipeline"
git push origin "$BRANCH_NAME"

echo "→ GitHub Action pipeline created successfully."
echo "→ Dockerfile created successfully."

cd ../..
chmod +x choose_infra.sh
./choose_infra.sh