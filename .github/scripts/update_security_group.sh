name: Create Directory on EC2 via AWS SSM

on:
  push:
    branches:
      - main  # Replace with your branch name
  workflow_dispatch:  # Allows manual triggering from GitHub UI

jobs:
  create-directory:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v2
        
      - name: Set up AWS CLI
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: your-aws-region
      
      - name: Run AWS SSM command to create directory
        run: |
          INSTANCE_ID="your-instance-id"  # Replace with your EC2 instance ID
          DIRECTORY_PATH="/home/rajat/test"
          
          aws ssm send-command \
            --instance-ids "$INSTANCE_ID" \
            --document-name "AWS-RunShellScript" \
            --parameters commands="mkdir -p $DIRECTORY_PATH" \
            --output text
      
      - name: Monitor command execution
        run: |
          # Check command execution status and output
          aws ssm list-command-invocations --details \
            --instance-id "$INSTANCE_ID" \
            --query "CommandInvocations[?Status=='Success'].{ID:CommandId, Status:Status, Output:CommandPlugins[].Output}" \
            --output json
