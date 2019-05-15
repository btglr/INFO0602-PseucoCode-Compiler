#ifndef TP9_QUEUE_H
#define TP9_QUEUE_H

#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include "cell.h"

typedef struct {
    char *name;
    variable_type type;
} variable_t;

typedef struct queue {
    int front, rear, size;
    unsigned capacity;
    variable_t** variables;
} queue_t;

queue_t* createQueue(unsigned capacity);
int isFull(queue_t* queue);
int isEmpty(queue_t* queue);
void enqueue(queue_t *queue, variable_t *item);
variable_t * dequeue(queue_t *queue);
variable_t * front(queue_t *queue);
variable_t * rear(queue_t *queue);
void destroyQueue(queue_t* queue);

#endif
