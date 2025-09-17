#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <security-group-id>"
  exit 1
fi

SG_ID=$1

echo "======================================="
echo " 🔒 RÈGLES DU SECURITY GROUP : $SG_ID"
echo "======================================="

# --- Infos générales sur le SG ---
aws ec2 describe-security-groups \
  --group-ids $SG_ID \
  --query "SecurityGroups[0].[GroupId,GroupName,Description,VpcId]" \
  --output table

echo ""
echo "👉 Règles ENTRANTES (Inbound)"
aws ec2 describe-security-groups \
  --group-ids $SG_ID \
  --query "SecurityGroups[0].IpPermissions[*].{Proto:IpProtocol,From:FromPort,To:ToPort,IPv4:IpRanges[*].CidrIp,IPv6:Ipv6Ranges[*].CidrIpv6,SGs:UserIdGroupPairs[*].GroupId}" \
  --output table

echo ""
echo "👉 Règles SORTANTES (Outbound)"
aws ec2 describe-security-groups \
  --group-ids $SG_ID \
  --query "SecurityGroups[0].IpPermissionsEgress[*].{Proto:IpProtocol,From:FromPort,To:ToPort,IPv4:IpRanges[*].CidrIp,IPv6:Ipv6Ranges[*].CidrIpv6,SGs:UserIdGroupPairs[*].GroupId}" \
  --output table

echo ""
echo "✅ Rapport terminé"
