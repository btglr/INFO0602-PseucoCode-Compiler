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

char* getVariableType(variable_type type) {
    switch (type) {
        case TYPE_BOOLEAN:
        case TYPE_INT:
            return "int";
    }
}

variable_type charToVariableType(char *type) {
    variable_type rtype;

    if (strcmp(type, "entier") == 0) {
        rtype = TYPE_INT;
    }

    else if (strcmp(type, "booléen") == 0) {

    }
}