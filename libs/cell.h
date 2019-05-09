#ifndef TP3_CELLULE_H
#define TP3_CELLULE_H

typedef struct cell {
    char name[256];
    double value;
    struct cell *prev, *next;
} cell_t;

void initializeCell(cell_t*, char*, double);
void destroyCell(cell_t*);

#endif
