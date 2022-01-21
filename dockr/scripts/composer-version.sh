#!/bin/bash

GENERATED_COMPOSER_FILE_NAME="/usr/local/dockr/composer/composer_${DOCKR_COMPOSER_VERSION}"

if [ -f "${GENERATED_COMPOSER_FILE_NAME}" ]; then
    rm -rf /usr/bin/composer
    cp "${GENERATED_COMPOSER_FILE_NAME}" /usr/bin/composer

elif [ "${DOCKR_COMPOSER_VERSION}" == "1" ]; then
    rm -rf /usr/bin/composer
    cp /usr/local/dockr/composer/composer_1.8.6 /usr/bin/composer
fi
