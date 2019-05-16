#include "hashTable.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

int hash(int k, int size) {
    return k % size;
}

void initializeHashTable(hashTable_t *ht, char* name, int size) {
    int i;

    ht->name = strdup(name);
    ht->list = (list_t*) malloc(sizeof(list_t) * size);
    ht->tabSize = size;
    ht->prev = NULL;
    ht->next = NULL;

    for(i = 0; i < size; ++i) {
        initializeList(&ht->list[i]);
    }
}

void destroyHashTable(hashTable_t *ht) {
    size_t i;

    if (ht != NULL) {
        free(ht->name);

        for (i = 0; i < ht->tabSize; ++i) {
            destroyList(&ht->list[i]);
        }

        free(ht->list);
        free(ht);
    }
}

void insertHashTable(hashTable_t *ht, cell_t *cell) {
    int nb = convertStringToInt(cell->name);
    int ind = hash(nb, ht->tabSize);

    insertList(&ht->list[ind], cell);
}

cell_t *findHashTable(hashTable_t *ht, char *mot) {
    int nb = convertStringToInt(mot);
    int ind = hash(nb, ht->tabSize);

    return findList(&ht->list[ind], mot);
}

void removeFromHashTable(hashTable_t *th, cell_t *cell) {
    int nb = convertStringToInt(cell->name);
    int ind = hash(nb, th->tabSize);

    removeList(&th->list[ind], cell);
}

int convertStringToInt(char *str) {
    size_t i;
    size_t length;
    int total = 0;

    length = strlen(str);

    for (i = 0; i < length; ++i) {
        total += str[i];
    }

    return total;
}
