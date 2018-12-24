//
// Created by Krzysiek on 25.11.2018.
//

#include "events.h"
#include <time.h>
#include "../../rankings/rankings.h"

static char *getTime(char *time) {
    time_t now = strtol(time, NULL, 0);
    struct tm ts;

    char *buffer = malloc(200 * sizeof(char));
    if (buffer == NULL) {
        fprintf(stderr, "Nie mozna przydzielic pamieci \"getTime()\"\n%s\n", strerror(errno));
        exit(errno);
    }
    ts = *localtime(&now);
    strftime(buffer, 200, "[B]%d.%m.%Y %H:[/B][B]%M[/B]", &ts);
    return buffer;
}

static char *getPolishMessage(struct tree *client, struct list *clientStats) {
    char *msg = malloc(sizeof(char) * 1024);
    if (msg == NULL) {
        fprintf(stderr, "Nie mozna przydzielic pamieci \"getPolishMessage()\"\n%s\n", strerror(errno));
        exit(errno);
    }
    char *client_nickname = unEscapeText(treeGetValue(client, "client_nickname"));
    char *firstConnection = getTime(treeGetValue(clientStats->tree, "first_connection"));
    char *lastConnection = getTime(treeGetValue(clientStats->tree, "last_connection"));
    sprintf(msg, "\n[B]Witaj [COLOR=#ff0000]%s[/COLOR]!!![/B]\n"
                 "Jest to twoja [B][COLOR=#00ff00]%s[/COLOR][/B] wizyta.\n"
                 "Spędziłeś\\aś u nas łącznie [B][COLOR=#0000ff]%lfh [/COLOR][/B][COLOR=#737373](w tym %lfh AFK)[/COLOR].\n"
                 "Twoja pierwsza wizyta: %s\n"
                 "Twoja ostatnia wizyta: %s",
            client_nickname,
            treeGetValue(clientStats->tree, "total_connection_count"),
            strtol(treeGetValue(clientStats->tree, "total_connection_time"), NULL, 0) / 3600.0,
            strtol(treeGetValue(clientStats->tree, "total_inactivity_time"), NULL, 0) / 3600.0,
            firstConnection, lastConnection);
    free(lastConnection);
    free(client_nickname);
    free(firstConnection);
    return msg;
}

static char *getEnglishMessage(struct tree *client, struct list *clientStats) {
    char *msg = malloc(sizeof(char) * 1024);
    if (msg == NULL) {
        fprintf(stderr, "Nie mozna przydzielic pamieci \"getEnglishMessage()\"\n%s\n", strerror(errno));
        exit(errno);
    }
    char *client_nickname = unEscapeText(treeGetValue(client, "client_nickname"));
    char *firstConnection = getTime(treeGetValue(clientStats->tree, "first_connection"));
    char *lastConnection = getTime(treeGetValue(clientStats->tree, "last_connection"));
    sprintf(msg, "\n[B]Hello [COLOR=#ff0000]%s[/COLOR]!!![/B]\n"
                 "This is your [B][COLOR=#00ff00]%s[/COLOR][/B] visit.\n"
                 "You spent a total of [B][COLOR=#0000ff]%lfh [/COLOR][/B][COLOR=#737373] with us (including %lfh AFK)[/COLOR].\n"
                 "Your first visit:  %s\n"
                 "Your last visit: %s",
            client_nickname,
            treeGetValue(clientStats->tree, "total_connection_count"),
            strtol(treeGetValue(clientStats->tree, "total_connection_time"), NULL, 0) / 3600.0,
            strtol(treeGetValue(clientStats->tree, "total_inactivity_time"), NULL, 0) / 3600.0,
            firstConnection, lastConnection);
    free(lastConnection);
    free(firstConnection);
    free(client_nickname);
    return msg;
}

static int sendWelcomeMessage(int mainSocket, struct tree *client) {
    char query[1024];
    sprintf(query, "SELECT "
                   "IF(`last_connection` = 0 , `first_connection`,`last_connection`) AS `last_connection`,"
                   "`first_connection`, "
                   "`total_connection_count` + 1 as `total_connection_count`, "
                   "`total_connection_time`, "
                   "`total_inactivity_time` "
                   " FROM `clients` WHERE `TS_client_database_id` = %s;", treeGetValue(client, "client_database_id"));

    struct list *clientStats = execQuery(query);
    if (clientStats != NULL) {
        char *msg = NULL;
        if (strcmp(treeGetValue(client, "client_country"), "PL") == 0) {
            msg = getPolishMessage(client, clientStats);
        } else {
            msg = getEnglishMessage(client, clientStats);
        }
        sendPrivateMessageToClient(mainSocket, client, msg);
        free(msg);
    }
    listFree(clientStats);
}


void clientJoin(int mainSocket, struct tree *new) {
    char query[1024];

    char *client_nickname = unEscapeText(treeGetValue(new, "client_nickname"));
    char *safe_client_nickname = sqlInjection(client_nickname);
    free(client_nickname);
    char *client_version = unEscapeText(treeGetValue(new, "client_version"));
    char *client_unique_identifier = unEscapeText(treeGetValue(new, "client_unique_identifier"));
    char *client_platform = unEscapeText(treeGetValue(new, "client_platform"));

    sprintf(query, "CALL `client_join`('%s', '%s', '%s', '%s', '%s', '%s','%s', '%s', '%s');",
            client_unique_identifier,
            treeGetValue(new, "client_database_id"),
            treeGetValue(new, "clid"),
            safe_client_nickname,
            client_platform,
            treeGetValue(new, "connection_client_ip"),
            client_version,
            treeGetValue(new, "client_country"),
            treeGetValue(new, "cid")
    );
    free(safe_client_nickname);

    free(client_version);
    free(client_unique_identifier);
    free(client_platform);
    listFree(execQuery(query));


    if (strcmp(treeGetValue(new, "client_type"), "0") == 0) {
        sendWelcomeMessage(mainSocket, new);
    }
    updateRankingConnectionTimes(mainSocket, TS3_RANKING_TIME);
    updateRankingConnectionCount(mainSocket, TS3_RANKING_COUNT);
}
