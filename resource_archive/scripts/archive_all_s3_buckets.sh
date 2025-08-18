#!/usr/bin/env bash
# This script sets a lifecycle configuration on all S3 buckets to immediately transition all objects to Glacier storage class.
# Requires AWS CLI and jq to be installed and configured with appropriate permissions.
# Ensure you have the necessary permissions to modify the bucket lifecycle configuration.
# This is useful for archiving data that is infrequently accessed but needs to be retained for long periods, such as for compliance reasons or for account closure.
set -euf -o pipefail
for bucket in $(aws s3api list-buckets | jq -r '.Buckets[].Name'); do
  echo "Setting lifecycle configuration for bucket: $bucket";
  aws s3api put-bucket-lifecycle-configuration --bucket "$bucket" --lifecycle-configuration '{
  "Rules": [
    {
      "ID": "ImmediatelyTransitionToGlacier",
      "Prefix": "", 
      "Status": "Enabled",
      "Transitions": [
        {
          "Days": 0,
          "StorageClass": "GLACIER"
        }
      ]
    }
  ]
}';
  echo "Lifecycle configuration for bucket '$bucket' has been set to immediately transition objects to Glacier storage class."
done