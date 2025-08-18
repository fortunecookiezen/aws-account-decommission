#!/usr/bin/env bash
# This script sets a lifecycle configuration on all S3 buckets (except those containing "cloudtrail" in their names)
# to delete all objects after 1 day. Use with caution, as this will permanently delete objects after the specified period.
# Requires AWS CLI and jq to be installed and configured with appropriate permissions.
# Intended for use in a controlled environment where immediate deletion is acceptable.
# Ensure you have the necessary permissions to modify the bucket lifecycle configuration.
# Use with caution, as this will permanently delete objects.
# Usage: ./empty_all_s3_buckets.sh
# Use during account decommissioning or similar scenarios.
set -euf -o pipefail
for bucket in $(aws s3api list-buckets | jq -r '.Buckets[] | select (.Name | contains("cloudtrail") | not )' | jq -r '.Name'); do
  echo "Setting lifecycle configuration for bucket: $bucket";
  aws s3api put-bucket-lifecycle-configuration --bucket "$bucket" --lifecycle-configuration '{
    "Rules": [{
        "Expiration": {
          "Days": 1
        },
        "ID": "FullDelete",
        "Filter": {
          "Prefix": ""
        },
        "Status": "Enabled",
        "NoncurrentVersionExpiration": {
          "NoncurrentDays": 1
        },
        "AbortIncompleteMultipartUpload": {
          "DaysAfterInitiation": 1
        }
      },
      {
        "Expiration": {
          "ExpiredObjectDeleteMarker": true
        },
        "ID": "DeleteMarkers",
        "Filter": {
          "Prefix": ""
        },
        "Status": "Enabled"
      }
    ]
  }';
  echo "Lifecycle configuration for bucket '$bucket' has been set to delete objects after 1 day and delete markers."
done