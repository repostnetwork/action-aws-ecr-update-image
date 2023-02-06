#!/bin/bash

if [ -z "$LOGICAL_NAME" ]
then
      echo "The environment variable LOGICAL_NAME must be defined"
      exit 1
fi
: "${TAG:=latest}"
: "${REDEPLOY:=true}"

ECR_REPOSITORY=`aws ecr get-login --no-include-email --region us-east-1 | awk 'NF{ print $NF }' | sed -e 's/^http:\/\///g' -e 's/^https:\/\///g'`
ECR_URI=$ECR_REPOSITORY/$LOGICAL_NAME
eval $(aws ecr get-login --no-include-email --region us-east-1)

echo -e "Building Docker..."
docker build -t $LOGICAL_NAME:$TAG --build-arg ENV=$ENV --build-arg TYPE=$TYPE . || exit 1

echo -e "Creating CloudWatch Log Group..."
aws logs create-log-group --log-group-name ecs/$LOGICAL_NAME || true

echo -e "Creating ECR repository..."
aws ecr create-repository --repository-name $LOGICAL_NAME || true

echo -e "Tagging Image..."
docker tag $LOGICAL_NAME:$TAG $ECR_URI:$TAG

echo -e "Pushing to ECR..."
docker push $ECR_URI:$TAG

if [[ "$REDEPLOY" == "true" ]]
then
  aws ecs update-service --force-new-deployment --cluster repost --service $LOGICAL_NAME || true
fi
