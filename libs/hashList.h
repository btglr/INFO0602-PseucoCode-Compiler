#ifndef HASHLIST_H
#define HASHLIST_H

#include "hashTable.h"

typedef struct {
    hashTable_t *head;
} hashList_t;

void initializeHashList(hashList_t*);
void destroyHashList(hashList_t*);
void insertHashList(hashList_t*, hashTable_t*);
hashTable_t* findHashList(hashList_t*, char*);

#endif