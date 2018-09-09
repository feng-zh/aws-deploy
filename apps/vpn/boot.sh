#!/bin/sh

if [ ! -f /tmp/log.enabled ]; then
    apt-get update && apt-get -y install rsyslog
    service rsyslog restart
    sed -i '/modprobe/a service rsyslog restart' /opt/src/run.sh
    touch /tmp/log.enabled
    touch /var/log/auth.log
fi

tail -f /var/log/auth.log | grep --line-buffered pluto &
exec /opt/src/run.sh "$@"
