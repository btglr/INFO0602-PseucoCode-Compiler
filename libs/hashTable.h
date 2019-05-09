#ifndef TP3_TABLEHACHAGE_H
#define TP3_TABLEHACHAGE_H

#include "list.h"

typedef struct {
    list_t *list;
    int tabSize;
} hash_table_t;

int convertStringToInt(char *str);
int hash(int k, int size);
void initializeHashTable(hash_table_t*, int);
void destroyHashTable(hash_table_t*);
void insertHashTable(hash_table_t*, cell_t*);
cell_t* findHashTable(hash_table_t*, char*);
void removeFromHashTable(hash_table_t*, cell_t*);

#endif
