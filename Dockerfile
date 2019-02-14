FROM repostnetwork/deploy-utils:latest

LABEL "com.github.actions.name"="AWS ECR Update Image"
LABEL "com.github.actions.description"="Push a Docker Image to ECR for the URL for this Repo"
LABEL "com.github.actions.icon"="cloud"
LABEL "com.github.actions.color"="red"

WORKDIR /usr/src

COPY update-image.sh /update-image.sh
RUN chmod +x /update-image.sh
ENTRYPOINT [ "/update-image.sh" ]