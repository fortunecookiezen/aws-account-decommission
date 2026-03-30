#!/usr/bin/env bash

set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"

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
  echo "----------------------------------------"
  echo "Processing cluster: $CLUSTER"

  # Get instances in the cluster
  INSTANCES=$(aws rds describe-db-clusters \
    --region "$AWS_REGION" \
    --query "DBClusters[?DBClusterIdentifier=='$CLUSTER'].DBClusterMembers[].DBInstanceIdentifier" \
    --output text)

  # Delete instances first
  for INSTANCE in $INSTANCES; do
    echo "Deleting instance: $INSTANCE"

    aws rds delete-db-instance \
      --region "$AWS_REGION" \
      --db-instance-identifier "$INSTANCE" \
      --skip-final-snapshot \
      --delete-automated-backups >/dev/null 2>&1

    echo "  Instance delete initiated."
  done

  echo "Waiting for instances to be deleted..."
  for INSTANCE in $INSTANCES; do
    aws rds wait db-instance-deleted \
      --region "$AWS_REGION" \
      --db-instance-identifier "$INSTANCE" >/dev/null 2>&1
  done
  echo "Disabling deletion protection for cluster: $CLUSTER"

  aws rds modify-db-cluster \
    --region "$AWS_REGION" \
    --db-cluster-identifier "$CLUSTER" \
    --no-deletion-protection >/dev/null 2>&1

  echo "Deleting cluster: $CLUSTER"

  aws rds delete-db-cluster \
    --region "$AWS_REGION" \
    --db-cluster-identifier "$CLUSTER" \
    --skip-final-snapshot \
    --delete-automated-backups >/dev/null 2>&1

  echo "  Cluster delete initiated."
done

echo "----------------------------------------"
echo "All clusters deletion initiated."
echo "Deletion process completed."