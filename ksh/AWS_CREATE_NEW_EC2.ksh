#!/bin/bash

if [[ $# -lt 2 ]]; then
	echo -e  ""
	echo -e  "Usage: $0 SUBNET_ID SECURITY_GROUP_ID"
	echo -e  "ANOMALIE : le nb de parametre(s) est incorrecte"
	echo -e  ""
	exit 1
fi


# === Paramètres à adapter ===
KEY_NAME="my-new-key.pm"        # Nom de ta clé SSH existante
SUBNET_ID=$1          # ID de ton subnet : subnet-024e768270223fb40
SECURITY_GROUP_ID=$2      # ID du groupe de sécurité   : sg-0557aee05416e693b
INSTANCE_TYPE="t2.micro"                      # Type d'instance
OS_CHOICE="amazon"                            # "amazon" ou "ubuntu"

# === Récupération de la dernière AMI ===
if [ "$OS_CHOICE" == "amazon" ]; then
  echo "🔎 Recherche de la dernière AMI Amazon Linux 2..."
  AMI_ID=$(aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
    --query "Images | sort_by(@, &CreationDate)[-1].ImageId" \
    --output text \
    --region "eu-central-1")
elif [ "$OS_CHOICE" == "ubuntu" ]; then
  echo "🔎 Recherche de la dernière AMI Ubuntu 22.04 LTS..."
  AMI_ID=$(aws ec2 describe-images \
    --owners 099720109477 \
    --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
    --query "Images | sort_by(@, &CreationDate)[-1].ImageId" \
    --output text \
	--region eu-central-1)
else
  echo "❌ Choix OS invalide (utilise 'amazon' ou 'ubuntu')"
  exit 1
fi

echo "✅ AMI trouvée : $AMI_ID"

# === Création de l’instance ===
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --count 1 \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --subnet-id "$SUBNET_ID" \
  --security-group-ids "$SECURITY_GROUP_ID" \
  --associate-public-ip-address \
  --query "Instances[0].InstanceId" \
  --output text \
  --region "eu-central-1")

echo "🚀 Instance lancée : $INSTANCE_ID"

# === Attente de l'IP publique ===
echo "⏳ Attente de l’IP publique..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text \
  --region "eu-central-1")

echo "🌍 Instance disponible !"
echo "   ➡️ Instance ID : $INSTANCE_ID"
echo "   ➡️ IP publique : $PUBLIC_IP"
