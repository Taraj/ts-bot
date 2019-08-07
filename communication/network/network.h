//
// Created by Krzysiek on 23.12.2018.
//

#ifndef TS3_BOT_NETWORK_H
#define TS3_BOT_NETWORK_H

#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>

#include "../../config.h"

/**
 * Create socket and connect to specified @ip and @port if connection will fail program will be terminated and error will be printed
 * @param ip - server address(ipv4)
 * @param port - server port
 * @return socket descriptor
 */
int createSocket(char *ip, uint16_t port);


/**
 * Receive all data from Team Speak except welcome message because function try to receive data until not receive "error id="
 * @param mainSocket - socket descriptor
 * @return pointer to dynamic allocated string contain received data
 */
char *receiveAllDataFromTeamSpeak(int mainSocket);


#endif //TS3_BOT_NETWORK_H
