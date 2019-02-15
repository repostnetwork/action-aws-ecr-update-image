#!/bin/bash

LOGICAL_NAME=${GITHUB_REPOSITORY/repostnetwork\//}

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')
ECR_REPOSITORY=`aws ecr get-login --no-include-email --region us-east-1 | awk 'NF{ print $NF }'`
ECR_URI=$ECR_REPOSITORY/$LOGICAL_NAME
eval $(aws ecr get-login --no-include-email --region us-east-1)

echo $LOGICAL_NAME
echo $ECR_REPOSITORY
echo $ECR_URI

# Configure ECR
echo -e "\n\nCreating ECR repository..."
aws ecr create-repository --repository-name $LOGICAL_NAME || true

# Building Docker
echo -e "\n\nBuilding docker..."
docker build -t $LOGICAL_NAME --build-arg ENV=$ENV .

# Tag Image
docker tag $LOGICAL_NAME:latest $ECR_URI:latest

echo -e "\n\Pushing to ECR..."
docker push $ECR_URI:latest

# Force a new deployment for the service
aws ecs update-service --force-new-deployment --cluster repost --service $LOGICAL_NAME
