//
// Created by Krzysiek on 20.11.2018.
//

#ifndef TS3_BOT_UTILITIES_H
#define TS3_BOT_UTILITIES_H

#include "config.h"

#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>

#include "collections/collections.h"

int haveGroup(struct tree *tree, char *group);

/**
 * Decode string from ts3
 * @param string
 * @return
 */
char *unEscapeText(char *string);


/**
 * Prepare string to send
 * @param string
 * @return
 */
char *escapeText(char *string);
#endif //TS3_BOT_UTILITIES_H
