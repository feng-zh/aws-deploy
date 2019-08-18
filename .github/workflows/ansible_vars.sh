#!/bin/bash

if [[ "$EXTRA_VARS" = http* ]]; then
  curl -Lqs "$EXTRA_VARS" > .extra_vars
else
  echo "$EXTRA_VARS" > .extra_vars
fi
