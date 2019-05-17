#include "codeGenerator.h"
#include <stdlib.h>

void include_librairies(FILE *r) {
    fprintf(r, "#include <stdio.h>\n");
    fprintf(r, "#include <stdlib.h>\n\n");

    fprintf(r, "#define bool int\n");
    fprintf(r, "#define true 1\n");
    fprintf(r, "#define false 0\n\n");
}

void start_void_function(FILE *r, char *name, function_t *func) {
    start_function(r, name, func, TYPE_VOID);
}

void start_function(FILE *r, char *name, function_t *func, variable_type return_type) {
    size_t i;
    char type[10];

    switch (return_type) {
        case TYPE_INT:
            fprintf(r, "int ");
            break;

        case TYPE_BOOLEAN:
            fprintf(r, "bool ");
            break;
        
        case TYPE_VOID:
            fprintf(r, "void ");
            break;
    }

    fprintf(r, "%s(", name);
    for (i = 0; i < func->nbArguments; ++i) {
        if (func->arguments[i]->type == TYPE_INT) {
            strcpy(type, "int");
        }

        else if (func->arguments[i]->type == TYPE_BOOLEAN) {
            strcpy(type, "bool");
        }

        else {
            fprintf(stderr, "Type inconnu\n");
            exit(EXIT_FAILURE);
        }

        if (i < func->nbArguments - 1) {
            fprintf(r, "%s %s, ", type, func->arguments[i]->name);
        }
        else {
            fprintf(r, "%s %s", type, func->arguments[i]->name);
        }
    }
    fprintf(r, ") {\n");
}

void start_if(FILE *r, int level, char *cmp1, char *operator, char *cmp2) {
    print_tabs(r, level);
    fprintf(r, "if (%s %s %s) {\n", cmp1, operator, cmp2);
}

void start_else(FILE *r, int level) {
    print_tabs(r, level);
    fprintf(r, "else {\n");
}

void start_for(FILE *r, int level, char *var, int from, int to) {
    print_tabs(r, level);
    fprintf(r, "for (%s = %d; %s <= %d; ++%s) {\n", var, from, var, to, var);
}

void start_for_step(FILE *r, int level, char *var, int from, int to, int step) {
    print_tabs(r, level);
    fprintf(r, "for (%s = %d; %s <= %d; %s += %d) {\n", var, from, var, to, var, step);
}

void start_while(FILE *r, int level, char *cmp1, char *operator, char *cmp2) {
    print_tabs(r, level);
    fprintf(r, "while (%s %s %s) {\n", cmp1, operator, cmp2);
}

void start_while_true(FILE *r, int level, char *cond) {
    print_tabs(r, level);
    fprintf(r, "while (%s) {\n", cond);
}

void start_main(FILE *r, char *name) {
    fprintf(r, "\n/******************\nAlgorithme %s\n******************/\n\nint main() {\n", name);
}

void declaration(FILE *r, int level, char *name, char *value) {
    print_tabs(r, level);
    fprintf(r, "%s = %s;\n", name, value);
}

void function_call(FILE *r, int level, char *name, function_t *func) {
    int i;

    print_tabs(r, level);
    fprintf(r, "%s(", name);

    for (i = 0; i < func->nbArguments; ++i) {
        if (i < func->nbArguments - 1) {
            fprintf(r, "%s, ", func->arguments[i]->name);
        }
        else {
            fprintf(r, "%s", func->arguments[i]->name);
        }
    }

    fprintf(r, ");\n");
}

void function_scanf(FILE *r, int level, char *name) {
    print_tabs(r, level);
    fprintf(r, "scanf(\"%%d\", &%s);\n", name);
}

void function_printf(FILE *r, int level, char *format, queue_t *values) {
    print_tabs(r, level);

    if (!isEmpty(values)) {
        fprintf(r, "printf(\"%s\", ", format);
    }

    else {
        fprintf(r, "printf(\"%s\"", format);
    }

    while (!isEmpty(values)) {
        variable_t *v = dequeue(values);

        /* Si vide on ne met pas de virgule */
        if (isEmpty(values)) {
            fprintf(r, "%s", v->name);
        }
        else {
            fprintf(r, "%s, ", v->name);
        }

        free(v->name);
        free(v);
    }

    fprintf(r, ");\n");
}

void return_function(FILE *r, int level) {
    print_tabs(r, level);
    fprintf(r, "return;\n");
}

void return_function_value(FILE *r, int level, char *value) {
    print_tabs(r, level);
    fprintf(r, "return %s;\n", value);
}

void generate_declaration(FILE *r, int level, char *name, variable_type type) {
    print_tabs(r, level);
    switch (type) {
        case TYPE_BOOLEAN:
            fprintf(r, "/* Booléen */\n");
            print_tabs(r, level);

        case TYPE_INT:
            fprintf(r, "int ");
            break;

        default:
            fprintf(stderr, "Erreur: type inconnu\n");
            exit(EXIT_FAILURE);
    }

    fprintf(r, "%s;\n", name);
}

void end_void_function(FILE *r) {
    fprintf(r, "}\n");
}

void end_function(FILE *r) {
    fprintf(r, "}\n");
}

void end_if(FILE *r, int level) {
    print_tabs(r, level);
    fprintf(r, "}\n");
}

void end_else(FILE *r, int level) {
    print_tabs(r, level);
    fprintf(r, "}\n");
}

void end_for(FILE *r, int level) {
    print_tabs(r, level);
    fprintf(r, "}\n");
}

void end_while(FILE *r, int level) {
    print_tabs(r, level);
    fprintf(r, "}\n");
}

void end_main(FILE *r, int level) {
    print_tabs(r, level);
    fprintf(r, "return 1;\n");
    fprintf(r, "}");
}

void print_tabs(FILE *r, int nb) {
    int i;

    for (i = 0; i < nb; ++i) {
        fprintf(r, "\t");
    }
}