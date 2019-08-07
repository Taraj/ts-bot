//
// Created by Krzysiek on 25.11.2018.
//

#include "events.h"

char *randomString(int length) {
    char *str = malloc(sizeof(char) * length + 1);
    if (str == NULL) {
        fprintf(stderr, "Nie mozna przydzielic pamieci \"randomString()\"\n%s\n", strerror(errno));
        exit(errno);
    }
    char available[62] = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM123456789";
    srand(time(NULL));
    for (int i = 0; i < length; i++) {
        str[i] = available[rand() % 60];
    }
    str[length] = '\0';
    return str;
}

void clientServerGroupChange(int mainSocket, struct tree *old, struct tree *new) {
    if (haveGroup(new, TS3_CREATE_CHANNEL_GROUP)) {
        serverGroupDeleteClient(mainSocket, new, TS3_CREATE_CHANNEL_GROUP);
        char query[1024];
        sprintf(query,
                "SELECT `TS_cid` FROM `channels` WHERE `clients_id` = (SELECT `id` FROM `clients` WHERE `TS_client_database_id` = %s);",
                treeGetValue(old, "client_database_id"));
        struct list *channel = execQuery(query);

        if (channel == NULL) {
            char *name = randomString(40);
            char *channelId = createChannel(mainSocket, name, TS3_CHANNEL_DEFAULT_PASSWORD, NULL);
            free(name);
            if (channelId == NULL) {
                return;
            }
            channelGroupAddClient(mainSocket, new, channelId, TS3_CHANNEL_ADMIN_GROUP);

            sprintf(query, "CALL `channel_create`('%s', '1', '%s');", channelId,
                    treeGetValue(new, "client_database_id"));
            listFree(execQuery(query));
            moveClient(mainSocket, new, channelId);
            free(channelId);
        } else {
            moveClient(mainSocket, new, treeGetValue(channel->tree, "TS_cid"));
            listFree(channel);
        }
    }
}