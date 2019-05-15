#ifndef CODEGENERATOR_H
#define CODEGENERATOR_H

#include "cell.h"
#include <stdio.h>
#include <string.h>

void start_void_function(FILE *r, char *name, function_t *func);
void start_function(FILE *r, char *name, function_t *func, variable_type return_type);
void start_if(FILE *r, char *cmp1, char *operator, char *cmp2);
void start_else(FILE *r);
void start_for(FILE *r, char *var, int from, int to);
void start_for_step(FILE *r, char *var, int from, int to, int step);
void start_while(FILE *r, char *cmp1, char *operator, char *cmp2);
void start_while_true(FILE *r);
void start_main(FILE *r, char *name);

void instruction(FILE *r);
void declaration(FILE *r, char *name, char *value);
void function_call(FILE *r, char *name, function_t *func);
void return_function(FILE *r);
void return_function_value(FILE *r, char *value);

void end_void_function(FILE *r);
void end_function(FILE *r);
void end_if(FILE *r);
void end_else(FILE *r);
void end_for(FILE *r);
void end_while(FILE *r);
void end_main(FILE *r);

#endif