#include <string.h>
#include "memoryUtils.h"
#include "queue.h"

queue_t *createQueue(unsigned capacity) {
    queue_t *queue = (queue_t *) malloc_check(sizeof(queue_t));
    queue->capacity = capacity;
    queue->front = queue->size = 0;
    queue->rear = capacity - 1;
    queue->variables = (variable_t**) malloc_check(queue->capacity * sizeof(variable_t*));

    return queue;
}

void destroyQueue(queue_t *queue) {
    variable_t *elem;

    while (!isEmpty(queue)) {
        elem = dequeue(queue);
        free(elem->name);
        free(elem);
    }

    free(queue->variables);
    free(queue);
}

int isFull(queue_t *queue) {
    return (queue->size == queue->capacity);
}

int isEmpty(queue_t *queue) {
    return (queue->size == 0);
}

void enqueue(queue_t *queue, variable_t *item) {
    if (isFull(queue))
        return;

    queue->rear = (queue->rear + 1) % queue->capacity;

    queue->variables[queue->rear] = item;
    queue->size = queue->size + 1;
}

variable_t * dequeue(queue_t *queue) {
    variable_t *item;

    if (isEmpty(queue))
        return NULL;

    item = queue->variables[queue->front];
    queue->front = (queue->front + 1) % queue->capacity;
    queue->size = queue->size - 1;

    return item;
}

variable_t * front(queue_t *queue) {
    if (isEmpty(queue))
        return NULL;

    return queue->variables[queue->front];
}

variable_t * rear(queue_t *queue) {
    if (isEmpty(queue))
        return NULL;

    return queue->variables[queue->rear];
}
