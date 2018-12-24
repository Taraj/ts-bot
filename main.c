#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "config.h"
#include "collections/collections.h"
#include "utilities.h"
#include "bot/compare.h"
#include "communication/communication.h"
#include "highLevelFunctions/highLevelFunctions.h"

int main() {
    int connection = connectTeamSpeak(SERVER_IP, SERVER_PORT);

    char buffer[256];
    struct result res;
    sprintf(buffer, "login %s %s\n", TS3_SERVER_ADMIN_LOGIN, TS3_SERVER_ADMIN_PASSWORD);
    res = executeCommandWithBooleanResponse(connection, buffer);
    if (res.error != NULL) {
        fprintf(stderr, "%s\n%s\n", buffer, res.error);
        free(res.error);
        exit(1);
    }

    sprintf(buffer, "use %d client_nickname=%s\n", TS3_SERVER_ID, TS3_BOT_NAME);
    res = executeCommandWithBooleanResponse(connection, buffer);
    if (res.error != NULL) {
        fprintf(stderr, "%s\n%s\n", buffer, res.error);
        free(res.error);
        exit(1);
    }

    struct list *clientListOld = clientList(connection, "-uid -voice -times -groups -info -country -ip -badges");
    struct list *clientListNew = NULL;

    struct list *channelListOld = channelList(connection, "-secondsempty");
    struct list *channelListNew = NULL;

    sleep(TS3_BOT_REFRESH_TIME);
    int i = 120;
    while (i--) {
        printf("%d\n", i);
        clientListNew = clientList(connection, "-uid -voice -times -groups -info -country -ip -badges");
        channelListNew = channelList(connection, "-secondsempty");

        compareClientList(connection, clientListOld, clientListNew);
        compareChannelList(connection, channelListOld, channelListNew);

        listFree(channelListOld);
        listFree(clientListOld);

        channelListOld = channelListNew;
        clientListOld = clientListNew;

        sleep(TS3_BOT_REFRESH_TIME);
    }
    listFree(clientListOld);
    listFree(channelListOld);

    return 0;
}