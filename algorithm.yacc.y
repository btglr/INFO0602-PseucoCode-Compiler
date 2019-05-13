%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "libs/hashTable.h"

FILE *r;

void yyerror(const char *erreurMsg);
void generate_function(char*, char*, char*);
void end_function();
void start_main();
void end_main();
int yylex();

hash_table_t table;

%}

%union {
	int integer;
	char type[64];
	char *variable;
	char *string;
}

%token BEGIN_ALGORITHM END BEGIN_FUNCTION BEGIN_PROCEDURE
%token<string> FOR WHILE IF ELSE WRITE_OUTPUT READ_INPUT DO THEN RETURN FROM TO STEP
%token<type> VARIABLE_TYPE
%token<string> COMPARISON_OPERATOR OPERATOR_DIVIDE OPERATOR_MINUS OPERATOR_MODULO OPERATOR_MULTIPLY OPERATOR_PLUS NOT
%token<integer> BOOLEAN INT
%token<variable> VARIABLE
%token<string> STRING
%type<integer> plus_minus
%type<integer> multiply_divide
%type<integer> number
%type<string> parameters
%type<string> argument

%%

program:
	function algorithm END {
		end_main();
		return EXIT_SUCCESS;
	}
	| ;

algorithm:
	BEGIN_ALGORITHM VARIABLE '\n' {
    	printf("\tStarted algorithm %s\n", $2);
		start_main();
	} expression
	;

function:
	BEGIN_FUNCTION VARIABLE parameters ':' VARIABLE_TYPE '\n' {
		/* Fonction Nom(type nomParam[, type nomParam]) : typeRetour */
		generate_function($2, $3, $5);
	} expression END {
		end_function();
	} '\n' function
	| BEGIN_PROCEDURE VARIABLE parameters '\n' {
		/* Procédure Nom(type nomParam[, type nomParam]) */
		generate_function($2, $3, "void");
	} expression END {
		end_function();
	} '\n' function
	| ;

parameters:
	'(' argument ')' {
		/* Correspond à un argument de fonction/procédure */

		if (($$ = strdup($2)) == NULL) {
			fprintf(stderr, "Erreur, mémoire insuffisante\n");
			exit(EXIT_FAILURE);
		}

		free($2);
	}
	| '(' STRING ')' {
		/* Correspond à un appel de fonction (Ex: Ecrire("test")) */

		if (($$ = strdup($2)) == NULL) {
			fprintf(stderr, "Erreur, mémoire insuffisante\n");
			exit(EXIT_FAILURE);
		}

		printf("String: %s\n", $$);
		free($2);
	}
	| '(' VARIABLE ')' {
		/*
		Correspond à un appel de fonction (Ex: Lire(a) ou Ecrire(a))
		Faire en sorte que ce soit possible d'appeler une fonction avec plusieurs arguments : pgcd(x, y)

		arguments: règle qui prend [soit un type et une variable, soit une variable], n fois

		*/

		if (($$ = strdup($2)) == NULL) {
			fprintf(stderr, "Erreur, mémoire insuffisante\n");
			exit(EXIT_FAILURE);
		}

		printf("Variable: %s\n", $$);
		free($2);
	}
	;

argument:
	VARIABLE_TYPE VARIABLE ',' argument {
		size_t length = strlen($1) + strlen($2) + strlen($4) + 4;

		if (($$ = (char*) malloc(sizeof(char) * length)) == NULL) {
			fprintf(stderr, "Erreur, mémoire insuffisante\n");
			exit(EXIT_FAILURE);
		}

		snprintf($$, length, "%s %s, %s", $1, $2, $4);
		printf("\t{Parameter: %s} : {Type: %s}\n", $2, $1);

		free($2);
		free($4);
	}
	| VARIABLE_TYPE VARIABLE {
		size_t length = strlen($1) + strlen($2) + 2;
		
		if (($$ = (char*) malloc(sizeof(char) * length)) == NULL) {
			fprintf(stderr, "Erreur, mémoire insuffisante\n");
			exit(EXIT_FAILURE);
		}

		snprintf($$, length, "%s %s", $1, $2);
		printf("\t{Parameter: %s} : {Type: %s}\n", $2, $1);

		free($2);
	}
	| {
		$$ = (char*) malloc(sizeof(char));
		strcpy($$, "");
	}
	;

expression:
	declaration '\n' expression
	| instruction '\n' expression
	| ;

declaration:
	VARIABLE '=' plus_minus {
		printf("Assigned int variable \"%s\" with value %d\n", $1, $3);

		cell_t *cell;

		if ((cell = findHashTable(&table, $1)) == NULL) {
			cell = (cell_t*) malloc(sizeof(cell_t));
			initializeCell(cell, $1, $3);
			insertHashTable(&table, cell);
		}

		else {
			cell->value = $3;
		}
	}
	| VARIABLE '=' BOOLEAN {
		printf("Assigned boolean variable \"%s\" with value %d\n", $1, $3);

		cell_t *cell;

		if ((cell = findHashTable(&table, $1)) == NULL) {
			cell = (cell_t*) malloc(sizeof(cell_t));
			initializeCell(cell, $1, $3);
			insertHashTable(&table, cell);
		}

		else {
			cell->value = $3;
		}

		/*
		Ajouter $$ = $3 pour l'assignation et comparaison ?
		Ex: (a = 2) == 0
		*/
	}
	;

