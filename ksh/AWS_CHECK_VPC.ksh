#!/bin/bash

aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-003de46fed7e9d102" --query "Subnets[*].{ID:SubnetId,AZ:AvailabilityZone,CIDR:CidrBlock}" --output table
