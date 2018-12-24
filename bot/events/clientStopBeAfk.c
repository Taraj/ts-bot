//
// Created by Krzysiek on 25.11.2018.
//

#include "events.h"

void clientStopBeAfk(int mainSocket, struct tree *old, struct tree *new) {
    if (strcmp(treeGetValue(new, "client_type"), "0") == 0) {
        serverGroupDeleteClient(mainSocket, new, TS3_BOT_AFK_GROUP);
        char query[1024];
        sprintf(query, "CALL `client_stop_inactivity`('%s', '%lld');", treeGetValue(old, "clid"),
                (strtoll(treeGetValue(old, "client_idle_time"), NULL, 0) - TS3_BOT_MIN_AFK_TIME) / 1000);
        listFree(execQuery(query));
    }
}