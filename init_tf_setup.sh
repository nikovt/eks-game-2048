#!/bin/bash

set -eu

if [ $# -lt 2 ]; then
    echo "Required parameters are missing."
    echo "init_tf_setup.sh <unique-s3-bucket-name> <dynamo-db-lock-table-name>"
    exit 1
else 
    BUCKET_NAME=$1
    LOCK_TABLE_NAME=$2
fi

# Create an s3 bucket for Terraform state and set default encryption and versioning
if aws s3api head-bucket --bucket $BUCKET_NAME 2>/dev/null
then
	echo "S3 bucket $BUCKET_NAME already exists."
else
    aws s3api create-bucket --bucket $BUCKET_NAME --region "eu-west-2" --create-bucket-configuration LocationConstraint="eu-west-2"

    echo "Waiting for bucket to be created..."
    aws s3api wait bucket-exists --bucket $BUCKET_NAME

    aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled
    aws s3api put-public-access-block --bucket $BUCKET_NAME --public-access-block-configuration \
        BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
     aws s3api put-bucket-encryption \
        --bucket $BUCKET_NAME \
        --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
fi

if aws dynamodb describe-table --table-name $LOCK_TABLE_NAME 2>/dev/null
then
    echo "$LOCK_TABLE_NAME dynamodb table exists. Nothing to do."
else
    aws dynamodb create-table \
        --table-name $LOCK_TABLE_NAME \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --billing-mode PAY_PER_REQUEST 
    echo "Waiting for lock table to be created..."
    aws dynamodb wait table-exists --table-name $LOCK_TABLE_NAME
fi

cat ./providers.tf.tmpl | \
        sed "s~##S3_BUCKET_NAME##~$BUCKET_NAME~; \
        s~##DYNAMODB_LOCK_TABLE##~$LOCK_TABLE_NAME~; " > ./providers.tf

echo "Done"