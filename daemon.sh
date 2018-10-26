#!/bin/bash

set -e

INTERVAL_SEC=${1:-30}

while true; do
    /opt/reconfigure.sh
    sleep ${INTERVAL_SEC:?}
done
