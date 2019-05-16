#ifndef TP3_CELLULE_H
#define TP3_CELLULE_H

typedef enum {
    TYPE_BOOLEAN = 0,
    TYPE_INT,
    TYPE_VOID
} variable_type;

typedef struct {
    variable_type type;
    char *name;
} argument_t;

typedef struct {
    int nbArguments;
    argument_t **arguments;
} function_t;

typedef struct cell {
    char *name;
    variable_type type;
    struct cell *prev, *next;
} cell_t;

void initializeCell(cell_t*, char*, variable_type);
void destroyCell(cell_t*);
void destroyFunction(function_t*);

#endif
