#!/bin/sh

if [ "$EXTRA_VARS" = http* ]; then
  apt-get update && apt-get install curl -y && apt-get clean -y
  curl -L -q $EXTRA_VARS > .extra_vars
else
  echo "$EXTRA_VARS" > .extra_vars
fi
