#include "codeGenerator.h"
#include <stdlib.h>

void start_void_function(FILE *r, char *name, function_t *func) {
    start_function(r, name, func, TYPE_VOID);
}

void start_function(FILE *r, char *name, function_t *func, variable_type return_type) {
	char *parameterPair;
	char *parameter;
    size_t i;
    char type[10];

    switch (return_type) {
        case TYPE_INT:
        case TYPE_BOOLEAN:
            fprintf(r, "int ");
            break;
        
        case TYPE_VOID:
            fprintf(r, "void ");
            break;
    }

	fprintf(r, "%s", name);

	/* copy = strdup(args); */

    fprintf(r, "(");
    for (i = 0; i < func->nbArguments; ++i) {
        if (func->arguments[i]->type == TYPE_INT || func->arguments[i]->type == TYPE_BOOLEAN) {
            strcpy(type, "int");
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

	/* fprintf(r, "(");
	if (copy != NULL) {
		while ((parameterPair = strsep(&copy, ","))) {
			while ((parameter = strsep(&parameterPair, " "))) {
				if (strcmp("entier", parameter) == 0 || strcmp("booleen", parameter) == 0 || strcmp("booléen", parameter) == 0) {
					fprintf(r, "int ");
				}

				if (parameterPair == NULL) {
					fprintf(r, "%s", parameter);
				}
			}

			if (copy != NULL) {
				fprintf(r, ", ");
			}
		}
	}

	fprintf(r, ") {\n"); */

	free(name);
	/* free(args); */  
}

void start_if(FILE *r, char *cmp1, char *operator, char *cmp2) {
    fprintf(r, "if (%s %s %s) {\n", cmp1, operator, cmp2);
}

void start_else(FILE *r) {
    fprintf(r, "else {\n");
}

void start_for(FILE *r, char *var, int from, int to) {
    fprintf(r, "for (%s = %d; %s <= %d; ++%s) {\n", var, from, var, to, var);
}

void start_for_step(FILE *r, char *var, int from, int to, int step) {
    /* Déclaration de la variable ? */
    fprintf(r, "for (%s = %d; %s <= %d; %s += %d) {\n", var, from, var, to, var, step);
}

void start_while(FILE *r, char *cmp1, char *operator, char *cmp2) {
    fprintf(r, "while (%s %s %s) {\n", cmp1, operator, cmp2);
}

void start_while_true(FILE *r) {
    fprintf(r, "while (1) {\n");
}

void start_main(FILE *r, char *name) {
    fprintf(r, "/******************\nAlgorithme %s\n******************/\n\nint main() {\n", name);
}

void instruction(FILE *r) {

}

void declaration(FILE *r, char *name, char *value) {
    fprintf(r, "%s = %s;\n", name, value);
}

void function_call(FILE *r, char *name, function_t *func) {
    int i;

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

void return_function(FILE *r) {
    fprintf(r, "return;\n");
}

void return_function_value(FILE *r, char *value) {
    fprintf(r, "return %s;\n", value);
}

void end_void_function(FILE *r) {
    fprintf(r, "}\n");
}

void end_function(FILE *r) {
    fprintf(r, "}\n");
}

void end_if(FILE *r) {
    fprintf(r, "}\n");
}

void end_else(FILE *r) {
    fprintf(r, "}\n");
}

void end_for(FILE *r) {
    fprintf(r, "}\n");
}

void end_while(FILE *r) {
    fprintf(r, "}\n");
}

void end_main(FILE *r) {
    fprintf(r, "}\n");
}