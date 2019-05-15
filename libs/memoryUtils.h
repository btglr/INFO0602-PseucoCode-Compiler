#ifndef PROJET3_MEMORY_UTILS_H
#define PROJET3_MEMORY_UTILS_H

#include <stdlib.h>

void *malloc_check(size_t length);
void *realloc_check(void *var, size_t length);

#endif