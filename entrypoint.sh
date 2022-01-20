#!/bin/bash

/usr/local/dockr/scripts/supervisor-definition.sh
/usr/local/dockr/scripts/composer-version.sh

exec "$@"
