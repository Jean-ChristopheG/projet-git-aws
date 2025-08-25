#!/bin/bash

aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-cb8c0ba0" --query "Subnets[*].{ID:SubnetId,AZ:AvailabilityZone,CIDR:CidrBlock}" --output table