
#  Obtenir la dernière AMI Amazon Linux 2 officielle dans la région de Francfort (eu-central-1)
aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" --query "Images[*].[ImageId,Name,CreationDate]" --output table --region eu-central-1
 

# trier par date pour prendre la plus récent dans la région de Francfort (eu-central-1)
aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" --query "Images | sort_by(@, &CreationDate)[-1].[ImageId,Name,CreationDate]" --output table --region eu-central-1


# Exemple : Obtenir la dernière AMI Ubuntu 22.04 LTS dans la région de Francfort (eu-central-1)
aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" --query "Images | sort_by(@, &CreationDate)[-1].[ImageId,Name,CreationDate]"   --output table --region eu-central-1
