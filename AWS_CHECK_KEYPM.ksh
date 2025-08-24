
echo "Voir la liste des clés déjà existantes"
aws ec2 describe-key-pairs \
  --query "KeyPairs[*].[KeyName,KeyPairId]" \
  --output table
