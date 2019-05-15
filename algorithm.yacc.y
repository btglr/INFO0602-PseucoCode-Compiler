%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "libs/hashTable.h"
#include "libs/memoryUtils.h"
#include "libs/queue.h"
#include "libs/hashList.h"
#include "libs/codeGenerator.h"

#define YYDEBUG 0

FILE *r;

void yyerror(const char *erreurMsg);
int isVariableCreated(hashTable_t *table, char *variable);
int isFunctionCreated(hashList_t *liste, char *function);
int yylex();

hashList_t *hashList;
hashTable_t *mainTable;
hashTable_t *currentTable;
queue_t *queue;
function_t *func;

%}

%union {
	int integer;
	char *variable;
	char *string;
	variable_type vtype;
}

%token BEGIN_ALGORITHM END BEGIN_FUNCTION BEGIN_PROCEDURE
%token<string> FOR WHILE IF ELSE WRITE_OUTPUT READ_INPUT DO THEN RETURN FROM TO STEP
%token<vtype> VARIABLE_TYPE
%token<string> COMPARISON_OPERATOR
%token<string> BOOLEAN INT
%token<variable> VARIABLE
%token<string> STRING
%type<string> plus_minus
%type<string> multiply_divide
%type<string> number
%type<string> write
%type<string> full_string
%type<string> var_or_string
%type<string> value
%type<string> boolean_expression

%%

program:
	function algorithm END {
		end_main(r);
		return EXIT_SUCCESS;
	}
	| ;

algorithm:
	BEGIN_ALGORITHM VARIABLE '\n' {
		mainTable = (hashTable_t*) malloc(sizeof(hashTable_t));

		/* Insertion de la table main */
		initializeHashTable(mainTable, $2, 256);
		insertHashList(hashList, mainTable);

    	printf("\tStarted algorithm %s\n", $2);
		start_main(r, mainTable->name);

		currentTable = mainTable;

		free($2);
	} expression
	;

function:
	BEGIN_FUNCTION VARIABLE {
		if (isFunctionCreated(hashList, $2)) {
			yyerror("Fonction deja existante");
		}

		hashTable_t *funcTable = (hashTable_t*) malloc(sizeof(hashTable_t));

		/* Insertion de la table main */
		initializeHashTable(funcTable, $2, 256);
		insertHashList(hashList, funcTable);

		currentTable = funcTable;

		func = (function_t*) malloc(sizeof(function_t));
		func->nbArguments = 0;
	} '(' function_definition_arguments ')' ':' VARIABLE_TYPE '\n' {
		/* Fonction Nom(type nomParam[, type nomParam]) : typeRetour */
		start_function(r, $2, func, $8);
	} expression END {
		end_function(r);
		free($2);
		free(func);
	} '\n' function
	| BEGIN_PROCEDURE VARIABLE {
		if (isFunctionCreated(hashList, $2)) {
			yyerror("Fonction deja existante");
		}

		hashTable_t *funcTable = (hashTable_t*) malloc(sizeof(hashTable_t));

		/* Insertion de la table main */
		initializeHashTable(funcTable, $2, 256);
		insertHashList(hashList, funcTable);

		currentTable = funcTable;

		func = (function_t*) malloc(sizeof(function_t));
		func->nbArguments = 0;
		func->arguments = (argument_t**) malloc(sizeof(argument_t*));
	} '(' function_definition_arguments ')' '\n' {
		/* Procédure Nom(type nomParam[, type nomParam]) */
		start_void_function(r, $2, func);
	} expression END {
		end_function(r);
		free($2);
		free(func);
	} '\n' function
	| '\n' function
	| ;

function_call:
	read
	| write
	| VARIABLE {
		func = (function_t*) malloc(sizeof(function_t));
		func->nbArguments = 0;
	} '(' function_call_arguments ')' {
		if (!isFunctionCreated(hashList, $1)) {
			yyerror("Fonction inconnue");
		}

		function_call(r, $1, func);

		free($1);
		free(func);
	}
	;

function_definition_arguments:
	function_definition_arguments ',' arguments
	| arguments
	;

