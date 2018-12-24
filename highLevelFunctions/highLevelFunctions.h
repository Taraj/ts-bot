//
// Created by Krzysiek on 25.11.2018.
//

#ifndef TS3_BOT_HIGHLEVELFUNCTIONS_H
#define TS3_BOT_HIGHLEVELFUNCTIONS_H

#include <stdio.h>

#include "../collections/collections.h"
#include "../communication/communication.h"
#include "../utilities.h"

/**
 * @param mainSocket - socket descriptor
 * @param client - client tree
 * @param msg  - message, maximum length 100 (the excess will be cut off)
 * @return if success 0, on error -1
 */
int clientPoke(int mainSocket, struct tree *client, char *msg);

/**
 * @param mainSocket - socket descriptor
 * @param client - client tree
 * @param msg - message, maximum length 1024 (the excess will be cut off)
 * @return if success 0, on error -1
 */
int sendPrivateMessageToClient(int mainSocket, struct tree *client, char *msg);

/**
 * @param mainSocket - socket descriptor
 * @param client - client tree
 * @param msg - message, maximum length 80 (the excess will be cut off)
 * @return if success 0, on error -1
 */
int kickClientFromServer(int mainSocket, struct tree *client, char *msg);

/**
 * @param mainSocket - socket descriptor
 * @param client - client tree
 * @param cid - channel id
 * @return if success 0, on error -1
 */
int moveClient(int mainSocket, struct tree *client, char *cid);

/**
 * @param mainSocket - socket descriptor
 * @param client - client tree
 * @param cid - channel id
 * @param gid - channel group id
 * @return if success 0, on error -1
 */
int channelGroupAddClient(int mainSocket, struct tree *client, char *cid, char *gid);

/**
 * @param mainSocket - socket descriptor
 * @param client - client tree
 * @param gid - server group id
 * @return if success 0, on error -1
 */
int serverGroupDeleteClient(int mainSocket, struct tree *client, char *gid);

/**
 * @param mainSocket - socket descriptor
 * @param client - client tree
 * @param gid - server group id
 * @return if success 0, on error -1
 */
int serverGroupAddClient(int mainSocket, struct tree *client, char *gid);

/**
 *
 * @param mainSocket
 * @param cid
 * @return
 */
int deleteChannel(int mainSocket, char *cid);

/**
 *
 * @param mainSocket
 * @param cid
 * @param description
 * @return
 */
int chanelChangeDescription(int mainSocket, char *cid, char *description);

/**
 * @param mainSocket - socket descriptor
 * @param name - maximum length 40 (the excess will be cut off)
 * @param cpid - parent id (if NULL will be created without a parent)
 * @return if success channel id, on error NULL
 */
char *createChannel(int mainSocket, char *name, char *password, char *cpid);


struct list *channelList(int mainSocket, char *flags);

struct list *clientList(int mainSocket, char *flags);



#endif //TS3_BOT_HIGHLEVELFUNCTIONS_H
