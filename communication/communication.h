//
// Created by Krzysiek on 04.12.2018.
//

#ifndef TS3_BOT_COMMUNICATION_H
#define TS3_BOT_COMMUNICATION_H

#include <sys/socket.h>
#include "../collections/collections.h"
#include "network/network.h"

struct result {
    char *error;
    void *data;
};

/**
 * Connect to Team Speak server and skip welcome message if connection will fail program will be terminated and error will be printed
 * @param ip - server address(ipv4)
 * @param port - server port
 * @return socket descriptor
 */
int connectTeamSpeak(char *ip, uint16_t port);

/**
 * Execute Team Speak command and return response
 * @param mainSocket - socket descriptor connected to the ts3 server
 * @param command - command to execute (remember to insert '\n' at the end of command and escape all needed characters)
 * @return struct result{char *error; struct list *data;};
 *      On succes:
 *          error = NULL
 *          data - contains pointer to dynamically allocated list
 *      On error:
 *          error - dynamically allocated error message returned from ts3
 *          data = NULL
 */
struct result executeCommandWthListResponse(int mainSocket, char *command);


/**
 * Execute Team Speak command and return response
 * @param mainSocket - socket descriptor connected to the ts3 server
 * @param command - command to execute (remember to insert '\n' at the end of command and escape all needed characters)
 * @return struct result{char *error; struct tree *data;};
 *      On succes:
 *          error = NULL
 *          data - contains pointer to dynamically allocated tree
 *      On error:
 *          error - dynamically allocated error message returned from ts3
 *          data = NULL
 */
struct result executeCommandWithTreeResponse(int mainSocket, char *command);


/**
 * Execute Team Speak command and return response
 * @param mainSocket - socket descriptor connected to the ts3 server
 * @param command - command to execute (remember to insert '\n' at the end of command and escape all needed characters)
 * @return struct result{char *error; void *data;};
 *      On succes:
 *          error = NULL
 *          data = NULL
 *      On error:
 *          error - dynamically allocated error message returned from ts3
 *          data = NULL
 */
struct result executeCommandWithBooleanResponse(int mainSocket, char *command);


/**
 * Execute Team Speak command and return response
 * @param mainSocket - socket descriptor connected to the ts3 server
 * @param command - command to execute (remember to insert '\n' at the end of command and escape all needed characters)
 * @return struct result{char *error; char *data;};
 *      On succes:
 *          error = NULL
 *          data - dynamically allocated  message returned from ts3
 *      On error:
 *          error - dynamically allocated error message returned from ts3
 *          data = NULL
 */
struct result executeCommandWithPlainTextResponse(int mainSocket, char *command);


#endif //TS3_BOT_COMMUNICATION_H
