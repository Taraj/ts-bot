//
// Created by Krzysiek on 22.11.2018.
//

#ifndef TS3_BOT_MYSQL_H
#define TS3_BOT_MYSQL_H

#include <mysql.h>
#include <stdio.h>
#include "../collections/collections.h"
#include <stdlib.h>
#include "../config.h"

struct list *execQuery(char *query);

char *sqlInjection(char *string);

#endif //TS3_BOT_MYSQL_H
