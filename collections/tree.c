//
// Created by Krzysiek on 25.11.2018.
//
#include "collections.h"
struct tree *treeInsert(struct tree *tree, char *key, char *value) {

    if (tree == NULL) {
        size_t keyLength = strlen(key) + 1;
        size_t valueLength = strlen(value) + 1;

        struct tree *leaf = malloc(sizeof(struct tree));
        if (leaf == NULL) {
            fprintf(stderr, "Nie mozna przydzielic pamieci \"treeInsert()\"\n%s\n", strerror(errno));
            exit(errno);
        }

        leaf->left = NULL;
        leaf->right = NULL;

        leaf->key = malloc(keyLength * sizeof(char));
        if (leaf->key == NULL) {
            fprintf(stderr, "Nie mozna przydzielic pamieci \"treeInsert()\" - key\n%s\n", strerror(errno));
            exit(errno);
        }

        leaf->value = malloc(valueLength * sizeof(char));
        if (leaf->value == NULL) {
            fprintf(stderr, "Nie mozna przydzielic pamieci \"treeInsert()\" - value\n%s\n", strerror(errno));
            exit(errno);
        }

        memcpy(leaf->key, key, keyLength);
        memcpy(leaf->value, value, valueLength);

        return leaf;

    }

    if (strcmp(tree->key, key) < 0) {
        tree->left = treeInsert(tree->left, key, value);
    } else {
        tree->right = treeInsert(tree->right, key, value);
    }

    return tree;

}

char *treeGetValue(struct tree *tree, char *key) {

    if (tree == NULL)
        return NULL;

    int cmp = strcmp(tree->key, key);

    if (cmp == 0)
        return tree->value;

    if (cmp < 0)
        return treeGetValue(tree->left, key);
    return treeGetValue(tree->right, key);
}

struct tree *treeFree(struct tree *tree) {
    if (tree->left)
        treeFree(tree->left);
    if (tree->right)
        treeFree(tree->right);
    free(tree->key);
    free(tree->value);
    free(tree);
    return NULL;
}

static void treePrintHelper(struct tree *tree, int length) {
    if (tree->right)
        treePrintHelper(tree->right, length);
    printf("Key: %-*s \t Value: %s\n", length, tree->key, tree->value);
    if (tree->left)
        treePrintHelper(tree->left, length);
}

static int treeGetMaxKeyLength(struct tree *tree) {
    int length = strlen(tree->key);
    int maxLengthRight = -1;
    int maxLengthLeft = -1;
    if (tree->right)
        maxLengthRight = treeGetMaxKeyLength(tree->right);
    if (tree->left)
        maxLengthLeft = treeGetMaxKeyLength(tree->left);

    if (maxLengthRight > maxLengthLeft) {
        if (length > maxLengthRight) {
            return length;
        }
        return maxLengthRight;
    } else {
        if (length > maxLengthLeft) {
            return length;
        }
        return maxLengthLeft;
    }
}

void treePrint(struct tree *tree) {
    treePrintHelper(tree, treeGetMaxKeyLength(tree));
}





