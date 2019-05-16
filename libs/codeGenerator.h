#ifndef CODEGENERATOR_H
#define CODEGENERATOR_H

#include "cell.h"
#include "hashTable.h"
#include "queue.h"
#include <stdio.h>
#include <string.h>

void include_librairies(FILE *r);

void start_void_function(FILE *r, char *name, function_t *func);
void start_function(FILE *r, char *name, function_t *func, variable_type return_type);
void start_if(FILE *r, int level, char *cmp1, char *operator, char *cmp2);
void start_else(FILE *r, int level);
void start_for(FILE *r, int level, char *var, int from, int to);
void start_for_step(FILE *r, int level, char *var, int from, int to, int step);
void start_while(FILE *r, int level, char *cmp1, char *operator, char *cmp2);
void start_while_true(FILE *r, int level);
void start_main(FILE *r, char *name);

void declaration(FILE *r, int level, char *name, char *value);
void function_call(FILE *r, int level, char *name, function_t *func);
void function_scanf(FILE *r, int level, char *name);
void function_printf(FILE *r, int level, char *format, queue_t *values);
void return_function(FILE *r, int level);
void return_function_value(FILE *r, int level, char *value);

void generate_declaration(FILE *r, int level, char *name, variable_type type);

void end_void_function(FILE *r);
void end_function(FILE *r);
void end_if(FILE *r, int level);
void end_else(FILE *r, int level);
void end_for(FILE *r, int level);
void end_while(FILE *r, int level);
void end_main(FILE *r, int level);

void print_tabs(FILE *r, int nb);

#endif