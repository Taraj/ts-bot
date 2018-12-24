//
// Created by Krzysiek on 25.11.2018.
//

#include "highLevelFunctions.h"

static inline int executeCommandAndPrintError(int mainSocket, char *command) {
    struct result res = executeCommandWithBooleanResponse(mainSocket, command);
    if (res.error != NULL) {
        fprintf(stderr, "%s\n%s\n", command, res.error);
        free(res.error);
        return -1;
    }
    return 0;
}

int clientPoke(int mainSocket, struct tree *client, char *msg) {
    char command[1024];
    char cuttedMsg[101];
    char *escapedMsg = escapeText(msg);

    strncpy(cuttedMsg, escapedMsg, 100);
    free(escapedMsg);
    cuttedMsg[100] = '\0';

    sprintf(command, "clientpoke clid=%s msg=%s\n", treeGetValue(client, "clid"), cuttedMsg);

    return executeCommandAndPrintError(mainSocket, command);
}


int sendPrivateMessageToClient(int mainSocket, struct tree *client, char *msg) {
    char command[2048];
    char cuttedMsg[1025];
    char *escapedMsg = escapeText(msg);

    strncpy(cuttedMsg, escapedMsg, 1024);
    free(escapedMsg);
    cuttedMsg[1024] = '\0';

    sprintf(command, "sendtextmessage targetmode=1 target=%s msg=%s\n", treeGetValue(client, "clid"), cuttedMsg);

    return executeCommandAndPrintError(mainSocket, command);
}

char *createChannel(int mainSocket, char *name, char *password, char *cpid) {

    char command[2048];
    char cuttedName[41];
    char *escapedName = escapeText(name);

    strncpy(cuttedName, escapedName, 40);
    free(escapedName);
    cuttedName[40] = '\0';
    if (cpid == NULL) {
        sprintf(command, "channelcreate channel_flag_permanent=1 channel_name=%s channel_password=%s\n\n", cuttedName,
                password);
    } else {
        sprintf(command, "channelcreate channel_flag_permanent=1 cpid=%s channel_name=%s channel_password=%s\n\n",
                cpid, cuttedName, password);
    }
    struct result res = executeCommandWithTreeResponse(mainSocket, command);
    if (res.error != NULL) {
        fprintf(stderr, "%s\n%s\n", command, res.error);
        free(res.error);
        return NULL;
    }
    char *tmp = treeGetValue(res.data, "cid");
    size_t length = strlen(tmp) + 1;
    char *cid = malloc(length);
    if (cid == NULL) {
        fprintf(stderr, "Nie mozna przydzielic pamieci \"createChannel()\" - key\n%s\n", strerror(errno));
        exit(errno);
    }
    memcpy(cid, tmp, length);
    treeFree(res.data);
    return cid;
}

int kickClientFromServer(int mainSocket, struct tree *client, char *msg) {
    char command[1024];
    char cuttedMsg[81];
    char *escapedMsg = escapeText(msg);

    strncpy(cuttedMsg, escapedMsg, 80);
    free(escapedMsg);
    cuttedMsg[80] = '\0';

    sprintf(command, "clientkick clid=%s  reasonid=5 reasonmsg=%s\n", treeGetValue(client, "clid"), cuttedMsg);

    return executeCommandAndPrintError(mainSocket, command);
}

int moveClient(int mainSocket, struct tree *client, char *cid) {
    char command[1024];
    if (strcmp(treeGetValue(client, "cid"), cid) != 0) {
        sprintf(command, "clientmove clid=%s cid=%s\n", treeGetValue(client, "clid"), cid);
        return executeCommandAndPrintError(mainSocket, command);
    }
    return 0;
}

int channelGroupAddClient(int mainSocket, struct tree *client, char *cid, char *gid) {
    char command[1024];

    sprintf(command, "setclientchannelgroup cgid=%s cid=%s cldbid=%s\n", gid, cid,
            treeGetValue(client, "client_database_id"));

    return executeCommandAndPrintError(mainSocket, command);
}

int serverGroupAddClient(int mainSocket, struct tree *client, char *gid) {
    if (!haveGroup(client, gid)) {
        char command[1024];
        sprintf(command, "servergroupaddclient  sgid=%s cldbid=%s\n", gid, treeGetValue(client, "client_database_id"));
        return executeCommandAndPrintError(mainSocket, command);
    }
    return 0;
}

int serverGroupDeleteClient(int mainSocket, struct tree *client, char *gid) {
    if (haveGroup(client, gid)) {
        char command[1024];
        sprintf(command, "servergroupdelclient  sgid=%s cldbid=%s\n", gid, treeGetValue(client, "client_database_id"));
        return executeCommandAndPrintError(mainSocket, command);
    }
    return 0;
}

int deleteChannel(int mainSocket, char *cid) {
    char command[1024];

    sprintf(command, "channeldelete cid=%s force=0\n", cid);

    return executeCommandAndPrintError(mainSocket, command);
}

struct list *channelList(int mainSocket, char *flags) {
    char command[1024];
    sprintf(command, "channellist %s \n", flags);

    struct result res = executeCommandWthListResponse(mainSocket, command);
    if (res.error == NULL) {
        return res.data;
    }

    fprintf(stderr, "%s\n%s\n", command, res.error);
    free(res.error);

    return NULL;
}

struct list *clientList(int mainSocket, char *flags) {
    char command[1024];
    sprintf(command, "clientlist %s \n", flags);

    struct result res = executeCommandWthListResponse(mainSocket, command);
    if (res.error == NULL) {
        return res.data;
    }

    fprintf(stderr, "%s\n%s\n", command, res.error);
    free(res.error);
    return NULL;
}

int chanelChangeDescription(int mainSocket, char *cid, char *description) {
    char command[10480];

    char *escapedMsg = escapeText(description);

    sprintf(command, "channeledit cid=%s channel_description=%s\n", cid, escapedMsg);
    free(escapedMsg);
    return executeCommandAndPrintError(mainSocket, command);

}

