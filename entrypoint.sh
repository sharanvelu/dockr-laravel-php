#!/bin/bash

for SCRIPT in /usr/local/dockr/scripts/*.sh; do
    chmod +x ${SCRIPT}
    ${SCRIPT}
done

exec "$@"
