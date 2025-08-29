#! /bin/sh

echo "
███╗   ███╗██╗      █████╗ ███╗   ██╗██████╗
████╗ ████║██║     ██╔══██╗████╗  ██║██╔══██╗
██╔████╔██║██║     ███████║██╔██╗ ██║██║  ██║
██║╚██╔╝██║██║     ██╔══██║██║╚██╗██║██║  ██║
██║ ╚═╝ ██║███████╗██║  ██║██║ ╚████║██████╔╝
╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝

Mon script personnel qui configure mon système après une installation de Arch.
C'est aussi un ensemble de fonctions utiles.

Téléchargement : https://mielota.com/scripts/mland.sh
"

dotfiles='https://codeberg.org/mielota/dots'

# Main desktop and apps
desktop="
hyprland
hyprpaper
hyprpicker
hypridle
hyprlock

ghostty
waybar
wmenu
ly

zathura
zathura-pdf-poppler

thunderbird
bitwarden
mpv
yt-dlp
nsxiv

pavucontrol
dunst

grim 
wl-clipboard
slurp

xdg-desktop-portal-hyprland
xdg-user-dirs

ttf-jetbrains-mono-nerd
ttf-nerd-fonts-symbols
"

# IDE
neovim="
neovim

clang
jdk-openjdk
rustup

jdtls
lua-language-server
pyright
vscode-langservers-extracted

prettier
python-black
stylua
google-java-format
"

other="
time
tree
fastfetch 

openssh

grml-zsh-config
zsh
"

dependencies_install() {
  echo "Évaluation des paquets à télécharger"
  packages=$(echo "$other $neovim $desktop" | tr '\n' ' ')
  echo "Paquets à installer : $packages"

  sudo pacman -Sy --noconfirm git
  echo "installation de paru-bin"
  git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin/ && makepkg -si && cd .. && rm -rf paru-bin/

  echo "Installation des paquets"
  paru -Sy --noconfirm $packages

  echo "installation de rustup"
  rustup default stable
  echo "Installation de rust-analyzer"
  rustup component add rust-analyzer
}

clone_conf() {
  echo "Installation de mes dotfiles"
  rm -rf ~/.config
  git clone $dotfiles ~/.config

  echo "Installation du fond d'écran"
  mkdir -p ~/.config/wall
  curl -L "mielota.com/res/tokyo.jpg" -o ~/.config/wall/wall.jpg

  echo "Création des users dirs"
  cd ~
  mkdir code dl music pic pub vid
  xdg-user-dirs-update
  cd -
}

build_blink_neovim() {
  cd ~/.local/share/nvim/lazy/blink.cmp/ && cargo build --release && cd -
}

setup_neovim() {
  echo "Configuration de neovim :"
  sudo pacman -S --needed --noconfirm neovim
  rm -rf ~/.local/*/nvim
  nvim --headless &
  sleep 12
  pkill nvim
  build_blink_neovim
}

setup_firefox() {
  echo "Configuration de archenfox"
  sudo pacman -S --needed --noconfirm firefox 
  rm -rf .mozilla
  firefox --headless &
  sleep 2
  pkill firefox
  git clone https://github.com/arkenfox/user.js && mv user.js/* ~/.mozilla/firefox/*.default-release/ && rm -rf user.js/
}

mland_install() {
  dependencies_install

  chsh -s /usr/bin/zsh

  clone_conf

  setup_neovim quiet

  setup_firefox
  
  echo "Activation de ly"
  sudo systemctl enable ly

  echo "FIN DE L'INSTALLATION"
  return 0
}
