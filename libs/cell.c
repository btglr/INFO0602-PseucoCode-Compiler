#include "cell.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

void initializeCell(cell_t *cell, char *name, double value) {
    sprintf(cell->name, "%s", name);
    cell->value = value;
    cell->prev = NULL;
    cell->next = NULL;
}

void destroyCell(cell_t *cell) {
    free(cell);
}
