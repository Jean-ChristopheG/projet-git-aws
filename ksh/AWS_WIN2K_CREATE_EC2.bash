#!/bin/bash 
set -e

### --- VARIABLES ---
REGION=eu-central-1            # adapte si nécessaire
KEY_NAME=MyWindowsKey
SEC_GROUP=WinSecGroup
INSTANCE_NAME=WinFreeTier

echo "=== Création de la clé SSH ==="
if ! aws ec2 describe-key-pairs --key-names $KEY_NAME --region $REGION >/dev/null 2>&1; then
  aws ec2 create-key-pair \
    --key-name $KEY_NAME \
    --region $REGION \
    --query 'KeyMaterial' \
    --output text > ${KEY_NAME}.pem
  chmod 400 ${KEY_NAME}.pem
  echo "Clé créée et sauvegardée dans ${KEY_NAME}.pem"
else
  echo "Clé $KEY_NAME déjà existante"
fi

echo "=== Création du Security Group ==="
VPC_ID=$(aws ec2 describe-vpcs --region $REGION --query "Vpcs[0].VpcId" --output text)

if ! aws ec2 describe-security-groups --group-names $SEC_GROUP --region $REGION >/dev/null 2>&1; then
  aws ec2 create-security-group \
    --group-name $SEC_GROUP \
    --description "Security group for Windows RDP" \
    --vpc-id $VPC_ID \
    --region $REGION
fi

SEC_GROUP_ID=$(aws ec2 describe-security-groups \
  --group-names $SEC_GROUP \
  --region $REGION \
  --query 'SecurityGroups[0].GroupId' \
  --output text)

MY_IP=$(curl -s https://checkip.amazonaws.com)/32
aws ec2 authorize-security-group-ingress \
  --group-id $SEC_GROUP_ID \
  --protocol tcp \
  --port 3389 \
  --cidr $MY_IP \
  --region $REGION || true

echo "=== Recherche de l’AMI Windows Server Free Tier ==="
AMI_ID=$(aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=Windows_Server-2019-English-Full-Base-*" \
  "Name=state,Values=available" \
  --region $REGION \
  --query 'Images | sort_by(@, &CreationDate)[-1].ImageId' \
  --output text)

echo "AMI sélectionnée : $AMI_ID"

echo "=== Lancement de l’instance EC2 ==="
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --count 1 \
  --instance-type t2.micro \
  --key-name $KEY_NAME \
  --security-group-ids $SEC_GROUP_ID \
  --associate-public-ip-address \
  --region $REGION \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "Instance lancée : $INSTANCE_ID"

echo "=== Attente que l’instance soit prête (2-3 min) ==="
aws ec2 wait instance-status-ok --instance-ids $INSTANCE_ID --region $REGION
echo "Instance opérationnelle."

echo "=== Récupération de l’adresse publique ==="
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --region $REGION \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "Adresse publique de la VM Windows : $PUBLIC_IP"

echo "=== ATTENTION : le mot de passe Windows sera dispo après ~4-5 minutes ==="
echo "Commande pour récupérer le mot de passe :"
echo "aws ec2 get-password-data --instance-id $INSTANCE_ID --priv-launch-key ${KEY_NAME}.pem --region $REGION --query PasswordData --output text"

echo "=== Connexion RDP ==="
echo "Utilise un client RDP (mstsc sur Windows) avec :"
echo "Adresse : $PUBLIC_IP"
echo "Utilisateur : Administrator"
echo "Mot de passe : (commande ci-dessus après 5 min)"
