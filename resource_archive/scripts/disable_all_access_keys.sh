#!/usr/bin/env bash
# This script disables all IAM access keys in an account.
# Use with caution, as this will permanently disable all aws access keys.
# Requires AWS CLI to be installed and configured with appropriate permissions.
# Usage: ./disable_all_access_keys.sh
# Example: ./disable_all_access_keys.sh
set -euf -o pipefail

for user in $(aws iam list-users --query 'Users[*].UserName' --output text); do
  for key in $(aws iam list-access-keys --user-name $user --query 'AccessKeyMetadata[*].AccessKeyId' --output text); do
    echo "Disabling key $key for user $user"
    aws iam update-access-key --user-name $user --access-key-id $key --status Inactive
  done
done
echo "All access keys have been disabled."