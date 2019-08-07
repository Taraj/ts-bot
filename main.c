#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <netdb.h>

#include "config.h"
#include "collections/collections.h"
#include "utilities.h"
#include "bot/compare.h"
#include "communication/communication.h"
#include "highLevelFunctions/highLevelFunctions.h"

#include "database/database.h"

char *hostnameToIP(char *hostname){
    struct hostent *he;
    if((he = gethostbyname(hostname)) == NULL){
        fprintf(stderr, "Nie mozna odczytac IP\n%s\n", strerror(errno));
        exit(errno);
    }
    return inet_ntoa(*((struct in_addr *)(he->h_addr_list[0])));
}

int main() {

    char *address = hostnameToIP(SERVER_ADDRESS);

    int connection = connectTeamSpeak(address, SERVER_PORT);

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

    listFree(execQuery("CALL `init`();"));

    struct list *clientListOld = clientList(connection, "-uid -voice -times -groups -info -country -ip -badges");
    struct list *clientListNew = NULL;

    struct list *channelListOld = channelList(connection, "-secondsempty");
    struct list *channelListNew = NULL;

    sleep(TS3_BOT_REFRESH_TIME);
    
    while (1) {
 
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