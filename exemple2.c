#include <stdio.h>
#include <stdlib.h>

int PGCD(int i, int j) {
	int a;
	a = i;
	int b;
	b = j;
	while (b != 0) {
		int tmp;
		tmp = a;
		a = b;
		b = tmp % b;
	}
	return a;
}

/******************
Algorithme CalculPGCD
******************/

int main() {
	printf("Saisissez un entier : ");
	int i;
	scanf("%d", &i);
	printf("Saisissez un autre entier : ");
	int j;
	scanf("%d", &j);
	printf("Le PGCD de %d et %d", i, j);
	printf(" = %d\n", PGCD(i, j));
	return 1;
}