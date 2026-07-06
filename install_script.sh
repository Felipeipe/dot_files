#!/bin/bash

# 1. Actualización e instalación de paquetes base
sudo apt update && \
sudo apt upgrade -y && \
sudo apt install -y \
    tmux \
    vim-gtk3 \
    xournalpp \
    zsh \
    bat \
    curl \
    git \
    stow

# 2. Instalación de Docker
sudo apt remove -y $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)

# Add Docker's official GPG key:
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker

# Configuración de grupo Docker (requerirá reiniciar sesión para hacer efecto)
sudo groupadd -f docker
sudo usermod -aG docker $USER
# Nota: Quitamos newgrp docker para que no interrumpa el script. 
# Puedes correr 'docker run hello-world' manualmente después de reiniciar tu sesión.

# 3. Instalación de Oh My Zsh y plugins (Modo desatendido)
RUNZSH=no CHSH=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

rm -f ~/.zshrc

stow -v --dotfiles --ignore='.*\.sh$' .

echo "¡Instalación completada! Por favor, cierra sesión y vuelve a entrar para que los cambios de Docker y Zsh surtan efecto."
