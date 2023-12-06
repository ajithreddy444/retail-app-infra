#!/bin/bash
set -ex

ENV_NAME_ARG=$1
bucketname=$2

###############################################################################
# Create an S3 stack which holds our CloudFormation templates and an ECR stack
# which will hold our application's Docker images
#

BUCKET_STACK_NAME=${ENV_NAME_ARG}-template-storage

if ! aws cloudformation describe-stacks --stack-name ${BUCKET_STACK_NAME}; then
  aws cloudformation deploy \
      --stack-name ${BUCKET_STACK_NAME} \
      --template-file ./infrastructure/cloud-formation/templates/template-storage.yml \
      --parameter-overrides BucketName=${bucketname}
fi


###############################################################################
# Ensure that S3 has the most recent revision of our CloudFormation templates
#

aws s3 sync \
    --acl public-read \
    --delete \
    . s3://${bucketname}/


###############################################################################
# Create the stack
#

aws cloudformation deploy \
    --stack-name ${ENV_NAME_ARG} \
    --capabilities CAPABILITY_NAMED_IAM CAPABILITY_IAM \
    --template-file ./infrastructure/cloud-formation/templates/master.yml \
    --parameter-overrides \
        S3TemplateKeyPrefix=https://s3.amazonaws.com/${ENV_NAME_ARG}/infrastructure/cloud-formation/templates/ \
        LambdaPackageLoc=${bucketname}

echo "$(date):create:${ENV_NAME_ARG}:success"
