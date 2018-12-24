//
// Created by Krzysiek on 25.11.2018.
//
#include "events.h"

void clientStartAfk(int mainSocket, struct tree *old, struct tree *new) {
    if(strcmp(treeGetValue(new, "client_type"), "0") == 0){
        serverGroupAddClient(mainSocket, new, TS3_AFK_GROUP);
    }
}
