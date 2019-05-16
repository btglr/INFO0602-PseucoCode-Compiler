#include "cell.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "memoryUtils.h"

void initializeCell(cell_t *cell, char *name, variable_type type) {
    if ((cell->name = strdup(name)) == NULL) {
        fprintf(stderr, "Erreur: mémoire insuffisante\n");
        exit(EXIT_FAILURE);
    }

    cell->type = type;
    cell->prev = NULL;
    cell->next = NULL;
}

void destroyCell(cell_t *cell) {
    free(cell->name);
    free(cell);
}