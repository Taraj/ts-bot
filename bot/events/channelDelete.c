//
// Created by Krzysiek on 25.11.2018.
//
#include "events.h"

void channelDelete(int mainSocket, struct tree *old) {
    char query[1024];
    sprintf(query, "DELETE FROM `channels` WHERE `TS_cid` = %s;", treeGetValue(old, "cid"));
    listFree(execQuery(query));
}
