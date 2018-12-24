//
// Created by Krzysiek on 25.11.2018.
//

#include "events.h"

void clientLeft(int mainSocket, struct tree *old) {
    char query[1024];
    long long int idleTime = strtoll(treeGetValue(old, "client_idle_time"), NULL, 0) - TS3_BOT_MIN_AFK_TIME;
    if (idleTime < 0) {
        idleTime = 0;
    }
    sprintf(query, "CALL `client_leave`('%s', '%lld');", treeGetValue(old, "clid"), idleTime / 1000);
    listFree(execQuery(query));
    updateRankingConnectionTimes(mainSocket, TS3_RANKING_TIME);
    updateRankingConnectionCount(mainSocket, TS3_RANKING_COUNT);
}
