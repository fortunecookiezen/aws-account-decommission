#!/usr/bin/env bash
# This script deletes all IAM access keys in an account.
# Use with caution, as this will permanently delete all aws access keys.
# Requires AWS CLI to be installed and configured with appropriate permissions.
# Usage: ./delete_all_access_keys.sh
# Example: ./delete_all_access_keys.sh
set -euf -o pipefail

for user in $(aws iam list-users --query 'Users[*].UserName' --output text); do
  for key in $(aws iam list-access-keys --user-name $user --query 'AccessKeyMetadata[*].AccessKeyId' --output text); do
    echo "Deleting key $key for user $user"
    aws iam delete-access-key --user-name $user --access-key-id $key
  done
done
echo "All access keys have been deleted."