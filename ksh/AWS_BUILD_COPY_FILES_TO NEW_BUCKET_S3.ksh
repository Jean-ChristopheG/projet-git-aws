
#!/bin/bash

# 1. Définir le dossier source à transférer
SOURCE_DIR="/home/cloudshell-user/*.ksh"

# 2. Créer un nom de bucket unique
BUCKET_NAME="transfert-$(date +%Y%m%d-%H%M%S)-$RANDOM"

# 3. Créer le bucket (choisir la bonne région)
aws s3 mb s3://$BUCKET_NAME --region eu-west-3

# 4. Copier les fichiers vers S3
aws s3 cp "$SOURCE_DIR" s3://$BUCKET_NAME/ --recursive

# 5. Afficher la commande à exécuter sur le PC local pour télécharger
echo "Pour télécharger les fichiers sur votre PC local, exécutez :"
echo "aws s3 cp s3://$BUCKET_NAME/ C:\business\knowledgedb\WORKSHOP\DevOps\Git\Jean-ChristopheG\desktop\projet-git-aws\scripts\ksh --recursive"

# 6. supprime tous les fichiers (directory et subdir)
aws s3 rm s3://$BUCKET_NAME/ --recursive
aws s3 rb s3://$BUCKET_NAME --force