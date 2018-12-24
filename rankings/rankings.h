//
// Created by Krzysiek on 23.12.2018.
//

#ifndef TS3_BOT_RANKINGS_H
#define TS3_BOT_RANKINGS_H

#include <stdlib.h>
#include "stdio.h"
#include "../collections/collections.h"
#include "../database/database.h"
#include "../highLevelFunctions/highLevelFunctions.h"

/**
 *
 * @param mainSocket - socket descriptor
 * @param cid - channel id
 */
void updateRankingConnectionTimes(int mainSocket, char *cid);

/**
 *
 * @param mainSocket - socket descriptor
 * @param cid - channel id
 */
void updateRankingConnectionCount(int mainSocket, char *cid);

#endif //TS3_BOT_RANKINGS_H
