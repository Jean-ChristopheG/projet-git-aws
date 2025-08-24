EC2_INSTANCE_ID=$1
REGION="eu-central-1"

EC2_PRIVATE_IP=$(aws ec2 describe-instances \
  --instance-ids $EC2_INSTANCE_ID \
  --query "Reservations[0].Instances[0].PrivateIpAddress" \
  --output text \
  --region $REGION)

echo $EC2_PRIVATE_IP
