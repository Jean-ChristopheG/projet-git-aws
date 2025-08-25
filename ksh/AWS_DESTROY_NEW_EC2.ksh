#!/bin/bash

# === Paramètres à adapter ===
KEY_NAME="JGDKeyPair"        	# Nom de ta clé SSH existante
SUBNET_ID="subnet-837ac4fe"     # ID de ton subnet
INSTANCE_ID=$1
SECURITY_GROUP_ID=$2    		# ID du groupe de sécurité
INSTANCE_TYPE="t2.micro"        # Type d'instance
OS_CHOICE="amazon"              # "amazon" ou "ubuntu"

# === Fonction pour détruire une instance ===
destroy_instance() {
    if [ -z "$INSTANCE_ID" ]; then
    echo "❌ Merci de préciser l’Instance ID :"
    exit 1
  fi

  echo "🗑️ Suppression de l’instance $INSTANCE_ID ..."
  aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" > /dev/null
  aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID"
  echo "✅ Instance $INSTANCE_ID supprimée."
}

# === Menu principal ===

   
    echo "⚙️ Usage :"
    echo "   destroy_instance  # Détruire une instance"
	destroy_instance $INSTANCE_ID

