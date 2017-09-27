#!/bin/bash

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

APPDIR=${APPDIR:-/application}

echo "ENTRYPOINT: checking /etc/envoy.json"
/usr/bin/python3 "$APPDIR/ambassador.py" config --check /etc/ambassador-config /etc/envoy.json

STATUS=$?

if [ $STATUS -eq 0 ]; then
    echo "ENTRYPOINT: starting diagd"
    /usr/bin/python3 "$APPDIR/diagd.py" /etc/ambassador-config &

    echo "ENTRYPOINT: starting Envoy"
    /usr/local/bin/envoy -c /etc/envoy.json

    STATUS=$?
fi

if [ $STATUS -eq 0 ]; then
    echo "ENTRYPOINT: claiming success, but exited \?\?\?\?"
else
    echo "ENTRYPOINT: exited with status $STATUS"
fi

echo "Here's the envoy.json we were trying to run with:"
cat /etc/envoy.json

sleep 5
echo "ENTRYPOINT: shutting down"

