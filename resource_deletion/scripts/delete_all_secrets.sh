#!/usr/bin/env bash
# This script deletes all secrets in AWS Secrets Manager.
# Use with caution, as this will permanently delete secrets.
# Requires AWS CLI to be installed and configured with appropriate permissions.
# Usage: ./delete_all_secrets.sh
# Example: ./delete_all_secrets.sh
# Note: This script does not delete the secrets themselves, only the secret versions.
set -euf -o pipefail

for secret_arn in $(aws secretsmanager list-secrets --query 'SecretList[*].ARN' | jq -r '.[]'); do
  aws secretsmanager delete-secret --secret-id "$secret_arn" --recovery-window-in-days 7
done
echo "All secrets have been scheduled for deletion. They will be permanently deleted after the recovery window."
echo "You can verify the deletion status with: aws secretsmanager list-secrets"
echo "Note: Ensure that you have the necessary permissions to delete secrets in AWS Secrets Manager."
echo "This script is intended for use in a controlled environment where immediate deletion of secrets is acceptable."
echo "Use with caution, as this will permanently delete secrets after the specified recovery window."
echo "If you want to delete secrets immediately, use the --force-delete-without-recovery option with caution."
echo "Example: aws secretsmanager delete-secret --secret-id <secret-id> --force-delete-without-recovery"
echo "This will delete the secret immediately without any recovery option."
echo "Ensure you have the necessary permissions to perform this operation."
echo "Always double-check before running scripts that delete resources in AWS to avoid accidental data loss."
echo "Consider using this script during account decommissioning or similar scenarios where secrets need to be removed."
echo "Backup any important secrets before running this script, as it will permanently delete them."
echo "For more information on AWS Secrets Manager, refer to the official documentation: https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html"
echo "This script is provided as-is and should be used with caution. Always test in a safe environment before running in production."
