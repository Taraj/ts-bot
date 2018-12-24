//
// Created by Krzysiek on 25.11.2018.
//
#include "collections.h"

struct list *listInsert(struct list *list, struct tree *tree) {
    struct list *item = malloc(sizeof(struct list));
    if (item == NULL) {
        fprintf(stderr, "Nie mozna przydzielic pamieci \"listInsert()\"\n%s\n", strerror(errno));
        exit(errno);
    }
    item->tree = tree;
    item->next = list;
    return item;
}


struct list *listFree(struct list *list) {
    struct list *last = list;
    while (list != NULL) {
        list = list->next;
        treeFree(last->tree);
        free(last);
        last = list;
    }
    return NULL;
}

struct list *listReverse(struct list *list) {
    struct list *new = NULL;

    struct list *last = list;
    while (list != NULL) {
        new = listInsert(new, list->tree);
        list = list->next;
        free(last);
        last = list;
    }
    return new;
}

void listPrint(struct list *list) {
    while (list != NULL) {
        printf("----------------------------------------------\n");
        treePrint(list->tree);
        printf("----------------------------------------------\n");
        list = list->next;
    }
}