arguments:
	VARIABLE_TYPE VARIABLE {
		if (isVariableCreated(currentTable, $2)) {
			yyerror("Variable déjà existante dans la définition de fonction");
		}

		cell_t *cell = (cell_t*) malloc(sizeof(cell_t));
		initializeCell(cell, $2, $1);
		insertHashTable(currentTable, cell);
		
		func->nbArguments += 1;
		func->arguments = realloc(func->arguments, sizeof(argument_t*) * func->nbArguments);

		argument_t *arg = (argument_t*) malloc(sizeof(argument_t));
		arg->type = $1;
		arg->name = strdup($2);

		func->arguments[func->nbArguments - 1] = arg;

		free($2);
	}
	| ;

function_call_arguments:
	function_call_arguments ',' arguments_without_types
	| arguments_without_types
	;

arguments_without_types:
	plus_minus {
		func->nbArguments += 1;
		func->arguments = realloc(func->arguments, sizeof(argument_t*) * func->nbArguments);

		argument_t *arg = (argument_t*) malloc(sizeof(argument_t));
		arg->type = TYPE_VOID;
		arg->name = strdup($1);

		func->arguments[func->nbArguments - 1] = arg;

		free($1);
	}
	| ;

read:
	READ_INPUT '(' VARIABLE ')' {
		/* Si la variable n'est pas encore existante elle est ajoutée à la table de hachage et déclarée en C */
		if (!isVariableCreated(currentTable, $3)) {
			cell_t *cell = (cell_t*) malloc(sizeof(cell_t));
			initializeCell(cell, $3, TYPE_INT);
			insertHashTable(currentTable, cell);

			/* Trouver la ligne de déclaration et ajouter toutes les variables de la table des symboles juste après ? */
			fprintf(r, "int %s;\n", $3);
		}

		/* Puis ensuite on effectue le scanf */
		fprintf(r, "scanf(\"%%d\", &%s);\n", $3);
	}
	;

write:
	WRITE_OUTPUT '(' full_string ')' {
		if (!isEmpty(queue)) {
			fprintf(r, "printf(\"%s\", ", $3);
		}

		else {
			fprintf(r, "printf(\"%s\"", $3);
		}

		while (!isEmpty(queue)) {
			variable_t *v = dequeue(queue);

			/* Si vide on ne met pas de virgule */
			if (isEmpty(queue)) {
				fprintf(r, "%s", v->name);
			}
			else {
				fprintf(r, "%s, ", v->name);
			}
		}

		fprintf(r, ");\n");
	}
	;

full_string:
	full_string '+' var_or_string {
		/* printf("%s %s\n", $1, $$); */

		size_t length = strlen($1) + strlen($3) + 1;
		$$ = malloc_check(sizeof(char) * length);

		snprintf($$, length, "%s%s", $1, $3);
	}
	| var_or_string
	;

var_or_string:
	VARIABLE {
		func = (function_t*) malloc(sizeof(function_t));
		func->nbArguments = 0;
	} '(' function_call_arguments ')' {
		int i;

		if (!isFunctionCreated(hashList, $1)) {
			yyerror("Fonction inconnue");
		}

		/* Ajouter la fonction à la pile */
		variable_t *v = (variable_t*) malloc(sizeof(variable_t));
		
		size_t argLength = 0;

		for (i = 0; i < func->nbArguments; ++i) {
			/* + 2 pour la virgule et l'espace */
			argLength += strlen(func->arguments[i]->name) + 2;
		}
		/* -2 pour supprimer la dernière virgule et le dernier espace, +1 pour le \0 */
		argLength -= 1;

		char *argBuffer = (char*) malloc(sizeof(char) * argLength);

		for (i = 0; i < func->nbArguments; ++i) {
			if (i < func->nbArguments - 1) {
				snprintf(argBuffer + strlen(argBuffer), argLength, "%s, ", func->arguments[i]->name);
			}
			else {
				snprintf(argBuffer + strlen(argBuffer), argLength, "%s", func->arguments[i]->name);
			}
		}

		size_t length = argLength + strlen($1) + 3;
		v->name = malloc(sizeof(char) * length);
		snprintf(v->name, length, "%s(%s)", $1, argBuffer);
		v->type = TYPE_INT;

		enqueue(queue, v);
	} {
		printf("Appel de fonction dans ecrire\n");
	}
	| VARIABLE {
		cell_t *cell;

		if ((cell = findHashTable(currentTable, $1)) == NULL) {
			yyerror("Variable inexistante");
		}

		size_t length = strlen("%d") + 1;

		$$ = malloc_check(sizeof(char) * length);

		snprintf($$, length, "%s", "%d");

		/* Ajouter la variable à une pile */
		variable_t *v = (variable_t*) malloc(sizeof(variable_t));
		v->name = strdup($1);
		v->type = TYPE_INT;

		enqueue(queue, v);
	}
	| STRING {
		char *var;
		var = strdup($1);

		size_t length = strlen(var);

		if (length > 2) {
			var++;
			var[length - 2] = '\0';
			length = strlen(var) + 1;

			$$ = (char*) malloc_check(sizeof(char) * length);
			snprintf($$, length, "%s", var);
		}

		else {
			var = realloc_check(var, sizeof(char) * 2);

			var[0] = ' ';
			var[1] = '\0';
		}

		/* printf("%s", var); */
	}
	;

