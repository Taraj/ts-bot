# Team Speak - BOT
Simple ts BOT used on my server. 
I chose **C** because my VPS is not the most powerful and i need some performance.
# Features
* add clients to AFK group.
* kick clients while recording(if they haven't special group).
* create private channel via group.
* poke helpers if someone join to help channel.
* welcome message.
* rankings:
  * connections count
  * connections time
* store informations about users in database
# OS
* Debian 9 - *Only here i tested xD*
# Docker
https://hub.docker.com/r/taraj2/ts-bot

Examle `docker-compose.yml`(only part)

```
ts-bot:
    image: taraj2/ts-bot
    container_name: ts-bot
    networks:
      - ts
    restart: on-failure
    depends_on: 
      - teamspeak
    environment:
      SERVER_ADDRESS: teamspeak
      SERVER_PORT: 10011
      DATABASE_ADDRESS: mysql
      DATABASE_USER: TeamSpeakBot
      DATABASE_PASSWORD: 1235
      DATABASE: TeamSpeakBotData
      TS3_SERVER_ADMIN_LOGIN: serveradmin
      TS3_SERVER_ADMIN_PASSWORD: 123
      TS3_SERVER_ID: 1
      TS3_BOT_REFRESH_TIME: 1
      TS3_BOT_DATA_PACKAGE_SIZE: 1024
      TS3_BOT_NAME: Mocno\\sTestowo
      TS3_ALLOW_RECORDING_GROUP: 1
      TS3_MIN_AFK_TIME: 1
      TS3_AFK_GROUP: 1
      TS3_HELPER_IGNORE_GROUP: 1
      TS3_HELPER_GROUP: 1
      TS3_HELPER_CHANNEL: 10
      TS3_CREATE_CHANNEL_GROUP: 1
      TS3_CHANNEL_ADMIN_GROUP: 5
      TS3_CHANNEL_DEFAULT_PASSWORD: 123
      TS3_RANKING_CONNECTION_TIME_CHANNEL_ID: 1
      TS3_RANKING_CONNECTION_COUNT_CHANNEL_ID: 2
      TS3_RANKING_LONGEST_CONNECTION_CHANNEL_ID: 4
```