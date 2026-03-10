#!/bin/bash

ENV=$1

# 1. Validation
if [[ ! "$ENV" =~ ^(dev|qa|test|uat|prod)$ ]]; then
    echo "❌ Error: Use dev, qa, test, uat, or prod"
    exit 1
fi

# 2. Paths
ROOT_DIR=$(pwd)
CONF_FILE="$ROOT_DIR/backend/$ENV.conf"
TERRAFORM_DIR="$ROOT_DIR/infra/terraform/env/core"

echo "🚀 Switching to $ENV environment..."

# 3. Execution
cd "$TERRAFORM_DIR" || exit
terraform init -backend-config="$CONF_FILE" -reconfigure

if [ $? -eq 0 ]; then
    echo "✅ Success! Backend is now set to $ENV"
else
    echo "❌ Error: Terraform init failed."
    exit 1
fi
