#!/bin/bash

GEN_SALT=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c 8)

if [ -n "$1" ]; then
  GEN_PASSWD=$1
else
  GEN_PASSWD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9@!% | head -c 12)
  echo "Password: $GEN_PASSWD" 1>&2
fi

perl -e 'print crypt("'${GEN_PASSWD}'","\$6\$'${GEN_SALT}'\$") . "\n"'
