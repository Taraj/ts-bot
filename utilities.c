//
// Created by Krzysiek on 20.11.2018.
//

#include "utilities.h"

int haveGroup(struct tree *tree, char *group) {
    char *groupsTree = treeGetValue(tree, "client_servergroups");
    char *groups = malloc(strlen(groupsTree) + 1);
    if (groups == NULL) {
        fprintf(stderr, "Nie mozna przydzielic pamieci \"haveGroup()\"\n%s\n", strerror(errno));
        exit(errno);
    }
    strcpy(groups, groupsTree);
    char *pch = strtok(groups, ",");
    while (pch != NULL) {

        if (strcmp(group, pch) == 0) {
            free(groups);
            return 1;
        }
        pch = strtok(NULL, ",");
    }
    free(groups);
    return 0;
}
char *unEscapeText(char *string) {
    size_t size = strlen(string);
    char *new = malloc(size + 1);
    if (new == NULL) {
        fprintf(stderr, "Nie mozna przydzielic pamieci \"unEscapeText()\"\n%s\n", strerror(errno));
        exit(errno);
    }

    char *atm = new;
    for (int i = 0; i < size; i++) {
        if (string[i] == '\\') {
            switch (string[++i]) {
                case 's':
                    *atm = ' ';
                    break;
                case '\\':
                    *atm = '\\';
                    break;
                case '/':
                    *atm = '/';
                    break;
                case 'p':
                    *atm = '|';
                    break;
                case 'a':
                    *atm = '\a';
                    break;
                case 'b':
                    *atm = '\b';
                    break;
                case 'f':
                    *atm = '\f';
                    break;
                case 'n':
                    *atm = '\n';
                    break;
                case 'r':
                    *atm = '\r';
                    break;
                case 't':
                    *atm = '\t';
                    break;
                case 'v':
                    *atm = '\v';
                    break;
                default:
                    atm--;
            }
        } else {
            *atm = string[i];
        }
        atm++;
    }
    *atm = '\0';
    return new;
}

char *escapeText(char *string) {
    size_t size = strlen(string);
    char *new = malloc(2 * size + 1);
    if (new == NULL) {
        fprintf(stderr, "Nie mozna przydzielic pamieci \"unEscapeText()\"\n%s\n", strerror(errno));
        exit(errno);
    }
    char *atm = new;
    for (int i = 0; i < size; i++) {
        switch (string[i]) {
            case ' ':
                *atm = '\\';
                *(++atm) = 's';
                break;
            case '\\':
                *atm = '\\';
                *(++atm) = '\\';
                break;
            case '/':
                *atm = '\\';
                *(++atm) = '/';
                break;
            case '|':
                *atm = '\\';
                *(++atm) = 'p';
                break;
            case '\a':
                *atm = '\\';
                *(++atm) = 'a';
                break;
            case '\b':
                *atm = '\\';
                *(++atm) = 'b';
                break;
            case '\f':
                *atm = '\\';
                *(++atm) = 'f';
                break;
            case '\n':
                *atm = '\\';
                *(++atm) = 'n';
                break;
            case '\r':
                *atm = '\\';
                *(++atm) = 'r';
                break;
            case '\t':
                *atm = '\\';
                *(++atm) = 't';
                break;
            case '\v':
                *atm = '\\';
                *(++atm) = 'v';
                break;
            default:
                *atm = string[i];
        }
        atm++;
    }
    *atm = '\0';
    return new;
}
