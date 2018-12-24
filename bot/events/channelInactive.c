//
// Created by Krzysiek on 25.11.2018.
//
#include "events.h"

void channelInactive(int mainSocket, struct tree *old, struct tree *new) {
    char query[1024];
    sprintf(query, "SELECT `can_delete` FROM `channels` WHERE `TS_cid` = %s;", treeGetValue(new, "cid"));
    struct list *response = execQuery(query);

    if (response != NULL) {
        deleteChannel(mainSocket, treeGetValue(new, "cid"));
    }

    listFree(response);
}
