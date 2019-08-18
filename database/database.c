//
// Created by Krzysiek on 21.11.2018.
//
#include "database.h"

struct list *execQuery(char *query) {
    struct list *response = NULL;
    MYSQL_RES *result;
    MYSQL_ROW row;
    MYSQL_FIELD *field;
    MYSQL *connection = mysql_init(NULL);
    if (mysql_real_connect(connection, DATABASE_ADDRESS, DATABASE_USER, DATABASE_PASSWORD, DATABASE, 0, NULL, 0) == NULL) {
        fprintf(stderr, "%s\n%s\n", query, mysql_error(connection));
        mysql_close(connection);
        return NULL;
    }

    if (mysql_query(connection, "set names 'utf8mb4';") != 0) {
        fprintf(stderr, "set names 'utf8'\n%s\n", mysql_error(connection));
        mysql_close(connection);
        return NULL;
    }

    if (mysql_query(connection, query) != 0) {
        fprintf(stderr, "%s\n%s\n", query, mysql_error(connection));
        mysql_close(connection);
        return NULL;
    }

    if ((result = mysql_store_result(connection)) == NULL) {
        if (*mysql_error(connection))
            fprintf(stderr, "%s\n%s\n", query, mysql_error(connection));
        mysql_close(connection);
        return NULL;
    }
    unsigned long length = mysql_num_fields(result);

    char *fieldNames[length];
    int j = 0;

    while ((field = mysql_fetch_field(result))) {
        fieldNames[j] = field->name;
        j++;
    }

    while ((row = mysql_fetch_row(result)) != NULL) {
        struct tree *tree = NULL;
        for (int i = 0; i < length; i++) {
            tree = treeInsert(tree, fieldNames[i], row[i]);
        }
        response = listInsert(response, tree);
    }

    mysql_free_result(result);
    mysql_close(connection);
    return response;
}


char *sqlInjection(char *string) {
    size_t length = strlen(string) * 2;
    char *new = malloc(length + 1);
    char *it = new;
    if (new == NULL) {
        fprintf(stderr, "Nie mozna przydzielic pamieci \"sqlInjection()\"\n%s\n", strerror(errno));
        exit(errno);
    }
    while (*string) {
        if (*string == '\'') {
            *(it++) = '\\';
        }
        if (*string == '\\') {
            *(it++) = '\\';
        }
        *(it++) = *(string++);
    }
    *it = '\0';
    return new;
}