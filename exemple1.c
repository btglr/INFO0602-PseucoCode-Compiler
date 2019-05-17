#include <stdio.h>
#include <stdlib.h>

#define bool int
#define true 1
#define false 0

void pair(int i) {
	printf("%d est pair", i);
	return;
}
void impair(int i) {
	printf("%d est impair", i);
	return;
}

/******************
Algorithme Exemple
******************/

int main() {
	int i;
	for (i = 1; i <= 10; ++i) {
		printf("Tapez votre entier : ");
		int j;
		scanf("%d", &j);
		if (j % 2 == 0) {
			pair(j);
			printf("\n");
		}
		else {
			impair(j);
			printf("\n");
		}
	}
	return 1;
}