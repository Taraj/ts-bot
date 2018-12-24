//
// Created by Krzysiek on 25.11.2018.
//

#ifndef TS3_BOT_EVENTS_H
#define TS3_BOT_EVENTS_H

#include <time.h>

#include "../../collections/collections.h"

#include "../../database/database.h"
#include "../../utilities.h"
#include "../../highLevelFunctions/highLevelFunctions.h"

#include "../../rankings/rankings.h"

void clientJoin(int mainSocket, struct tree *new);

void clientLeft(int mainSocket, struct tree *old);

void clientMove(int mainSocket, struct tree *old, struct tree *new);

void clientRecording(int mainSocket, struct tree *old, struct tree *new);

void clientStopBeAfk(int mainSocket, struct tree *old, struct tree *new);

void clientStartAfk(int mainSocket, struct tree *old, struct tree *new);

void clientServerGroupChange(int mainSocket, struct tree *old, struct tree *new);

void channelDelete(int mainSocket, struct tree *old);

void channelInactive(int mainSocket, struct tree *old, struct tree *new);

#endif //TS3_BOT_EVENTS_H
