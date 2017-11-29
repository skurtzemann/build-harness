#!/usr/bin/env bash

echo "CI_JOB_ID=${CI_JOB_ID}"

# We create several docker tags to identified to build container
# - the full commit SHA
# - the branch or tag
# - the branch or tag with the 'short' commit SHA (8 characters)
# - the branch or tag with the GitLab CI job id 
DOCKER_TAGS=("$CI_COMMIT_SHA")
DOCKER_TAGS+=("$CI_COMMIT_REF_NAME")
DOCKER_TAGS+=("${CI_COMMIT_REF_NAME}-${CI_COMMIT_SHA:0:8}")
DOCKER_TAGS+=("${CI_COMMIT_REF_NAME}-${CI_JOB_ID}")

# For a git tag create an additionnal docker tag
if [ ! -z "${CI_COMMIT_TAG}" ]; then
  echo "CI_COMMIT_TAG=${CI_COMMIT_TAG}"
  DOCKER_TAGS+=("${CI_COMMIT_TAG}")
fi

# For the master branch add the "latest" tag
if [ "${CI_COMMIT_REF_NAME}" == "master" ]; then
  DOCKER_TAGS+=("latest")
fi

# For each 'DOCKER_TAGS' item tag and push an docker image based on the tag "ci-build" 
for TAG in "${DOCKER_TAGS[@]}"; do
  echo "Tagging ${DOCKER_REGISTRY_SERVER}/${DOCKER_IMAGE}:${TAG}"
  docker tag "${DOCKER_IMAGE}:ci-build" "${DOCKER_REGISTRY_SERVER}/${DOCKER_IMAGE}:${TAG}" && \
    docker push "${DOCKER_REGISTRY_SERVER}/${DOCKER_IMAGE}:${TAG}";
  if [ $? -ne 0 ]; then
    echo "Failed" 1>&2
    exit 1
  fi
done