expression:
	declaration '\n' expression
	| instruction '\n' expression
	| '\n' expression
	| ;

declaration:
	VARIABLE '=' plus_minus {
		cell_t *cell;

		if ((cell = findHashTable(currentTable, $1)) == NULL) {
			cell = (cell_t*) malloc(sizeof(cell_t));
			initializeCell(cell, $1, TYPE_INT);
			insertHashTable(currentTable, cell);
		}

		/* Déclaration de toutes les variables de la table des symboles au début de chaque fonction */
		fprintf(r, "int %s;\n", $1);

		declaration(r, $1, $3);
	}
	| VARIABLE '=' BOOLEAN {
		cell_t *cell;

		if ((cell = findHashTable(currentTable, $1)) == NULL) {
			cell = (cell_t*) malloc(sizeof(cell_t));
			initializeCell(cell, $1, TYPE_BOOLEAN);
			insertHashTable(currentTable, cell);
		}

		fprintf(r, "int %s;\n/* Booléen */\n", $1);
		declaration(r, $1, $3);

		/* else {
			cell->value = $3;
		} */

		/* Pas besoin des valeurs, juste de savoir si la variable est déclarée */
		/*
		Ajouter $$ = $3 pour l'assignation et comparaison ?
		Ex: (a = 2) == 0
		*/
	}
	;

instruction:
	condition
	| function_call
	| loop
	| RETURN value {
		return_function_value(r, $2);

		free($2);
	}
	| RETURN {
		return_function(r);
	}
	;

condition:
	IF plus_minus COMPARISON_OPERATOR value THEN {
		printf("Test1: %s\n", $2);
		printf("Test1: %s\n", $3);

		start_if(r, $2, $3, $4);

		free($2);
		free($4);
	} '\n' expression else_cond END IF {
		end_if(r);
	}
	| IF boolean_expression THEN {
		/* Equivalent à if(true), je sais pas si c'est nécessaire d'ajouter ça */

	} '\n' expression else_cond END IF {
		
	}
	;

else_cond:
	ELSE {
		end_if(r);
		start_else(r);
	} '\n' expression
	| ;

loop:
	while_loop
	| for_loop
	;

while_loop:
	WHILE plus_minus COMPARISON_OPERATOR plus_minus DO {
		start_while(r, $2, $3, $4);

		free($2);
		free($4);
	} '\n' expression END WHILE {
		end_while(r);
	}
	| WHILE boolean_expression DO {
		start_while_true(r);
		free($2);
	} '\n' expression END WHILE {
		end_while(r);
	}
	;

for_loop:
	FOR VARIABLE FROM INT TO INT DO {
		if (!isVariableCreated(currentTable, $1)) {
			cell_t *cell = (cell_t*) malloc(sizeof(cell_t));
			initializeCell(cell, $2, TYPE_INT);
			insertHashTable(currentTable, cell);
		}

		start_for(r, $2, atoi($4), atoi($6));

		free($2);
		free($4);
		free($6);
	} '\n' expression END FOR {
		end_for(r);
	}
	| FOR VARIABLE FROM INT TO INT STEP INT DO {
		if (!isVariableCreated(currentTable, $1)) {
			cell_t *cell = (cell_t*) malloc(sizeof(cell_t));
			initializeCell(cell, $2, TYPE_INT);
			insertHashTable(currentTable, cell);
		}

		start_for_step(r, $2, atoi($4), atoi($6), atoi($8));

		free($2);
		free($4);
		free($6);
		free($8);
	} '\n' expression END FOR {
		end_for(r);
	}
	;

