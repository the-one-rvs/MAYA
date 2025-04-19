cd Maya-ECS

echo "Creating ECS cluster..."
echo "Please provide the aws access key ID:"
read -r AWS_ACCESS_KEY_ID
echo "Please provide the aws secret access key:"
read -r AWS_SECRET_ACCESS_KEY
echo "Please provide the docker image name as  [<username>/<image-name>:<tag>]:"
read -r DOCKER_IMAGE
echo "Please provide the port number you have used in Docker Image:"
read -r PORT

cat > terraform.tfvars << EOL
aws_access_key = "${AWS_ACCESS_KEY_ID}"
aws_secret_access_key = "${AWS_SECRET_ACCESS_KEY}"
image = "${DOCKER_IMAGE}"
container_port = "${PORT}"
EOL

echo "Terraform variables have been set up successfully."
echo "Initializing Terraform..."    
terraform init
echo "Terraform initialized successfully."
echo "Applying Terraform configuration..."
terraform apply -auto-approve
echo "Terraform configuration applied successfully."
echo "ECS cluster has been created successfully."
