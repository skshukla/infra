#!/usr/bin/env bash

BRANCH=$(git rev-parse --abbrev-ref HEAD)
git reset --hard origin/${BRANCH}
git checkout dev
git reset --hard origin/dev
git pull