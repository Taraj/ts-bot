//
// Created by Krzysiek on 23.12.2018.
//

#include "rankings.h"


void updateRankingConnectionTimes(int mainSocket, char *cid) {

    char *description = malloc(10240);
    if (description == NULL) {
        fprintf(stderr, "Nie mozna przydzielic pamieci \"updateRankingConnectionTimes()\"\n%s\n", strerror(errno));
        exit(errno);
    }


    sprintf(description, "[center][B][size=30][COLOR=#ff0000]Ranking Czasu Połączeń[/COLOR][/size]\n"
                         "[size=20]\n");

    struct list *clients = listReverse(execQuery(
            "SELECT `total_connection_time`,`last_nickname`,`total_inactivity_time`, `TS_client_unique_identifier` FROM `clients` ORDER BY `total_connection_time` DESC LIMIT 20"));
    int i = 1;
    for (struct list *it = clients; it != NULL; it = it->next) {
        sprintf(description + strlen(description),
                "%d. [URL=client:///%s]%s[/URL] - %lfh [COLOR=#b3b3b3](%lfh AFK)[/COLOR]\n", i++,
                treeGetValue(it->tree, "TS_client_unique_identifier"), treeGetValue(it->tree, "last_nickname"),
                strtol(treeGetValue(it->tree, "total_connection_time"), NULL, 0) / 3600.0,
                strtol(treeGetValue(it->tree, "total_inactivity_time"), NULL, 0) / 3600.0);
    }
    chanelChangeDescription(mainSocket, cid, description);
    listFree(clients);
    free(description);
}

void updateRankingConnectionCount(int mainSocket, char *cid) {
    char *description = malloc(10240);
    if (description == NULL) {
        fprintf(stderr, "Nie mozna przydzielic pamieci \"updateRankingConnectionTimes()\"\n%s\n", strerror(errno));
        exit(errno);
    }
    sprintf(description, "[center][B][size=30][COLOR=#ff0000]Ranking Ilości Połączeń[/COLOR][/size]\n"
                         "[size=20]\n");

    struct list *clients = listReverse(execQuery(
            "SELECT `total_connection_count`,`last_nickname`,`TS_client_unique_identifier` FROM `clients` ORDER BY `total_connection_count` DESC LIMIT 20;"));

    int i = 1;
    for (struct list *it = clients; it != NULL; it = it->next) {
        sprintf(description + strlen(description), "%d. [URL=client:///%s]%s[/URL] - %s\n", i++,
                treeGetValue(it->tree, "TS_client_unique_identifier"), treeGetValue(it->tree, "last_nickname"),
                treeGetValue(it->tree, "total_connection_count"));
    }
    chanelChangeDescription(mainSocket, cid, description);
    listFree(clients);
    free(description);
}

