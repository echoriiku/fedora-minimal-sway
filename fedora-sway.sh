#!/bin/bash

# DNF config
echo "max_parallel_downloads=20
defaultyes=True" | sudo tee -a /etc/dnf/dnf.conf

sudo dnf clean all

# install Rpmfusion repo
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

# enable COPRs
sudo dnf copr enable -y atim/bottom
sudo dnf copr enable -y atim/lazygit
sudo dnf copr enable -y varlad/helix
sudo dnf copr enable -y tokariew/glow

sudo dnf upgrade -y --refresh

# grab all packages to install from repos
sudo dnf install $(cat fedora.repopackages) -y

# grab all packages to install from flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub $(cat fedora.flatpackages) -y

# compile and install Cargo packages
echo "export PATH='/home/$USER/.cargo/bin'" >> cargo.sh && sudo mv ./cargo.sh /etc/profile.d/
cargo install $(cat fedora.cargopackages)

# alacritty theme changer
sudo npm i -g alacritty-themes

# sway autotiling
sudo pip install autotiling

# enable fish
chsh -s $(which fish)

# setup dotfiles
echo "Intalling Chezmoi"
sh -c "$(curl -fsLS https://chezmoi.io/get)" -- -b $HOME/.local/bin
chezmoi init --apply https://github.com/echoriiku/dotfiles.git

# font setup
if [[ -d ~/.local/share/fonts/ ]]
then
  echo "Downloading terminal font"
else
  mkdir -vp ~/.local/share/fonts/
fi

cd && wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/CascadiaCode.zip
unzip CascadiaCode.zip -d
sleep 3
echo "Installation complete"