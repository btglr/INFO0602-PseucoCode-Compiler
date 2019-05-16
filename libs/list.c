#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "list.h"
#include <unistd.h>

void initializeList(list_t *list) {
    list->head = NULL;
}

void destroyList(list_t *list) {
    if(list != NULL) {
        cell_t *curr = list->head, *tmp;

        while(curr != NULL) {
            tmp = curr;
            curr = curr->next;

            destroyCell(tmp);
        }
    }
}

void insertList(list_t *list, cell_t *cell) {
    cell->next = list->head;
    cell->prev = NULL;

    if(list->head != NULL) {
        (list->head)->prev = cell;
    }

    list->head = cell;
}

cell_t *findList(list_t *list, char *name) {
    cell_t* curr = list->head;

    while(curr != NULL && strcmp(curr->name, name) != 0) {
        curr = curr->next;
    }

    return curr;
}

void removeList(list_t *list, cell_t *cell) {
    if(cell != NULL) {
        if(cell->prev != NULL)
            (cell->prev)->next = cell->next;
        else
            list->head = cell->next;

        if(cell->next != NULL)
            (cell->next)->prev = cell->prev;

        destroyCell(cell);
    }
}

