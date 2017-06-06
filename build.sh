#!/bin/bash

docker build \
    -t 056154071827.dkr.ecr.us-east-1.amazonaws.com/$PROJECT_NAME:$GIT_COMMIT-$BUILD_NUMBER .
