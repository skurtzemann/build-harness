#!/usr/bin/env bash
# ---
# Create docker tags to identified to built container according CI variables
# then push to 'DOCKER_REGISTRY_SERVER'.
# --- 

echo "CI_JOB_ID=${CI_JOB_ID}"

# General docker tags 
# - the full commit SHA
# - the short commit (8 characters)
DOCKER_TAGS=("$CI_COMMIT_SHA")
DOCKER_TAGS+=("${CI_COMMIT_SHA:0:8}")

# Branches tags
# - for a git tag we create the related docker tag
# - for others we create a docker tag for
#    - the branch
#    - the branch with the GitLab CI job id
if [ ! -z "${CI_COMMIT_TAG}" ]; then
  echo "CI_COMMIT_TAG=${CI_COMMIT_TAG}"
  DOCKER_TAGS+=("${CI_COMMIT_TAG}")
else
  DOCKER_TAGS+=("$CI_COMMIT_REF_NAME")
  DOCKER_TAGS+=("${CI_COMMIT_REF_NAME}-${CI_JOB_ID}")
fi

# For the master branch add the "latest" tag
if [ "${CI_COMMIT_REF_NAME}" == "master" ]; then
  DOCKER_TAGS+=("latest")
fi

# For each 'DOCKER_TAGS' item, tag and push an docker image based on the tag "ci-build" 
for TAG in "${DOCKER_TAGS[@]}"; do
  echo "Tagging ${DOCKER_REGISTRY_SERVER}/${DOCKER_IMAGE}:${TAG}"
  docker tag "${DOCKER_IMAGE}:ci-build" "${DOCKER_REGISTRY_SERVER}/${DOCKER_IMAGE}:${TAG}" && \
    docker push "${DOCKER_REGISTRY_SERVER}/${DOCKER_IMAGE}:${TAG}";
  if [ $? -ne 0 ]; then
    echo "Failed" 1>&2
    exit 1
  fi
done
