#!/bin/bash
# Script pour réparer les fichiers .repo Amazon Linux 2 et installer MariaDB

set -e

echo "[1/4] Sauvegarde des fichiers de repo actuels..."
sudo mkdir -p /etc/yum.repos.d/backup
sudo cp /etc/yum.repos.d/amazonlinux.repo /etc/yum.repos.d/backup/amazonlinux.repo.$(date +%s) || true

echo "[2/4] Téléchargement du repo Amazon Linux 2 par défaut..."
sudo curl -o /etc/yum.repos.d/amazonlinux.repo \
    https://cdn.amazonlinux.com/os-images/2.0/aws/repo/amzn2-core.repo

echo "[3/4] Nettoyage des métadonnées YUM..."
sudo yum clean all

echo "[4/4] Installation de MariaDB..."
sudo yum install -y mariadb

echo "=== Terminé ==="
