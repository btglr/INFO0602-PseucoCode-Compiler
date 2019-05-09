#include "hashTable.h"
#include <stdlib.h>
#include <string.h>

int hash(int k, int size) {
    return k % size;
}

void initializeHashTable(hash_table_t *ht, int size) {
    int i;

    ht->list = (list_t*) malloc(sizeof(list_t) * size);
    ht->tabSize = size;

    for(i = 0; i < size; ++i) {
        initializeList(&ht->list[i]);
    }
}

void destroyHashTable(hash_table_t *ht) {
    destroyList(ht->list);
    /* free(ht); */
}

void insertHashTable(hash_table_t *ht, cell_t *cell) {
    int nb = convertStringToInt(cell->name);
    int ind = hash(nb, ht->tabSize);

    insertList(&ht->list[ind], cell);
}

cell_t *findHashTable(hash_table_t *ht, char *mot) {
    int nb = convertStringToInt(mot);
    int ind = hash(nb, ht->tabSize);

    return findList(&ht->list[ind], mot);
}

void removeFromHashTable(hash_table_t *th, cell_t *cell) {
    int nb = convertStringToInt(cell->name);
    int ind = hash(nb, th->tabSize);

    removeList(&th->list[ind], cell);
}

int convertStringToInt(char *str) {
    size_t i;
    int total = 0;

    for (i = 0; i < strlen(str); ++i) {
        total += str[i];
    }

    return total;
}
