# rename EC2 id
aws ec2 create-tags --resources i-0f3b08559f93e9aa3 --tags Key=Name,Value="EC2-JGD-Linux-Amazon"

# check the new name
aws ec2 describle-instances --instance-ids i-0f3b08559f93e9aa3 --query "Reservations[0].Instances[0].Tags"

