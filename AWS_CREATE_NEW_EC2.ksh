#!/bin/bash

# === Paramètres à adapter ===
KEY_NAME="JGDKeyPair"        # Nom de ta clé SSH existante
SUBNET_ID="subnet-837ac4fe"          # ID de ton subnet
SECURITY_GROUP_ID="sg-17e0547a"      # ID du groupe de sécurité
INSTANCE_TYPE="t2.micro"                      # Type d'instance
OS_CHOICE="amazon"                            # "amazon" ou "ubuntu"

# === Récupération de la dernière AMI ===
if [ "$OS_CHOICE" == "amazon" ]; then
  echo "🔎 Recherche de la dernière AMI Amazon Linux 2..."
  AMI_ID=$(aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
    --query "Images | sort_by(@, &CreationDate)[-1].ImageId" \
    --output text)
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
  --output text\
  --region eu-central-1)

echo "🚀 Instance lancée : $INSTANCE_ID"

# === Attente de l'IP publique ===
echo "⏳ Attente de l’IP publique..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text\
  --region eu-central-1)

echo "🌍 Instance disponible !"
echo "   ➡️ Instance ID : $INSTANCE_ID"
echo "   ➡️ IP publique : $PUBLIC_IP"
