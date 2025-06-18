#!/bin/bash
set -e

echo Adding an SSH key for $GIT_USERNAME ...
PUB_KEY=$(sudo cat /home/ec2-user/.ssh/id_rsa.pub)
TITLE="$(hostname)$(date +%s)"
USER_ID=$(curl -sS "$GITLAB_URL/api/v4/users?search=$GIT_USERNAME" -H "PRIVATE-TOKEN: $IDE_PASSWORD" | jq '.[0].id')
curl -sS -X 'POST' "$GITLAB_URL/api/v4/users/$USER_ID/keys" \
  -H "PRIVATE-TOKEN: root-$IDE_PASSWORD" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d "{
  \"key\": \"$PUB_KEY\",
  \"title\": \"$TITLE\"
}" && echo -e "\n"

ssh-keyscan -H $NLB_DNS >> ~/.ssh/known_hosts

echo "GitLab url: $GITLAB_URL"
echo "GitLab username: $GIT_USERNAME"
echo "GitLab password: $IDE_PASSWORD"
