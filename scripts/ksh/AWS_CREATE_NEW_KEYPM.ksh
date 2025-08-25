
echo "créer une nouvelle clé key pem"
aws ec2 create-key-pair \
  --key-name my-new-key \
  --query "KeyMaterial" \
  --output text > my-new-key.pem
chmod 400 my-new-key.pem
