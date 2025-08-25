
#!/bin/bash

# Obtenir toutes les AMI Amazon Linux 2 disponibles dans la région eu-central-1
aws ec2 describe-images --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query "Images[*].[ImageId,Name,CreationDate]" \
  --output table \
  --region "eu-central-1"

# Obtenir uniquement la plus récente
aws ec2 describe-images --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query "Images | sort_by(@, &CreationDate)[-1].[ImageId,Name,CreationDate]" \
  --output table \
  --region "eu-central-1"
