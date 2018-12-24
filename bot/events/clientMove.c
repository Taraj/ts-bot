//
// Created by Krzysiek on 25.11.2018.
//

#include "events.h"
#include "../../highLevelFunctions/highLevelFunctions.h"

void clientMove(int mainSocket, struct tree *old, struct tree *new) {
    char query[1024];
    sprintf(query, "CALL `client_move`('%s', '%s');", treeGetValue(new, "clid"), treeGetValue(new, "cid"));
    listFree(execQuery(query));

    if (strcmp(treeGetValue(new, "client_type"), "0") == 0 &&
        strcmp(treeGetValue(new, "cid"), TS3_HELPER_CHANNEL) == 0 &&
        haveGroup(new, TS3_HELPER_GROUP) == 0 &&
        haveGroup(new, TS3_HELPER_IGNORE_GROUP) == 0
            ) {
        char buffer[1024];
        int helperCount = 0;
        sprintf(buffer, "Aktywni Helperzy zostali powiadomieni o twoim wejsciu tutaj (");
        struct list *list = clientList(mainSocket, "-groups -uid");
        char *client_nicknameUser = unEscapeText(treeGetValue(new, "client_nickname"));
        char *client_unique_identifierUser = unEscapeText(treeGetValue(new, "client_unique_identifier"));
        char tmp[110];
        sprintf(tmp, "Pomocy [URL=client:///%s]%s[/URL]!!!", client_unique_identifierUser,
                client_nicknameUser);
        for (struct list *atm = list; atm != NULL; atm = atm->next) {
            if (haveGroup(atm->tree, TS3_HELPER_GROUP)) {

                clientPoke(mainSocket, atm->tree, tmp);
                helperCount++;
                char *client_nickname = unEscapeText(treeGetValue(atm->tree, "client_nickname"));
                char *client_unique_identifier = unEscapeText(treeGetValue(atm->tree, "client_unique_identifier"));
                sprintf(buffer + strlen(buffer), "[URL=client:///%s]%s[/URL], ", client_unique_identifier,
                        client_nickname);
                free(client_unique_identifier);
                free(client_nickname);
            }
        }

        if (helperCount == 0) {
            sendPrivateMessageToClient(mainSocket, new, "Brak aktywnych Helperów. Proszę spróbować później :).");
        } else {
            sprintf(buffer + strlen(buffer) - 2, ").");
            sendPrivateMessageToClient(mainSocket, new, buffer);
        }

    }
}