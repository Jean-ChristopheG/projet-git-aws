#!/usr/bin/ksh

# Variables
REGION="eu-central-1"
EC2_INSTANCE_ID=$1
SECURITY_GROUP_ID=$2
RDS_ENDPOINT=$3
DB_USER="root"

# 1. Récupérer IP privée de l'EC2
EC2_PRIVATE_IP=$(aws ec2 describe-instances \
  --instance-ids "$EC2_INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PrivateIpAddress" \
  --output text \
  --region "$REGION")

print "IP privée EC2 : $EC2_PRIVATE_IP"

# 2. Ajouter la règle de sécurité pour MySQL
aws ec2 authorize-security-group-ingress \
  --group-id "$SECURITY_GROUP_ID" \
  --protocol tcp \
  --port 3306 \
  --cidr "$EC2_PRIVATE_IP/32" \
  --region "$REGION"

print "Règle ajoutée pour autoriser $EC2_PRIVATE_IP à accéder au port 3306."

# 3. Test de connexion MySQL depuis EC2
print "Pour tester depuis EC2, exécutez :"
print "mysql -h $RDS_ENDPOINT -u $DB_USER -p"
