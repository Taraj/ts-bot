//
// Created by Krzysiek on 04.12.2018.
//

#include "compare.h"

void compareClientList(int mainSocket, struct list *old, struct list *new) {
    int exist;
    for (struct list *ItOld = old; ItOld != NULL; ItOld = ItOld->next) {
        exist = 0;
        for (struct list *ItNew = new; ItNew != NULL; ItNew = ItNew->next) {
            if (strcmp(treeGetValue(ItNew->tree, "clid"), treeGetValue(ItOld->tree, "clid")) == 0) {
                exist = 1;
                break;
            }
        }
        if (!exist) {
            clientLeft(mainSocket, ItOld->tree);
        }
    }

    for (struct list *ItNew = new; ItNew != NULL; ItNew = ItNew->next) {
        exist = 0;
        for (struct list *ItOld = old; ItOld != NULL; ItOld = ItOld->next) {
            if (strcmp(treeGetValue(ItNew->tree, "clid"), treeGetValue(ItOld->tree, "clid")) == 0) {

                if (strcmp(treeGetValue(ItNew->tree, "client_is_recording"), "1") == 0) {
                    clientRecording(mainSocket, ItOld->tree, ItNew->tree);
                }

                if (strcmp(treeGetValue(ItNew->tree, "cid"), treeGetValue(ItOld->tree, "cid")) != 0) {
                    clientMove(mainSocket, ItOld->tree, ItNew->tree);
                }

                long long oldAfk = strtoll(treeGetValue(ItOld->tree, "client_idle_time"), NULL, 0);
                long long newAfk = strtoll(treeGetValue(ItNew->tree, "client_idle_time"), NULL, 0);

                if (newAfk < oldAfk && oldAfk > TS3_BOT_MIN_AFK_TIME) {
                    clientStopBeAfk(mainSocket, ItOld->tree, ItNew->tree);
                }

                if (newAfk > TS3_BOT_MIN_AFK_TIME && oldAfk <= TS3_BOT_MIN_AFK_TIME) {
                    clientStartAfk(mainSocket, ItOld->tree, ItNew->tree);
                }

                if (strcmp(treeGetValue(ItNew->tree, "client_servergroups"), treeGetValue(ItOld->tree, "client_servergroups")) != 0) {
                    clientServerGroupChange(mainSocket, ItOld->tree, ItNew->tree);
                }
                exist = 1;
                break;
            }
        }
        if (!exist) {
            clientJoin(mainSocket, ItNew->tree);
        }
    }
}

void compareChannelList(int mainSocket, struct list *old, struct list *new) {
    int exist;
    for (struct list *ItOld = old; ItOld != NULL; ItOld = ItOld->next) {
        exist = 0;
        for (struct list *ItNew = new; ItNew != NULL; ItNew = ItNew->next) {
            if (strcmp(treeGetValue(ItNew->tree, "cid"), treeGetValue(ItOld->tree, "cid")) == 0) {
                exist = 1;
                break;
            }
        }
        if (!exist) {
            channelDelete(mainSocket, ItOld->tree);
        }
    }

    for (struct list *ItNew = new; ItNew != NULL; ItNew = ItNew->next) {

        for (struct list *ItOld = old; ItOld != NULL; ItOld = ItOld->next) {
            if (strcmp(treeGetValue(ItNew->tree, "cid"), treeGetValue(ItOld->tree, "cid")) == 0) {

                long long oldInactive = strtoll(treeGetValue(ItOld->tree, "seconds_empty"), NULL, 0);
                long long newInactive = strtoll(treeGetValue(ItNew->tree, "seconds_empty"), NULL, 0);

                if (newInactive > TS3_BOT_MIN_CHANNEL_INACTIVE_TIME && oldInactive <= TS3_BOT_MIN_CHANNEL_INACTIVE_TIME) {
                    channelInactive(mainSocket, ItOld->tree, ItNew->tree);
                }
                break;
            }
        }
    }
}
