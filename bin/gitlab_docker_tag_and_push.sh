#!/usr/bin/env bash

DOCKER_TAGS=("$CI_COMMIT_SHA")
DOCKER_TAGS+=("${CI_COMMIT_REF_NAME}-${CI_COMMIT_SHA:0:8}")

echo "CI_JOB_ID=${CI_JOB_ID}"

if [ ! -z "${CI_COMMIT_TAG}" ]; then
  echo "CI_COMMIT_TAG=${CI_COMMIT_TAG}"
  DOCKER_TAGS+=("${CI_COMMIT_TAG}")
fi

for TAG in "${DOCKER_TAGS[@]}"; do
  echo "Tagging ${DOCKER_REGISTRY_SERVER}/${DOCKER_IMAGE_NAME}:${TAG}"
  docker tag "${DOCKER_IMAGE_NAME}:ci-build" "${DOCKER_REGISTRY_SERVER}/${DOCKER_IMAGE_NAME}:${TAG}" && \
    docker push "${DOCKER_REGISTRY_SERVER}/${DOCKER_IMAGE_NAME}:${TAG}";
  if [ $? -ne 0 ]; then
    echo "Failed" 1>&2
    exit 1
  fi
done
