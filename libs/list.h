#ifndef TP3_LISTE_H
#define TP3_LISTE_H

#include "cell.h"

typedef struct {
    cell_t *head;
} list_t;

void initializeList(list_t*);
void destroyList(list_t*);
void insertList(list_t*, cell_t*);
cell_t* findList(list_t*, char*);
void removeList(list_t*, cell_t*);

#endif
