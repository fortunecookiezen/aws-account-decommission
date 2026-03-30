#!/usr/bin/env bash

set -euo pipefail

# -------- CONFIGURATION --------
AWS_REGION="${AWS_REGION:-us-east-1}"

# Tags to apply to each snapshot
TAGS=(
  "Key=apm_id,Value=apm0007020"
  "Key=environment,Value=prod"
)
# --------------------------------

echo "Using region: $AWS_REGION"
echo "Discovering RDS DB clusters..."

CLUSTERS=$(aws rds describe-db-clusters \
  --region "$AWS_REGION" \
  --query 'DBClusters[].DBClusterIdentifier' \
  --output text)

if [[ -z "$CLUSTERS" ]]; then
  echo "No RDS DB clusters found."
  exit 0
fi

for CLUSTER in $CLUSTERS; do
  SNAPSHOT_NAME="final-${CLUSTER}-$(date +%Y%m%d%H%M%S)"

  echo "Processing cluster: $CLUSTER"
  echo "Snapshot name: $SNAPSHOT_NAME"

  # Check if snapshot already exists
  if aws rds describe-db-cluster-snapshots \
      --region "$AWS_REGION" \
      --db-cluster-snapshot-identifier "$SNAPSHOT_NAME" \
      >/dev/null 2>&1; then
    echo "  Snapshot already exists — skipping."
    continue
  fi

  # Create snapshot with tags
  aws rds create-db-cluster-snapshot \
    --region "$AWS_REGION" \
    --db-cluster-identifier "$CLUSTER" \
    --db-cluster-snapshot-identifier "$SNAPSHOT_NAME" \
    --tags "${TAGS[@]}" >/dev/null 2>&1

  echo "  Snapshot creation started."
done

echo "All clusters processed."
echo "Snapshot process completed."