#!/usr/bin/ksh

# Variables
REGION="eu-central-1"
EC2_INSTANCE_ID=$1
SECURITY_GROUP_ID=$2
RDS_ENDPOINT=$3
DB_USER="root"
KEY_PATH="./JGDKeyPair.pem"
EC2_USER="ec2-user"  # Amazon Linux 2
DB_NAME="mysql"      # Base par défaut

# 1. Récupérer IP publique de l'EC2
EC2_PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "$EC2_INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text \
  --region "$REGION")

echo "IP publique EC2 : $EC2_PUBLIC_IP"

EC2_PRIVATE_IP=$(aws ec2 describe-instances \
  --instance-ids $EC2_INSTANCE_ID \
  --query "Reservations[0].Instances[0].PrivateIpAddress" \
  --output text \
  --region $REGION)

echo "IP private EC2 : $EC2_PRIVATE_IP"


# 2. Ajouter la règle MySQL (si non présente)
aws ec2 authorize-security-group-ingress \
  --group-id "$SECURITY_GROUP_ID" \
  --protocol tcp \
  --port 3306 \
  --cidr "$EC2_PRIVATE_IP/32" \
  --region "$REGION" 2>/dev/null

print "Règle de sécurité ajoutée (ou déjà existante) pour IP $EC2_PRIVATE_IP."

# 3. Connexion SSH et test MySQL
print "Connexion à EC2 et test MySQL..."
ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" "$EC2_USER@$EC2_PUBLIC_IP" \
    "mysql -h $RDS_ENDPOINT -u $DB_USER -p -e 'SHOW DATABASES;' $DB_NAME"
