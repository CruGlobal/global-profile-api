#!/bin/bash

# `/usr/local/bin/aws ecr get-login` &&
docker build -t cruglobal/$PROJECT_NAME:$GIT_COMMIT-$BUILD_NUMBER .