value:
	plus_minus {
		$$ = strdup($1);
		free($1);
	}
	| boolean_expression {
		$$ = strdup($1);
		free($1);
	}
	;

boolean_expression:
	BOOLEAN {
		$$ = strdup($1);
		free($1);
	}
	| '!' BOOLEAN {
		size_t length = strlen($2) + 2;
		$$ = (char*) malloc_check(sizeof(char) * length);

		snprintf($$, length, "!%s", $2);
		free($2);
	}
	;

plus_minus:
	plus_minus '+' multiply_divide {
		size_t length = strlen($1) + strlen($3) + 4;
		$$ = malloc_check(sizeof(char) * length);
		snprintf($$, length, "%s + %s", $1, $3);

		free($1);
		free($3);
	}
	| plus_minus '-' multiply_divide {
		size_t length = strlen($1) + strlen($3) + 4;
		$$ = malloc_check(sizeof(char) * length);
		snprintf($$, length, "%s - %s", $1, $3);

		free($1);
		free($3);
	}
	| multiply_divide
	;

multiply_divide:
	multiply_divide '/' number {
		if (atoi($3) == 0) {
			yyerror("Division par zero");
		}
		
		size_t length = strlen($1) + strlen($3) + 4;
		$$ = malloc_check(sizeof(char) * length);
		snprintf($$, length, "%s / %s", $1, $3);

		free($1);
		free($3);
	}
	| multiply_divide '*' number {
		size_t length = strlen($1) + strlen($3) + 4;
		$$ = malloc_check(sizeof(char) * length);
		snprintf($$, length, "%s * %s", $1, $3);

		free($1);
		free($3);
	}
	| multiply_divide '%' number {
		if (!(strlen($3) == 1 && isalpha($3[0])) && atoi($3) == 0) {
			printf("Test: \"%s\"", $3);
			yyerror("Division par zero via modulo");
		}

		size_t length = strlen($1) + strlen($3) + 4;
		$$ = malloc_check(sizeof(char) * length);
		snprintf($$, length, "%s %% %s", $1, $3);

		free($1);
		free($3);
	}
	| number
	;

number:
	'(' plus_minus ')' {
		size_t length = strlen($2) + 3;
		$$ = malloc_check(sizeof(char) * length);
		snprintf($$, length, "(%s)", $2);

		free($2);
	}
	| '-' INT {
		size_t length = strlen($2) + 2;
		$$ = malloc_check(sizeof(char) * length);
		snprintf($$, length, "-%s", $2);

		free($2);
	}
	| INT {
		size_t length = strlen($1) + 1;
		$$ = malloc_check(sizeof(char) * length);
		snprintf($$, length, "%s", $1);

		free($1);
	}
	| VARIABLE {
		if (!isVariableCreated(currentTable, $1)) {
			yyerror("Variable inexistante dans opération");
		}

		cell_t *cell = findHashTable(currentTable, $1);

		if (cell->type == TYPE_BOOLEAN) {
			yyerror("Impossible d'effectuer des opérations avec un booleen");
		}

		size_t length = strlen($1) + 1;
		$$ = malloc_check(sizeof(char) * length);
		snprintf($$, length, "%s", $1);

		free($1);

		printf("$$ = %s\n", $$);
	}
	;

%%

int main(void) {
	hashList = (hashList_t*) malloc(sizeof(hashList_t));
	initializeHashList(hashList);

	r = fopen("result.c", "w");

	/* Correspond au nombre maximum de variables pouvant être ajoutées à un "Ecrire" */
	queue = createQueue(255);

	#if YYDEBUG
		yydebug = 1;
	#endif 

	yyparse();

	fclose(r);
	destroyHashList(hashList);;
	destroyQueue(queue);

  	return EXIT_SUCCESS;
}

int getIntegerLength(int value) {
	int length = !value;

	while(value) {
		length++;
		value /= 10;
	}

	return length;
}

int isVariableCreated(hashTable_t *table, char *variable) {
	return !(findHashTable(table, variable) == NULL);
}

int isFunctionCreated(hashList_t *liste, char *function) {
	return !(findHashList(liste, function) == NULL);
}