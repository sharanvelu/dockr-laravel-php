#!/bin/bash

if [ "${DOCKR_CONTAINER_TYPE}" == "worker" ]; then
    cp /etc/supervisor/disabled/supervisor-worker.conf /etc/supervisor/conf.d/supervisor-worker.conf
else
    cp "/etc/supervisor/disabled/supervisor-${DOCKR_SERVER_TYPE}.conf" "/etc/supervisor/conf.d/supervisor-${DOCKR_SERVER_TYPE}.conf"
fi
