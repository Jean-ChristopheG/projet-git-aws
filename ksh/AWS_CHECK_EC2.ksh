
#!/bin/bash

aws ec2 describe-instances --filters "Name=vpc-id,Values=vpc-cb8c0ba0" --query "Reservations[*].Instances[*].{ID:InstanceId,Type:InstanceType,State:State.Name}" --output table