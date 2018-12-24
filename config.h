//
// Created by Krzysiek on 20.11.2018.
//

#ifndef TS3_BOT_CONFIG_H
#define TS3_BOT_CONFIG_H


#define SERVER_IP "192.168.56.1"
#define SERVER_PORT 10011

#define DATABASE_IP "localhost"
#define DATABASE_USER "root"
#define DATABASE_PASSWORD "123"
#define DATABASE "teamSpeak3"


#define TS3_SERVER_ADMIN_LOGIN "serveradmin"
#define TS3_SERVER_ADMIN_PASSWORD "dm+krF9Q"
#define TS3_SERVER_ID 1

#define TS3_BOT_REFRESH_TIME 1 //sek
#define TS3_BOT_TRIES_BEFORE_EXIT 20
#define TS3_BOT_DATA_PACKAGE_SIZE 1024


#define TS3_BOT_NAME "bot\\stestowy"

#define TS3_BOT_MIN_AFK_TIME 5000 // sekundy * 1000
#define TS3_BOT_MIN_CHANNEL_INACTIVE_TIME 10

#define TS3_BOT_ALLOW_RECORDING_GROUP "21"
#define TS3_BOT_AFK_GROUP "20"
#define TS3_CREATE_CHANNEL_GROUP "23"
#define TS3_HELPER_GROUP "27"
#define TS3_HELPER_CHANNEL "4"

#define TS3_CHANNEL_ADMIN_GROUP "5"


#define TS3_RANKING_TIME "1"
#define TS3_RANKING_COUNT "2"
#endif //TS3_BOT_CONFIG_H
