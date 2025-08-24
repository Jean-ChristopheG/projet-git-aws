SECURITY_GROUP_ID=$2
EC2_INSTANCE_ID=$1
EC2_PRIVATE_IP=$3
REGION="eu-central-1"


aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 3306 \
  --cidr $EC2_PRIVATE_IP/32 \
  --region $REGION
