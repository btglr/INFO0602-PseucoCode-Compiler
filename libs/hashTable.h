#ifndef TP3_TABLEHACHAGE_H
#define TP3_TABLEHACHAGE_H

#include "list.h"

typedef struct hashTable {
    char *name;
    list_t *list;
    int tabSize;
    function_t *function;
    variable_type returnType;

    struct hashTable *prev, *next;
} hashTable_t;

int convertStringToInt(char *str);
int hash(int k, int size);
void initializeHashTable(hashTable_t*, char*, int);
void destroyHashTable(hashTable_t*);
void insertHashTable(hashTable_t*, cell_t*);
cell_t* findHashTable(hashTable_t*, char*);
void removeFromHashTable(hashTable_t*, cell_t*);

#endif
