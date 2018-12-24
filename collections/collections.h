//
// Created by Krzysiek on 25.11.2018.
//

#ifndef TS3_BOT_COLLECTIONS_H
#define TS3_BOT_COLLECTIONS_H

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

struct tree {
    char *key;
    char *value;

    struct tree *left;
    struct tree *right;
};

struct list {
    struct tree *tree;

    struct list *next;
};

/**
 * Get value of node with the given key
 * @param tree - pointer to root node
 * @param key - unique key used to find node
 * @return if the node with the given key exists return @value else NULL
 */
char *treeGetValue(struct tree *tree, char *key);

/**
 * Insert element at the begin of the list and return pointer to first node
 * @param list - pointer to first node
 * @param tree - pointer to root node of the inserted element
 * @return pointer to first node
 */
struct list *listInsert(struct list *list, struct tree *tree);

/**
 * Insert element to tree
 * @param tree - pointer to root node
 * @param key - unique key used to find this node
 * @param value - string to storage
 * @return pointer to root node
 */
struct tree *treeInsert(struct tree *tree, char *key, char *value);

/**
 * Free all allocated memory
 * @param tree - pointer to root node
 * @return NULL
 */
struct tree *treeFree(struct tree *tree);

/**
 * Free all allocated memory
 * @param list - pointer to first node
 * @return NULL
 */
struct list *listFree(struct list *list);

/**
 * Print tree
 * @param tree - pointer to root node
 */
void treePrint(struct tree *tree);

/**
 * Print list
 * @param list - pointer to first node
 */
void listPrint(struct list *list);

struct list *listReverse(struct list *list);

#endif //TS3_BOT_COLLECTIONS_H
