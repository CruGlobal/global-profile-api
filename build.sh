#!/bin/bash

docker build \
    --build-arg SECRET_KEY_BASE=$SECRET_KEY_BASE \
    -t 056154071827.dkr.ecr.us-east-1.amazonaws.com/$PROJECT_NAME:$ENVIRONMENT-$BUILD_NUMBER .