instruction:
	WRITE_OUTPUT parameters {
		fprintf(r, "printf(%s);\n", $2);
	}
	| READ_INPUT '(' VARIABLE ')' {
		/* Si la variable n'est pas encore existante elle est ajoutée à la table de hachage et déclarée en C */
		if (findHashTable(&table, $3) == NULL) {
			cell_t *cell = (cell_t*) malloc(sizeof(cell_t));
			initializeCell(cell, $3, 0);
			insertHashTable(&table, cell);

			fprintf(r, "int %s;\n", $3);
		}

		/* Puis ensuite on effectue le scanf */
		fprintf(r, "scanf(\"%%d\", &%s);\n", $3);
	}
	| condition
	| loop
	| RETURN value
	| RETURN
	;

condition:
	IF VARIABLE COMPARISON_OPERATOR value THEN {

	} '\n' expression ELSE {

	} '\n' expression END IF
	| IF boolean_expression THEN {
		/* Equivalent à if(true), je sais pas si c'est nécessaire d'ajouter ça */

	} '\n' expression ELSE {

	} '\n' expression END IF
	;

loop:
	while_loop
	| for_loop
	;

while_loop:
	WHILE plus_minus COMPARISON_OPERATOR plus_minus DO {
		printf("\tDébut tant que avec opération\n");
	} '\n' expression END WHILE
	| WHILE boolean_expression DO {

	} '\n' expression END WHILE {

	}
	;

for_loop:
	FOR VARIABLE FROM INT TO INT DO {

	} '\n' expression END FOR
	| FOR VARIABLE FROM INT TO INT STEP INT DO {

	} '\n' expression END FOR
	;

value:
	VARIABLE
	| INT
	| boolean_expression
	;

boolean_expression:
	BOOLEAN
	| NOT BOOLEAN
	;

plus_minus:
	plus_minus OPERATOR_PLUS multiply_divide {
		$$ = $1 + $3;
	}
	| plus_minus OPERATOR_MINUS multiply_divide {
		$$ = $1 - $3;
	}
	| multiply_divide
	;

multiply_divide:
	multiply_divide OPERATOR_DIVIDE number {
		if ($3 == 0) {
			yyerror("Division par zero");
		}
		else {
			$$ = $1 / $3;
		}
	}
	| multiply_divide OPERATOR_MULTIPLY number {
		$$ = $1 * $3;
	}
	| multiply_divide OPERATOR_MODULO number {
		if ($3 == 0) {
			yyerror("Division par zero via modulo");
		}
		else {
			$$ = $1 % $3;
		}
	}
	| number
	;

number:
	'(' plus_minus ')' {
		$$ = $2;
	}
	| OPERATOR_MINUS INT {
		$$ = -$2;
	}
	| INT {
		$$ = $1;
	}
	| VARIABLE {
		cell_t *cell;

		if ((cell = findHashTable(&table, $1)) == NULL) {
			yyerror("Variable inexistante");
		}

		else {
			$$ = cell->value;
		}
	}
	;

%%

int main(void) {
	initializeHashTable(&table, 256);

	r = fopen("result.c", "w");
	yyparse();

	fclose(r);
	destroyHashTable(&table);

  	return EXIT_SUCCESS;
}

void generate_function(char *name, char *args, char *return_type) {
	char *copy;
	char *parameterCouple;
	char *parameter;

	if (strcmp("entier", return_type) == 0 || strcmp("booleen", return_type) == 0 || strcmp("booléen", return_type) == 0) {
		fprintf(r, "int ");
	}

	else {
		fprintf(r, "void ");
	}

	fprintf(r, "%s", name);

	copy = strdup(args);

	fprintf(r, "(");
	if (copy != NULL) {
		while ((parameterCouple = strsep(&copy, ","))) {
			while ((parameter = strsep(&parameterCouple, " "))) {
				if (strcmp("entier", parameter) == 0 || strcmp("booleen", parameter) == 0 || strcmp("booléen", parameter) == 0) {
					fprintf(r, "int ");
				}

				if (parameterCouple == NULL) {
					fprintf(r, "%s", parameter);
				}
			}

			if (copy != NULL) {
				fprintf(r, ", ");
			}
		}
	}

	fprintf(r, ") {\n");

	free(name);
	free(args);
	free(copy);
}

void start_main() {
	fprintf(r, "int main() {\n");
}

void end_main() {
	fprintf(r, "}\n");
}

void end_function() {
	fprintf(r, "}\n");
}