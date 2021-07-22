#!/bin/bash

set -eu

if [ $# -lt 2 ]; then
    echo "Required parameters are missing."
    echo "clean_up.sh <unique-s3-bucket-name> <dynamo-db-lock-table-name>"
    exit 1
else 
    BUCKET_NAME=$1
    LOCK_TABLE_NAME=$2
fi

# Create an s3 bucket for Terraform state and set default encryption and versioning
if aws s3api head-bucket --bucket $BUCKET_NAME 2>/dev/null
then
    ./delete_all_object_versions.sh $BUCKET_NAME
    aws s3 rm s3://$BUCKET_NAME --recursive
	aws s3 rb s3://$BUCKET_NAME --force
else
    echo "S3 bucket $BUCKET_NAME doesn't exists. Nothing to do."
fi

if aws dynamodb describe-table --table-name $LOCK_TABLE_NAME 2>/dev/null
then
    aws dynamodb delete-table --table-name $LOCK_TABLE_NAME
else
    echo "$LOCK_TABLE_NAME dynamodb table doesn't exists. Nothing to do."
fi

echo "Done"