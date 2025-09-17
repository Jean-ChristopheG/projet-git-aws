# --- Variables à modifier --- 
$INSTANCE_ID = "i-xxxxxxxxxxxxxxxxx"   # InstanceId EC2
$KEY_PATH    = "C:\chemin\vers\MyWindowsKey.pem"  # chemin local vers ta clé .pem
$REGION      = "us-east-1"             # adapte si besoin
# --- Fin variables ---

# Récupère l'IP publique (optionnel : si tu veux récupérer aussi l'IP via AWS)
$PUBLIC_IP = aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION --query "Reservations[0].Instances[0].PublicIpAddress" --output text
if (-not $PUBLIC_IP -or $PUBLIC_IP -eq "None") {
    Write-Error "Impossible de récupérer l'IP publique. Vérifie que l'instance a une IP publique."
    exit 1
}

Write-Host "IP publique trouvée : $PUBLIC_IP"

# Récupère et déchiffre le mot de passe Admin (AWS CLI fait le déchiffrement avec la .pem)
$PASSWORD = aws ec2 get-password-data --instance-id $INSTANCE_ID --priv-launch-key $KEY_PATH --region $REGION --query PasswordData --output text

if (-not $PASSWORD) {
    Write-Error "Mot de passe indisponible : attends ~4-5 minutes après le lancement, ou vérifie le chemin de la clé."
    exit 1
}

# Crée une entrée d'identifiant pour RDP dans le Credential Manager Windows
cmdkey /generic:"TERMSRV/$PUBLIC_IP" /user:"Administrator" /pass:$PASSWORD

# Lance mstsc vers l'IP publique
Start-Process "mstsc" -ArgumentList "/v:$PUBLIC_IP"

# (Recommandation de sécurité) après ta session RDP, tu peux supprimer le credential :
Write-Host "Pour supprimer les identifiants enregistrés après usage, exécute :"
Write-Host "cmdkey /delete:`"TERMSRV/$PUBLIC_IP`""
