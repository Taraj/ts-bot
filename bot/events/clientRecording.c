//
// Created by Krzysiek on 25.11.2018.
//

#include "events.h"

void clientRecording(int mainSocket, struct tree *old, struct tree *new) {
    if (!haveGroup(new, TS3_ALLOW_RECORDING_GROUP)) {
        kickClientFromServer(mainSocket, new, "Zakaz nagrywania!!!");
    }
}