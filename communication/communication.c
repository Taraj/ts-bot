//
// Created by Krzysiek on 04.12.2018.
//

#include "communication.h"

static struct tree *parseItemHelper(struct tree *tree, char *data) {
    if (data == NULL)
        return tree;
    char *separator = strchr(data, '=');

    if (separator != NULL) {
        *separator = '\0';
        return treeInsert(tree, data, separator + 1);
    }

    return treeInsert(tree, data, "");
}

static struct tree *parseItem(char *data) {
    struct tree *tree = NULL;
    char *separator = data;
    char *singleValue = data;
    while ((separator = strchr(separator, ' ')) != NULL) {
        *separator = '\0';
        tree = parseItemHelper(tree, singleValue);
        singleValue = ++separator;
    }
    tree = parseItemHelper(tree, singleValue);

    return tree;
}

static struct list *parseList(char *data) {
    struct list *list = NULL;

    char *separator = data;
    char *singleValue = data;
    while ((separator = strchr(separator, '|')) != NULL) {
        *separator = '\0';
        list = listInsert(list, parseItem(singleValue));
        singleValue = ++separator;
    }
    list = listInsert(list, parseItem(singleValue));

    return list;
}

static struct result executeCommand(int mainSocket, char *command) {
    struct result result;

    if (send(mainSocket, command, strlen(command), 0) == -1) {
        fprintf(stderr, "Nie mozna wyslac danych\n%s\n", strerror(errno));
        exit(errno);
    }

    char *data = receiveAllDataFromTeamSpeak(mainSocket);

    if (strstr(data, "error id=0 msg=ok") == NULL) {
        result.error = data;
        result.data = NULL;
        return result;
    }

    *strchr(data, '\n') = '\0';

    result.error = NULL;
    result.data = data;

    return result;
}

struct result executeCommandWthListResponse(int mainSocket, char *command) {
    struct result result = executeCommand(mainSocket, command);

    if (result.error != NULL) {
        return result;
    }

    struct list *list = parseList(result.data);
    free(result.data);

    result.data = list;

    return result;
}

struct result executeCommandWithTreeResponse(int mainSocket, char *command) {
    struct result result = executeCommand(mainSocket, command);

    if (result.error != NULL) {
        return result;
    }

    struct tree *tree = parseItem(result.data);
    free(result.data);

    result.data = tree;

    return result;
}

struct result executeCommandWithBooleanResponse(int mainSocket, char *command) {
    struct result result = executeCommand(mainSocket, command);

    if (result.error != NULL) {
        return result;
    }

    free(result.data);

    result.data = NULL;

    return result;
}

struct result executeCommandWithPlainTextResponse(int mainSocket, char *command) {
    return executeCommand(mainSocket, command);
}

int connectTeamSpeak(char *ip, u_int16_t port) {
    int mainSocket = createSocket(ip, port);
    char *response = malloc(1024);
    if (response == NULL) {
        fprintf(stderr, "Nie mozna przydzielic pamieci \"connectTeamSpeak()\"\n%s\n", strerror(errno));
        exit(errno);
    }
    if (recv(mainSocket, response, 1024, 0) <= 0) {
        fprintf(stderr, "Nie mozna otrzymac danych\n%s\n", strerror(errno));
        exit(errno);
    }
    free(response);
    return mainSocket;
}