#!/usr/bin/ksh

# Variables
REGION="eu-central-1"
DB_IDENTIFIER="my-mysql-db"
DB_CLASS="db.t3.micro"
DB_ENGINE="mysql"
DB_USER="root"
DB_PASS="mypassword38"
DB_STORAGE=20
SUBNET_GROUP_NAME="ec2-rds-1"
VPC_SECURITY_GROUP_ID=$2
EC2_INSTANCE_ID=$1

# 1. Récupérer l'adresse IP privée de l'EC2
EC2_PRIVATE_IP=$(aws ec2 describe-instances \
  --instance-ids "$EC2_INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PrivateIpAddress" \
  --output text \
  --region "$REGION")

echo "IP privée de l'EC2 : $EC2_PRIVATE_IP"

# 2. Ajouter une règle de sécurité pour MySQL
aws ec2 authorize-security-group-ingress \
  --group-id "$VPC_SECURITY_GROUP_ID" \
  --protocol tcp \
  --port 3306 \
  --cidr "$EC2_PRIVATE_IP/32" \
  --region "$REGION"

echo "Règle MySQL ajoutée pour l'IP $EC2_PRIVATE_IP"

# 3. Vérifier / créer DB Subnet Group
aws rds describe-db-subnet-groups \
  --db-subnet-group-name "$SUBNET_GROUP_NAME" \
  --region "$REGION" >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Création du Subnet Group RDS..."
    SUBNET_IDS=$(aws ec2 describe-subnets \
      --filters "Name=default-for-az,Values=true" \
      --query "Subnets[*].SubnetId" \
      --output text \
      --region "$REGION")

    aws rds create-db-subnet-group \
      --db-subnet-group-name "$SUBNET_GROUP_NAME" \
      --db-subnet-group-description "Subnet group pour RDS MySQL" \
      --subnet-ids $SUBNET_IDS \
      --region "$REGION"
else
    echo "Subnet Group $SUBNET_GROUP_NAME déjà existant."
fi

# 4. Créer l'instance RDS
echo "Création de l'instance RDS MySQL..."
aws rds create-db-instance \
  --db-instance-identifier "$DB_IDENTIFIER" \
  --db-instance-class "$DB_CLASS" \
  --engine "$DB_ENGINE" \
  --master-username "$DB_USER" \
  --master-user-password "$DB_PASS" \
  --allocated-storage "$DB_STORAGE" \
  --backup-retention-period 7 \
  --no-publicly-accessible \
  --vpc-security-group-ids "$VPC_SECURITY_GROUP_ID" \
  --db-subnet-group-name "$SUBNET_GROUP_NAME" \
  --region "$REGION"

# 5. Attendre la disponibilité
echo "Attente que l'instance RDS soit disponible..."
aws rds wait db-instance-available \
  --db-instance-identifier "$DB_IDENTIFIER" \
  --region "$REGION"

# 6. Afficher l'endpoint
ENDPOINT=$(aws rds describe-db-instances \
  --db-instance-identifier "$DB_IDENTIFIER" \
  --query "DBInstances[0].Endpoint.Address" \
  --output text \
  --region "$REGION")

echo "Instance RDS prête !"
echo "Endpoint de connexion : $ENDPOINT"
