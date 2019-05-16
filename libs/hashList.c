#include "hashList.h"
#include <stdlib.h>
#include <string.h>

void initializeHashList(hashList_t *list) {
    list->head = NULL;
}

void destroyHashList(hashList_t *list) {
    if(list != NULL) {
        hashTable_t *curr = list->head, *tmp;

        while(curr != NULL) {
            tmp = curr;
            curr = curr->next;
            destroyHashTable(tmp);
        }

        free(list);
    }
}

void insertHashList(hashList_t *list, hashTable_t *table) {
    table->next = list->head;
    table->prev = NULL;

    if(list->head != NULL) {
        (list->head)->prev = table;
    }

    list->head = table;
}

hashTable_t *findHashList(hashList_t *list, char *name) {
    hashTable_t* curr = list->head;

    while(curr != NULL && strcmp(curr->name, name) != 0) {
        curr = curr->next;
    }

    return curr;
}