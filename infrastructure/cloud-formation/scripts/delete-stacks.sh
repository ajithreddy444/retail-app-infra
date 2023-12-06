#!/bin/bash
set -ex

ENV_NAME_ARG=$1

MAIN_STACK_NAME=${ENV_NAME_ARG}
AWS_REGION=$2

# List all repositories
aws ecr describe-repositories --region $AWS_REGION --output json | \
  jq -r '.repositories[] | .repositoryName' | \
  xargs -I {} aws ecr delete-repository --repository-name {} --region $AWS_REGION --force

for bucket in $(aws s3api list-buckets --region $AWS_REGION --query 'Buckets[*].Name' --output json | jq -r '.[]'); do
  echo "Emptying and deleting S3 bucket: $bucket"
  
  # Empty the S3 bucket
  aws s3 rm s3://$bucket --recursive --region $AWS_REGION

  # Delete the empty S3 bucket
  aws s3api delete-bucket --bucket $bucket --region $AWS_REGION
done

if aws cloudformation describe-stacks --stack-name ${MAIN_STACK_NAME}; then
    aws cloudformation delete-stack --stack-name ${MAIN_STACK_NAME} || true
    aws cloudformation wait stack-delete-complete --stack-name ${MAIN_STACK_NAME}
fi

echo "$(date):create:${ENV_NAME_ARG}:success"
