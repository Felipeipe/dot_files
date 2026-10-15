#!/bin/bash

INSTALL_ALL=false

while getopts "I" opt; do
  case ${opt} in
    I )
      INSTALL_ALL=true
      ;;
    \? )
      echo "Usage: $0 [-I]"
      exit 1
      ;;
  esac
done

if [ "$INSTALL_ALL" = true ]; then
    read -p "Do you want to run the full system installation? [y/N]: " confirm
    confirm=${confirm:-N}

    case "$confirm" in
        [yY]|[yY][eE][sS])
            echo "Starting software and package installation..."
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
                stow \
                zoxide \
                fzf \
                xclip \
                tree \
                openssh-server \
                openssh-client

            sudo apt remove -y $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc 2>/dev/null | cut -f1) 2>/dev/null || true

            sudo apt update
            sudo apt install -y ca-certificates curl
            sudo install -m 0755 -d /etc/apt/keyrings
            sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
            sudo chmod a+r /etc/apt/keyrings/docker.asc

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

            sudo groupadd -f docker
            sudo usermod -aG docker $USER

            RUNZSH=no CHSH=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

            git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 2>/dev/null || true
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 2>/dev/null || true

            DELTA_VERSION=$(curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/dandavison/delta/releases/latest | sed 's|.*/||')
            curl -L https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_$(dpkg --print-architecture).deb -o delta.deb
            sudo dpkg -i delta.deb
            rm delta.deb

            rm -f ~/.zshrc

            echo "Package installation complete."
            ;;
        *)
            echo "Full installation canceled. Applying dotfiles configuration only..."
            ;;
    esac
fi

stow -v --dotfiles --ignore='.*\.sh$' .

if [ "$INSTALL_ALL" = true ]; then
    echo "Process finished! Please log out and log back in or reboot your computer for user/group changes to take effect."
fi
