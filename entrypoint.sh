#!/bin/sh
set -e

if [ "$1" = 'TS3_BOT' ]; then
    cat <<- EOF >/TS3_BOT/config.h
            #ifndef TS3_BOT_CONFIG_H
            #define TS3_BOT_CONFIG_H


            #define SERVER_ADDRESS "${SERVER_ADDRESS}"
            #define SERVER_PORT ${SERVER_PORT} 

            #define DATABASE_ADDRESS "${DATABASE_ADDRESS}"
            #define DATABASE_USER "${DATABASE_USER}"
            #define DATABASE_PASSWORD "${DATABASE_PASSWORD}"
            #define DATABASE "${DATABASE}"


            #define TS3_SERVER_ADMIN_LOGIN "${TS3_SERVER_ADMIN_LOGIN}"
            #define TS3_SERVER_ADMIN_PASSWORD "${TS3_SERVER_ADMIN_PASSWORD}"
            #define TS3_SERVER_ID ${TS3_SERVER_ID}

            #define TS3_BOT_REFRESH_TIME ${TS3_BOT_REFRESH_TIME}
            #define TS3_BOT_DATA_PACKAGE_SIZE ${TS3_BOT_DATA_PACKAGE_SIZE}
            #define TS3_BOT_NAME "${TS3_BOT_NAME}"


            #define TS3_ALLOW_RECORDING_GROUP "${TS3_ALLOW_RECORDING_GROUP}"


            #define TS3_MIN_AFK_TIME ${TS3_MIN_AFK_TIME}
            #define TS3_AFK_GROUP "${TS3_AFK_GROUP}"


            #define TS3_HELPER_IGNORE_GROUP "${TS3_HELPER_IGNORE_GROUP}"
            #define TS3_HELPER_GROUP "${TS3_HELPER_GROUP}"
            #define TS3_HELPER_CHANNEL "${TS3_HELPER_CHANNEL}"


            #define TS3_CREATE_CHANNEL_GROUP "${TS3_CREATE_CHANNEL_GROUP}"
            #define TS3_CHANNEL_ADMIN_GROUP "${TS3_CHANNEL_ADMIN_GROUP}"
            #define TS3_CHANNEL_DEFAULT_PASSWORD "${TS3_CHANNEL_DEFAULT_PASSWORD}"


            #define TS3_RANKING_CONNECTION_TIME_CHANNEL_ID "${TS3_RANKING_CONNECTION_TIME_CHANNEL_ID}"
            #define TS3_RANKING_CONNECTION_COUNT_CHANNEL_ID "${TS3_RANKING_CONNECTION_COUNT_CHANNEL_ID}"
            #define TS3_RANKING_LONGEST_CONNECTION_CHANNEL_ID "${TS3_RANKING_LONGEST_CONNECTION_CHANNEL_ID}"

            #endif //TS3_BOT_CONFIG_H
	EOF
    make
fi

exec "$@"