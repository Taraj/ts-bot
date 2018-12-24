cmake_minimum_required(VERSION 3.12)
project(TS3_BOT C)

set(CMAKE_CXX_FLAGS "-Wall -pedantic -g")

set(CMAKE_C_STANDARD 11)
add_executable(TS3_BOT main.c config.h database/database.h
        database/database.c
        bot/events/clientMove.c
        bot/events/clientRecording.c
        bot/events/clientJoin.c
        bot/events/clientLeft.c
        bot/events/events.h
        bot/events/clientStopBeAfk.c
        bot/events/clientStartAfk.c
        bot/events/clientServerGroupChange.c
        bot/events/channelDelete.c
        bot/events/channelInactive.c
        highLevelFunctions/highLevelFunctions.c
        highLevelFunctions/highLevelFunctions.h
        collections/collections.h
        collections/list.c
        collections/tree.c
        communication/communication.h
        communication/communication.c
        bot/compare.c bot/compare.h utilities.h utilities.c communication/network/network.c communication/network/network.h "rankings/rankings.h" "rankings/rankings.c")
target_link_libraries(TS3_BOT mysqlclient)

include_directories(/usr/include/mysql/)
link_directories(/usr/include/mysql/)
