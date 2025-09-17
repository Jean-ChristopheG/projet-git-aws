
#!/bin/bash

set -x

# Dossier source dans CloudShell
SOURCE_DIR="/home/cloudshell-user"

# Créer un nom de bucket unique
BUCKET_NAME="transfert-$(date +%Y%m%d-%H%M%S)-$RANDOM"

# Créer le bucket (ajuste la région si nécessaire)
aws s3 mb s3://$BUCKET_NAME --region eu-central-1

# Copier les fichiers vers S3
aws s3 cp "$SOURCE_DIR" s3://$BUCKET_NAME/ --recursive --exclude "*" --include "*.ksh"


# 5. vérification du contenu
aws s3 ls //$BUCKET_NAME/



# Afficher la commande Windows avec création auto du dossier
echo "Pour télécharger les fichiers sur ton PC Windows, exécute dans PowerShell :"
echo "if (!(Test-Path 'C:\\temp')) { New-Item -ItemType Directory -Path 'C:\\temp' } ; aws s3 cp s3://$BUCKET_NAME C:\\temp\\ --recursive"

# depuis PS1
#***********************************************
#AWS Access Key ID [None]: AKIATEW5CFUJH6ZYAUGR
#AWS Secret Access Key [None]: ???
#Default region name [None]: eu-central-1
#Default output format [None]: table