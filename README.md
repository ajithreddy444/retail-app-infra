
## What's the Point?

The purpose of this repository is to provide the necessary tools for a
single-command provisioning of a high-availability, Fargate-backed ECS cluster
to which you can deploy your application.

## What You'll Get

After successfully creating the Cloud Formation stack you'll have:

- a high-availability (multi-AZ) ECS cluster
- a load balancer routing requests to 2 instances (one in each AZ) of a Rails 5 application connected to an RDS Mariadb database
- zero-downtime deploys to ECS via AWS Code Pipeline
- automatic application of cluster-safe migrations
- centralized logging with CloudWatch
- lambda scripts to send SAST and DAST reports to AWS SecurityHub

## Prerequisites

1.	Git command line installed
2.	Awscli installed
3.	AWS account 
4.	S3 bucket with put object ,list object access.
5.	AWS cli configured by IAM user credentials with Administrator access


## Deploying to AWS + CI


First, pick an globally unique, *alphanumeric* name for your stack:

```
export CF_DEMO_ENVIRONMENT=staging
```

The following command will create the master stack (which defines a VPC, ALB, ECS cluster, etc.). Note: Your application will be built and pushed to this new ECR repository during the
stack creation process.

```sh
./infrastructure/cloud-formation/scripts/deploy.sh ${CF_DEMO_ENVIRONMENT} s3bucketname
```

an example invocation:

```sh
./infrastructure/cloud-formation/scripts/deploy.sh staging s3-nag-dev
```

Once your stack reaches the `CREATE_COMPLETE` state (it could take 30+ minutes),
interrogate the stack outputs to obtain the web service URL and Code Pipeline
URL.

```sh
export APP_URL=$(aws cloudformation \
   describe-stacks \
   --query 'Stacks[0].Outputs[?OutputKey==`WebServiceUrl`].OutputValue' \
   --stack-name ${CF_DEMO_ENVIRONMENT} | jq '.[0]' | sed -e "s;\";;g")
```

```sh
export CI_URL=$(aws cloudformation \
   describe-stacks \
   --query 'Stacks[0].Outputs[?OutputKey==`PipelineUrl`].OutputValue' \
   --stack-name ${CF_DEMO_ENVIRONMENT} | jq '.[0]' | sed -e "s;\";;g")
```

## How to Delete Stack

```sh
./infrastructure/cloud-formation/scripts/delete-stacks.sh ${CF_DEMO_ENVIRONMENT}
```
Note: you may have empty & delete s3 buckets ,ECR created from template before as CFN delete won't delete non-empty buckets and ecrs.
