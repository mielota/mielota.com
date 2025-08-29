# mielota.com

## Intro

Ce repo contient le code source de [mon site.](https://mielota.com) 

> [!WARNING]
> Tout contenu présent dans res/ est soumis aux clauses de sa propre licence.

## march.sh

Voir [march.sh](https://codeberg.org/mielota/mielota.com/src/branch/main/scripts/march.sh)

march.sh est un script visant à installer Arch Linux sur un système EFI x86_64. Il suppose également que votre disque est nommé 'nvme...'.
Il configure l'os pour une personne vivant en France.

> [!WARNING]
> Le script supprime l'intégrité des données du disque, veillez bien à lire le contenu du script.

### Installation

1. Démarrer sur votre medium d'installation d'Arch Linux.

2. Télécharger le script

```sh
curl -LO mielota.com/scripts/march.sh
```

3. Vous devez remplir les variables au début du fichier et enlever la sécurité.

4. Éxécutez le script :

```sh
sh march.sh
```

## mland.sh

Voir [mland.sh](https://codeberg.org/mielota/mielota.com/src/branch/main/scripts/mland.sh)

mland.sh est un script visant à configurer automatiquement mon système suite à une installation fraiche d'Arch Linux.

### Installation

1. Télécharger le script :

```sh
curl -LO mielota.com/scripts/mland.sh
```

2. Chargez les fonctions du script dans votre session :

```sh
source mland.sh
```

3. Vous pouvez installer et tout configurer automatiquement à l'aide de :
```sh
mland_install
```

## Svp

Ces scripts me permettent surtout d'automatiser tout le travail ennuyant que nécessite l'installation et la configuration de mon système
