#!/bin/bash

INSTANCE_ID=$1
KEY_PATH=$2  
REGION=eu-central-1
USER="ec2-user"  # ou ubuntu / admin selon l'AMI

if [ -z "$INSTANCE_ID" ]; then
  echo "Usage: $0 <instance-id> [key.pem]"
  exit 1
fi

echo "======================================================"
echo " 🔍 Vérification de l'accès à l'instance $INSTANCE_ID"
echo "======================================================"

# Récupérer IP publique et SG
INFO=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query "Reservations[0].Instances[0].{State:State.Name,PublicIP:PublicIpAddress,SG:SecurityGroups[*].GroupId}" \
  --output json)

echo $INFO

# Récupérer IP privé
MY_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query "Reservations[0].Instances[0].PrivateIpAddress" \
  --output text \
  --region $REGION)
  

STATE=$(echo $INFO | jq -r .State)
PUBLIC_IP=$(echo $INFO | jq -r .PublicIP)
PRIVATE_IP=$MY_IP
SG_IDS=$(echo $INFO | jq -r .SG[""])

echo "➡️  État: $STATE"
echo "➡️  IP Publique: $PUBLIC_IP"
echo "➡️  IP Privée: $PRIVATE_IP"
echo "➡️  SG: $SG_IDS"
echo ""

string="$PUBLIC_IP"
NEW_PUBLIC_IP=`echo "${string//./-}"`

# retourne mon IP local à utiliser dans les règles entrantes
MY_IP_LOCAL=$(curl -s ifconfig.me)
echo $MY_IP_LOCAL



# Vérifier si SSH (port 22) est autorisé depuis ta machine
ALLOW_SSH=false



# MY_IP=$(curl -s ifconfig.me)

for SG in $SG_IDS; do
  RULES=$(aws ec2 describe-security-groups --group-ids $SG \
    --query "SecurityGroups[0].IpPermissions[?FromPort==\`22\` && ToPort==\`22\`]" \
    --output json)

echo " -> RULES : " $RULES


  if echo $RULES | grep -q "0.0.0.0/0"; then
    ALLOW_SSH=true
  elif echo $RULES | grep -q "$PRIVATE_IP"; then
    ALLOW_SSH=true
  fi
done

echo " -> ALLOW_SSH : " $ALLOW_SSH


# --- Tentative de connexion SSH ---
if [ "$ALLOW_SSH" = true ] && [ -n "$PUBLIC_IP" ] && [ -n "$KEY_PATH" ]; then
  echo "✅ SSH autorisé sur le port 22 depuis ton IP."
  echo "👉 Connexion avec la clé PEM..."
  ssh -i "$KEY_PATH" $USER@ec2-$NEW_PUBLIC_IP.eu-central-1.compute.amazonaws.com
  exit 0
else
  echo "⚠️  SSH direct non possible (pas d'IP publique, pas de clé PEM ou SG fermé)."
fi

# --- Fallback vers Session Manager (SSM) ---
#echo ""
#echo "👉 Tentative de connexion via AWS SSM..."
#aws ssm start-session --target $INSTANCE_ID
