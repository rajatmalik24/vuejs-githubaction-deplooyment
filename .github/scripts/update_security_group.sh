#!/bin/bash

# Define variables
SECURITY_GROUP_ID="sg-0fce1b8d8e4ee7141"
PORT="22"  # e.g., 22 for SSH, 80 for HTTP

# Fetch the latest GitHub Actions IP addresses
IPS=$(curl -s https://api.github.com/meta | jq -r '.actions[]')

# Revoke old rules (optional but recommended to avoid duplicate rules)
OLD_IPS=$(aws ec2 describe-security-groups --group-id $SECURITY_GROUP_ID --query "SecurityGroups[0].IpPermissions[?FromPort==\`$PORT\`].IpRanges[*].CidrIp" --output text)
for OLD_IP in $OLD_IPS; do
  aws ec2 revoke-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port $PORT --cidr $OLD_IP
done

# Add new rules
for IP in $IPS; do
  aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port $PORT --cidr $IP
done
