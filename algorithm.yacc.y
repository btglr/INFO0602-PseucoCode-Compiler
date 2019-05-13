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
	char string[256];
	char variable[256];
	char output[512];
}

%token<output> BEGIN_ALGORITHM END BEGIN_FUNCTION BEGIN_PROCEDURE
%token<string> FOR WHILE IF ELSE WRITE_OUTPUT READ_INPUT DO THEN RETURN FROM TO STEP
%token<string> VARIABLE_TYPE
%token<string> COMPARISON_OPERATOR OPERATION_OPERATOR ASSIGNMENT_OPERATOR OPERATOR_DIVIDE OPERATOR_MINUS OPERATOR_MODULO OPERATOR_MULTIPLY OPERATOR_PLUS
%token<string> OPENING_PARENTHESIS CLOSING_PARENTHESIS
%token<integer> BOOLEAN INT
%token<variable> VARIABLE
%token<output> STRING
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
	BEGIN_FUNCTION VARIABLE parameters
 ':' VARIABLE_TYPE '\n' {
		/* Fonction Nom(type nomParam[, type nomParam]) : typeRetour */
		generate_function($2, $3, $5);
	} expression END {
		end_function();
	} '\n' function
	| BEGIN_PROCEDURE VARIABLE parameters
 '\n' {
		/* Procédure Nom(type nomParam[, type nomParam]) */
		generate_function($2, $3, "void");
	} expression END {
		end_function();
	} '\n' function
	| ;

parameters:
	OPENING_PARENTHESIS argument CLOSING_PARENTHESIS {
		/* Correspond à un argument de fonction/procédure */
		snprintf($$, sizeof($$), "%s", $2);
		/* $$ = $2; */
	}
	| OPENING_PARENTHESIS STRING CLOSING_PARENTHESIS {
		strcpy($$, $2);
		/* Correspond à un appel de fonction (Ex: Ecrire("test")) */
	}
	| OPENING_PARENTHESIS VARIABLE CLOSING_PARENTHESIS {
		strcpy($$, $2);
		/*
		Correspond à un appel de fonction (Ex: Lire(a) ou Ecrire(a))
		Faire en sorte que ce soit possible d'appeler une fonction avec plusieurs arguments : pgcd(x, y)
		*/
	}
	;

argument:
	VARIABLE_TYPE VARIABLE ',' argument {
		snprintf($$, sizeof($$), "%s %s, %s", $1, $2, $4);
		printf("\t{Parameter: %s} : {Type: %s}\n", $2, $1);
	}
	| VARIABLE_TYPE VARIABLE {
		snprintf($$, sizeof($$), "%s %s", $1, $2);
		printf("\t{Parameter: %s} : {Type: %s}\n", $2, $1);
	}
	| {
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
	}
	;

instruction:
	WRITE_OUTPUT parameters
 {
		fprintf(r, "printf(%s);\n", $2);
	}
	| READ_INPUT parameters
 {
		fprintf(r, "scanf(\"%%d\", \&%s);\n", $2);
	}
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
		$$ = $1 % $3;
	}
	| number
	;

number:
	OPENING_PARENTHESIS plus_minus CLOSING_PARENTHESIS {
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
			printf("Erreur: variable inexistante\n");
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