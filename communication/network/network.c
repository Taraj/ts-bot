//
// Created by Krzysiek on 23.12.2018.
//

#include "network.h"

int createSocket(char *ip, u_int16_t port) {
    int mainSocket;
    struct sockaddr_in address;

    address.sin_family = AF_INET;
    address.sin_port = htons(port);
    address.sin_addr.s_addr = inet_addr(ip);

    if ((mainSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)) == -1) {
        fprintf(stderr, "Nie mozna utworzyc gniazda\n%s\n", strerror(errno));
        exit(errno);
    }

    if (connect(mainSocket, (struct sockaddr *) &address, sizeof(address)) == -1) {
        if (mainSocket) {
            close(mainSocket);
        }

        fprintf(stderr, "Nie mozna nawiazac polaczenia\n%s\n", strerror(errno));
        exit(errno);
    }
    return mainSocket;
}


char *receiveAllDataFromTeamSpeak(int mainSocket) {
    char *response = NULL;
    int dataLength = 0;
    size_t offset = 0;
    while (1) {
        response = realloc(response, offset + TS3_BOT_DATA_PACKAGE_SIZE + 1);
        if (response == NULL) {
            fprintf(stderr, "Nie mozna przydzielic pamieci \"receiveAllDataFromTeamSpeak()\"\n%s\n", strerror(errno));
            exit(errno);
        }

        if ((dataLength = recv(mainSocket, response + offset, TS3_BOT_DATA_PACKAGE_SIZE, 0)) <= 0) {
            fprintf(stderr, "Nie mozna otrzymac danych\n%s\n", strerror(errno));
            exit(errno);
        }
        offset += dataLength;
        response[offset] = '\0';

        if (offset >= 2)
            if (response[offset - 2] == '\n' && strstr(response, "error id=") != NULL)
                break;
    }
    return response;
}