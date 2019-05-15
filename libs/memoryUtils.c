#include <stdio.h>
#include "memoryUtils.h"

void *malloc_check(size_t length) {
    void *var;

    if ((var = malloc(length)) == NULL) {
        fprintf(stderr, "Erreur: mémoire insuffisante\n");
        exit(EXIT_FAILURE);
    }

    return var;
}

void *realloc_check(void *var, size_t length) {
	if ((var = realloc(var, length)) == NULL) {
		fprintf(stderr, "Erreur: mémoire insuffisante\n");
        exit(EXIT_FAILURE);
	}

	return var;
}