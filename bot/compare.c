//
// Created by Krzysiek on 04.12.2018.
//

#include "compare.h"

void compareClientList(int mainSocket, struct list *old, struct list *new) {
    struct list *last;
    int exist;
    last = new;
    for (struct list *ItOld = old; ItOld != NULL; ItOld = ItOld->next) {
        exist = 0;
        for (struct list *ItNew = last; ItNew != NULL; ItNew = ItNew->next) {
            if (strcmp(treeGetValue(ItNew->tree, "clid"), treeGetValue(ItOld->tree, "clid")) == 0) {
                exist = 1;
                last = ItNew->next;
                break;
            }
        }
        if (!exist) {
            clientLeft(mainSocket, ItOld->tree);
        }
    }

    last = old;
    for (struct list *ItNew = new; ItNew != NULL; ItNew = ItNew->next) {
        exist = 0;
        for (struct list *ItOld = last; ItOld != NULL; ItOld = ItOld->next) {
            if (strcmp(treeGetValue(ItNew->tree, "clid"), treeGetValue(ItOld->tree, "clid")) == 0) {

                if (strcmp(treeGetValue(ItNew->tree, "client_is_recording"), "1") == 0) {
                    clientRecording(mainSocket, ItOld->tree, ItNew->tree);
                }

                if (strcmp(treeGetValue(ItNew->tree, "cid"), treeGetValue(ItOld->tree, "cid")) != 0) {
                    clientMove(mainSocket, ItOld->tree, ItNew->tree);
                }

                long long oldAfk = strtoll(treeGetValue(ItOld->tree, "client_idle_time"), NULL, 0);
                long long newAfk = strtoll(treeGetValue(ItNew->tree, "client_idle_time"), NULL, 0);

                if (newAfk < oldAfk && oldAfk > TS3_MIN_AFK_TIME) {
                    clientStopBeAfk(mainSocket, ItOld->tree, ItNew->tree);
                }

                if (newAfk > TS3_MIN_AFK_TIME && oldAfk <= TS3_MIN_AFK_TIME) {
                    clientStartAfk(mainSocket, ItOld->tree, ItNew->tree);
                }

                if (strcmp(treeGetValue(ItNew->tree, "client_servergroups"),
                           treeGetValue(ItOld->tree, "client_servergroups")) != 0) {
                    clientServerGroupChange(mainSocket, ItOld->tree, ItNew->tree);
                }
                exist = 1;
                last = ItOld->next;
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
    struct list *last;
    last = new;
    for (struct list *ItOld = old; ItOld != NULL; ItOld = ItOld->next) {
        exist = 0;
        for (struct list *ItNew = last; ItNew != NULL; ItNew = ItNew->next) {
            if (strcmp(treeGetValue(ItNew->tree, "cid"), treeGetValue(ItOld->tree, "cid")) == 0) {
                exist = 1;
                last = ItNew->next;
                break;
            }
        }
        if (!exist) {
            channelDelete(mainSocket, ItOld->tree);
        }
    }
}
