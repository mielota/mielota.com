#! /bin/sh

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

# FILL THOSE VARS
rootpasswd=""
username=""
userpasswd=""

hostname=""
packages="linux linux-firmware sof-firmware base base-devel grub efibootmgr networkmanager neovim pipewire pipewire-pulse wireplumber"

echo "Sécurité active, supprimez moi du script pour lancer l'installation." ; exit 1

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

### Functions

catch_failure() {
  echo "Une erreur est survenue. Arrêt du programme"
  sleep 3
  exit 1
}

close() {
  echo "Fin, redémarrage dans 10 secondes."
  echo "TODO : se connecter à internet, décommenter wheel dans sudoers, xdg-user-dirs-update"
  sleep 10
  reboot
}

ch() {
  arch-chroot /mnt /bin/sh -c "$@" || catch_failure
}

### Main

echo "

███╗   ███╗ █████╗ ██████╗  ██████╗██╗  ██╗
████╗ ████║██╔══██╗██╔══██╗██╔════╝██║  ██║
██╔████╔██║███████║██████╔╝██║     ███████║
██║╚██╔╝██║██╔══██║██╔══██╗██║     ██╔══██║
██║ ╚═╝ ██║██║  ██║██║  ██║╚██████╗██║  ██║
╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝

Mon script personnel pour installer Arch.
Téléchargement : https://www.mielota.com/scripts/march.sh

Démarrage du programme dans 5 secondes ! Toutes les données du disque seront effacées !
"
sleep 5

echo "Configuration de timedatectl..."
timedatectl set-timezone Europe/Paris || catch_failure

echo "Partition des disques..."
(
echo g
echo n 
echo 1
echo
echo +1G
echo t
echo 1
echo 1
echo n
echo 2
echo
echo
echo w
) | fdisk "/dev/nvme0n1" &> /dev/null || catch_failure

echo "Formattage du disque..."

echo "Formattage du ESP..."
yes | mkfs.fat -F 32 -n ESP /dev/nvme0n1p1 || catch_failure

echo "Formattage du ROOT..."
yes | mkfs.ext4 -L ROOT /dev/nvme0n1p2 || catch_failure

echo "Montage des partitions..."

echo "Montage de ROOT sur /mnt"
mount /dev/disk/by-label/ROOT /mnt || catch_failure

echo "Montage de ESP sur /mnt/boot/EFI"
mount --mkdir /dev/disk/by-label/ESP /mnt/boot/EFI || catch_failure

echo "Configuration des mirroirs de pacstrap... (peut prendre un moment)"
reflector --country France --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist || catch_failure

echo "Installation des paquets de base sur le système..."
pacstrap -K /mnt --noconfirm $packages || catch_failure

echo "Génération du fstab..."
genfstab -U /mnt >> /mnt/etc/fstab || catch_failure

echo "ARCH CHROOT"
echo "Configurer le temps..."
ch "ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime"
ch "hwclock --systohc"

echo "Configuration des langues..."
ch "echo 'fr_FR.UTF-8 UTF-8' >> /etc/locale.gen"
ch "locale-gen"
ch "echo 'LANG=fr_FR.UTF-8' > /etc/locale.conf"

echo "Configuration du KEYMAP vconsole..."
ch "echo 'KEYMAP=fr-latin1' > /etc/vconsole.conf"

echo "Application du hostname $hostname..."
ch "echo '$hostname' > /etc/hostname"

echo "Activation du service NetworkManager..."
ch "systemctl enable NetworkManager"

echo "Configuration du mot de passe root $rootpasswd..."
ch "echo 'root:$rootpasswd' | chpasswd"

echo "Configuration de l'utilisateur $username"
ch "useradd -m -G wheel $username"

echo "Configuration du mot de passe de $username $userpasswd"
ch "echo '$username:$userpasswd' | chpasswd"

echo "Configuration de GRUB"
echo "Installation..."
ch "grub-install --target=x86_64-efi --efi-directory=/boot/EFI"

echo "Génération de grub.cfg..."
ch "grub-mkconfig -o /boot/grub/grub.cfg"

close
