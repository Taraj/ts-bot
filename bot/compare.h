//
// Created by Krzysiek on 04.12.2018.
//

#ifndef TS3_BOT_COMPARE_H
#define TS3_BOT_COMPARE_H

#include "stdlib.h"
#include "string.h"
#include "../collections/collections.h"
#include "../config.h"
#include "events/events.h"

/**
 * Compares 2 list of clients and call functions in ./events/ if detect any changes. If you want catch more events
 * you must add it to this function but remember if you want to use more clients properties all must be in both clients lists
 * @param mainSocket - socket descriptor
 * @param old - list of clients
 * @param new - list of clients
 */
void compareClientList(int mainSocket, struct list *old, struct list *new);


/**
 * Compares 2 list of channels and call functions in ./events/ if detect any changes. If you want catch more events
 * you must add it to this function but remember if you want to use more channels properties all must be in both channels lists
 * @param mainSocket - socket descriptor
 * @param old - list of channels
 * @param new - list of channels
 */
void compareChannelList(int mainSocket, struct list *old, struct list *new);

#endif //TS3_BOT_COMPARE_H
