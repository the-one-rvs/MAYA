echo "Please tell me about your project infrastructure for orchestration.(kind, EKS, ECS, None)"
read -r INFRA

if ([[ "$INFRA" == "kind" ]] || [[ "$INFRA" == "EKS" ]] || [[ "$INFRA" == "ECS" ]] || [[ "$INFRA" == "None" ]]); then
    echo "→ Infrastructure: $INFRA"
else
    echo "Invalid input. Please enter either 'kind', 'EKS', or 'ECS'."
    exit 1
fi
if [[ "$INFRA" == "kind" ]]; then
    chmod +x kind.sh
    ./kind.sh
elif [[ "$INFRA" == "EKS" ]]; then
    chmod +x eks.sh
    # ./eks.sh
    echo "EKS infrastructure setup is not implemented yet."
elif [[ "$INFRA" == "ECS" ]]; then
    chmod +x ecs.sh
    ./ecs.sh
elif [[ "$INFRA" == "None" ]]; then
    echo "No infrastructure selected."
else
    echo "Invalid input. Please enter either 'kind', 'EKS', or 'ECS'."
    exit 1
fi