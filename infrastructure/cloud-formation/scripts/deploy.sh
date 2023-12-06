#!/bin/bash
set -ex

ENV_NAME_ARG=$1
bucketname=$2

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
        S3TemplateKeyPrefix=https://s3.amazonaws.com/${bucketname}/infrastructure/cloud-formation/templates/ \
        LambdaPackageLoc=${bucketname}

echo "$(date):create:${ENV_NAME_ARG}:success"
