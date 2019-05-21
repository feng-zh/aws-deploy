#!/bin/sh

cd /etc/v2ray

sed "s/env:V2RAY_CLIENT_ID/${V2RAY_CLIENT_ID}/g" config.json.template > config.json

exec v2ray -config=/etc/v2ray/config.json
