#!/bin/bash

/usr/local/dockr/scripts/worker-definition.sh
/usr/local/dockr/scripts/composer-version.sh

exec "$@"
