#!/bin/bash

if [ "${DOCKR_CONTAINER_TYPE}" == "worker" ]; then
    cp /usr/local/dockr/supervisor/supervisor-worker.conf /etc/supervisor/conf.d/supervisor-worker.conf
else
    cp /usr/local/dockr/supervisor/supervisor-apache.conf /etc/supervisor/conf.d/supervisor-apache.conf
fi
