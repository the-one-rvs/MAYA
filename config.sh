#!/usr/bin/bash

# Check if command exists
command_exists() {
  command -v "$1" &>/dev/null
}

# Detect OS: "linux" or "macos"
detect_os() {
  case "$(uname -s)" in
    Linux*)  echo "linux" ;;
    Darwin*) echo "macos" ;;
    *)       echo "unknown" ;;
  esac
}

install_docker() {
  if command_exists docker; then
    echo "✔ Docker already installed"
    return
  fi
  echo "→ Installing Docker..."
  if [[ "$OS" == "linux" ]]; then
    sudo apt-get update
    sudo apt-get install -y \
      apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
      "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker "$USER"
  else
    brew install --cask docker
  fi
  echo "✔ Docker installed"
}

install_terraform() {
  if command_exists terraform; then
    echo "✔ Terraform already installed"
    return
  fi
  echo "→ Installing Terraform..."
  if [[ "$OS" == "linux" ]]; then
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository \
      "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com \
      $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install -y terraform
  else
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
  fi
  echo "✔ Terraform installed"
}

install_ansible() {
  if command_exists ansible; then
    echo "✔ Ansible already installed"
    return
  fi
  echo "→ Installing Ansible..."
  if [[ "$OS" == "linux" ]]; then
    sudo apt-get update && sudo apt-get install -y software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt-get install -y ansible
  else
    brew install ansible
  fi
  echo "✔ Ansible installed"
}

install_awscli() {
  if command_exists aws; then
    echo "✔ AWS CLI already installed"
    return
  fi
  echo "→ Installing AWS CLI v2..."
  if [[ "$OS" == "linux" ]]; then
    tmpdir=$(mktemp -d)
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$tmpdir/awscliv2.zip"
    unzip "$tmpdir/awscliv2.zip" -d "$tmpdir"
    sudo "$tmpdir"/aws/install
    rm -rf "$tmpdir"
  else
    brew install awscli
  fi
  echo "✔ AWS CLI installed"
}

main() {
  echo "=== config.sh: installing selected prerequisites ==="
  OS=$(detect_os)
  if [[ "$OS" == "unknown" ]]; then
    echo "❌ Unsupported OS. Exiting."
    exit 1
  else
    echo "Detected OS: $OS"
  fi

  install_docker
  install_terraform
  install_ansible
  install_awscli

  echo
  echo "🎉 Done! Only missing tools were installed."
  echo "→ If you just added your user to the 'docker' group, log out and back in."
}

main "$@"
