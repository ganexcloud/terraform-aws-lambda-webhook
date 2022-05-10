function handler () {
  set -e
  EVENT_DATA=$1
  # Variables
  AWS_REGION="us-east-1"
  AWS_SSM_PARAMETER_NAME="ssh-key"
  GIT_REPO="git@gitlab.com:xxxx/xxxxx.git"
  GIT_BRANCH=$(echo ${EVENT_DATA} | jq -r ".push.changes[0].new.name")
  GIT_AUTHOR=$(echo ${EVENT_DATA} | jq -r ".push.changes[0].new.target.author.user.display_name")
  GIT_COMMIT=$(echo ${EVENT_DATA} | jq -r ".push.changes[0].new.target.summary.raw")
  S3_PATH="source.zip"
  if [[ ${GIT_BRANCH} == "master" ]]; then
    S3_BUCKET="frontend-production"
  elif [[ ${GIT_BRANCH} == "homolog" ]]; then
    S3_BUCKET="frontend-staging"
  else
    echo "Branch ${GIT_BRANCH} not found"
    exit 1
  fi
  DIR="$(mktemp -d)"
  echo "Build started by ${GIT_AUTHOR} on ${GIT_BRANCH}. Commit Message: ${GIT_COMMIT}" 2>&1
  # SSH Config
  mkdir -p /tmp/.ssh
  aws --region ${AWS_REGION} ssm get-parameter --name ${AWS_SSM_PARAMETER_NAME} --with-decryption --output text --query "Parameter.Value" >> ~/.ssh/id_rsa
  export GIT_SSH="/tmp"
  export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/tmp/.ssh/known_hosts -i /tmp/.ssh/id_rsa 2>/dev/null"
  chmod 600 /tmp/.ssh/id_rsa
  eval `ssh-agent -s`
  ssh-add /tmp/.ssh/id_rsa 2>/dev/null
  ssh-keyscan bitbucket.org >> /tmp/.ssh/known_hosts 2>/dev/null
  ssh-keyscan gitlab.com >> /tmp/.ssh/known_hosts 2>/dev/null
  ## Git
  cd ${DIR}
  git clone --single-branch --depth=1 --branch ${GIT_BRANCH} ${GIT_REPO} . 2>/dev/null
  echo "Successfully cloned repository" 2>&1
  # Zip
  zip -qq -r source.zip .
  echo "Successfully zip" 2>&1
  # S3
  aws s3 cp source.zip s3://${S3_BUCKET}/${S3_PATH}
  echo "Successfully copied to S3" 2>&1
  echo "{\"success\": true}" 2>&1
}
