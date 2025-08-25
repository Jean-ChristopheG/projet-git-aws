#!/bin/bash

aws ec2 describe-route-tables --filters "Name=vpc-id,Values=vpc-cb8c0ba0" --query "RouteTables[*].{ID:RouteTableId,Routes:Routes}" --output table