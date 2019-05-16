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

void yyerror(const char *erreurMsg);
int yylex_destroy();
int isVariableCreated(hashTable_t *table, char *variable);
int isFunctionCreated(hashList_t *list, char *function);
int yylex();

FILE *r;
hashList_t *hashList;
hashTable_t *mainTable;
hashTable_t *currentTable;
queue_t *queue;
function_t *func;
int level = 0;

%}

%union {
	char *variable;
	char *string;
	variable_type vtype;
}

%token BEGIN_ALGORITHM END BEGIN_FUNCTION BEGIN_PROCEDURE
%token<string> FOR WHILE IF ELSE WRITE_OUTPUT READ_INPUT DO THEN RETURN FROM TO STEP
%token<string> COMPARISON_OPERATOR
%token<string> BOOLEAN INT
%token<string> STRING
%token<variable> VARIABLE
%token<vtype> VARIABLE_TYPE
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
	{
		include_librairies(r);
	} function algorithm END {
		end_main(r, level);
		return EXIT_SUCCESS;
	}
	| ;

algorithm:
	BEGIN_ALGORITHM VARIABLE {
		mainTable = (hashTable_t*) malloc(sizeof(hashTable_t));

		/* Insertion de la table main */
		initializeHashTable(mainTable, $2, 256);
		insertHashList(hashList, mainTable);

		start_main(r, mainTable->name);
		level += 1;

		currentTable = mainTable;
	} '\n' expression {
		free($2);
	}
	;

function:
	BEGIN_FUNCTION VARIABLE {
		hashTable_t *funcTable;

		if (isFunctionCreated(hashList, $2)) {
			yyerror("Fonction deja existante");
		}
		
		funcTable = (hashTable_t*) malloc(sizeof(hashTable_t));

		/* Insertion de la table main */
		initializeHashTable(funcTable, $2, 256);
		insertHashList(hashList, funcTable);

		currentTable = funcTable;

		func = (function_t*) malloc(sizeof(function_t));
		func->nbArguments = 0;
		func->arguments = (argument_t**) malloc(sizeof(argument_t*));
	} '(' function_definition_arguments ')' ':' VARIABLE_TYPE '\n' {
		/* Fonction Nom(type nomParam[, type nomParam]) : typeRetour */
		start_function(r, $2, func, $8);
		level += 1;
	} expression END {
		level -= 1;
		end_function(r);

		free($2);
		destroyFunction(func);
	} '\n' function
	| BEGIN_PROCEDURE VARIABLE {
		hashTable_t *funcTable;

		if (isFunctionCreated(hashList, $2)) {
			yyerror("Fonction deja existante");
		}

		funcTable = (hashTable_t*) malloc(sizeof(hashTable_t));

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
		level += 1;
	} expression END {
		level -= 1;
		end_function(r);

		free($2);
		destroyFunction(func);
	} '\n' function
	| '\n' function
	| ;

function_call:
	read
	| write
	| VARIABLE {
		func = (function_t*) malloc(sizeof(function_t));
		func->nbArguments = 0;
		func->arguments = (argument_t**) malloc(sizeof(argument_t*));
	} '(' function_call_arguments ')' {
		if (!isFunctionCreated(hashList, $1)) {
			yyerror("Fonction inconnue");
		}

		function_call(r, level, $1, func);

		free($1);
		destroyFunction(func);
	}
	;

function_definition_arguments:
	function_definition_arguments ',' arguments
	| arguments
	;

arguments:
	VARIABLE_TYPE VARIABLE {
		cell_t *cell;
		argument_t *arg;

		if (isVariableCreated(currentTable, $2)) {
			yyerror("Variable déjà existante dans la définition de fonction");
		}

		cell = (cell_t*) malloc(sizeof(cell_t));
		initializeCell(cell, $2, $1);
		insertHashTable(currentTable, cell);
		
		func->nbArguments += 1;
		func->arguments = realloc(func->arguments, sizeof(argument_t*) * func->nbArguments);

		arg = (argument_t*) malloc(sizeof(argument_t));
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
		argument_t *arg;

		func->nbArguments += 1;
		func->arguments = realloc(func->arguments, sizeof(argument_t*) * func->nbArguments);

		arg = (argument_t*) malloc(sizeof(argument_t));
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

			generate_declaration(r, level, $3, TYPE_INT);
		}

		/* Puis ensuite on effectue le scanf */
		function_scanf(r, level, $3);

		free($3);
	}
	;

write:
	WRITE_OUTPUT '(' full_string ')' {
		function_printf(r, level, $3, queue);

		free($3);
	}
	;

full_string:
	full_string '+' var_or_string {
		size_t length = strlen($1) + strlen($3) + 1;
		$$ = malloc_check(sizeof(char) * length);

		snprintf($$, length, "%s%s", $1, $3);

		free($1);
		free($3);
	}
	| var_or_string
	;

var_or_string:
	VARIABLE {
		func = (function_t*) malloc(sizeof(function_t));
		func->nbArguments = 0;
		func->arguments = (argument_t**) malloc(sizeof(argument_t*));
	} '(' function_call_arguments ')' {
		int i;
		variable_t *v;
		size_t argLength, length;
		char *argBuffer;

		if (!isFunctionCreated(hashList, $1)) {
			yyerror("Fonction inconnue");
		}

		/* Création du formattage */
		length = strlen("%d") + 1;
		$$ = malloc_check(sizeof(char) * length);
		snprintf($$, length, "%s", "%d");
		
		argLength = 0;
		for (i = 0; i < func->nbArguments; ++i) {
			/* + 2 pour la virgule et l'espace */
			argLength += strlen(func->arguments[i]->name) + 2;
		}
		/* -2 pour supprimer la dernière virgule et le dernier espace, +1 pour le \0 */

		if (argLength != 0) {
			argLength -= 1;
			argBuffer = (char*) malloc(sizeof(char) * argLength);
			
			for (i = 0; i < func->nbArguments; ++i) {
				if (i < func->nbArguments - 1) {
					snprintf(argBuffer + strlen(argBuffer), argLength, "%s, ", func->arguments[i]->name);
				}
				else {
					snprintf(argBuffer + strlen(argBuffer), argLength, "%s", func->arguments[i]->name);
				}
			}

			/* Ajouter la fonction à la file */
			v = (variable_t*) malloc(sizeof(variable_t));
			length = argLength + strlen($1) + 3;
			v->name = malloc(sizeof(char) * length);
			snprintf(v->name, length, "%s(%s)", $1, argBuffer);
			v->type = TYPE_INT;

			enqueue(queue, v);
		}

		free($1);
	}
	| VARIABLE {
		size_t length;
		variable_t *v;

		if (!isVariableCreated(currentTable, $1)) {
			yyerror("Variable inexistante");
		}

		/* Création du formattage */
		length = strlen("%d") + 1;
		$$ = malloc_check(sizeof(char) * length);
		snprintf($$, length, "%s", "%d");

		/* Ajout de la variable à une file */
		v = (variable_t*) malloc(sizeof(variable_t));
		v->name = strdup($1);
		v->type = TYPE_INT;

		enqueue(queue, v);

		free($1);
	}
	| STRING {
		size_t i;
		size_t length;
		char *var;
		
		length = strlen($1);
		
		/* Si la longueur de la chaîne dépasse 2 caractères, on supprime le premier et dernier (les double-quotes) */
		if (length > 2) {
			var = (char*) malloc_check(sizeof(char) * (length - 1));

			for (i = 1; i < length - 1; ++i) {
				var[i - 1] = $1[i];
			}

			var[length - 2] = 0;
		}

		/* Sinon on remplace la chaîne par une chaîne d'un espace */
		else {
			var = (char*) malloc_check(sizeof(char) * 2);
			var[0] = ' ';
			var[1] = '\0';
		}

		length = strlen(var) + 2;

		$$ = (char*) malloc_check(sizeof(char) * length);
		snprintf($$, length, "%s", var);

		free($1);
		free(var);
	}
	;

expression:
	declaration '\n' expression
	| instruction '\n' expression
	| '\n' expression
	| ;

declaration:
	VARIABLE '=' plus_minus {
		if (!isVariableCreated(currentTable, $1)) {
			cell_t *cell;
			cell = (cell_t*) malloc(sizeof(cell_t));
			initializeCell(cell, $1, TYPE_INT);
			insertHashTable(currentTable, cell);

			generate_declaration(r, level, $1, TYPE_INT);
		}

		declaration(r, level, $1, $3);

		free($1);
		free($3);
	}
	| VARIABLE '=' BOOLEAN {
		if (!isVariableCreated(currentTable, $1)) {
			cell_t *cell = (cell_t*) malloc(sizeof(cell_t));
			initializeCell(cell, $1, TYPE_BOOLEAN);
			insertHashTable(currentTable, cell);

			generate_declaration(r, level, $1, TYPE_BOOLEAN);
		}

		declaration(r, level, $1, $3);

		free($1);
		free($3);
	}
	;

instruction:
	condition
	| function_call
	| loop
	| RETURN value {
		return_function_value(r, level, $2);

		free($2);
	}
	| RETURN {
		return_function(r, level);
	}
	;

condition:
	IF plus_minus COMPARISON_OPERATOR value THEN {
		start_if(r, level, $2, $3, $4);
		level += 1;

		free($2);
		free($3);
		free($4);
	} '\n' expression else_cond END IF {
		level -= 1;
		end_if(r, level);
	}
	;

else_cond:
	ELSE {
		level -= 1;
		end_if(r, level);
		start_else(r, level);
		level += 1;
	} '\n' expression
	| ;

loop:
	while_loop
	| for_loop
	;

while_loop:
	WHILE plus_minus COMPARISON_OPERATOR plus_minus DO {
		start_while(r, level, $2, $3, $4);
		level += 1;

		free($2);
		free($3);
		free($4);
	} '\n' expression END WHILE {
		level -= 1;
		end_while(r, level);
	}
	| WHILE boolean_expression DO {
		start_while_true(r, level);
		level += 1;
		free($2);
	} '\n' expression END WHILE {
		level -= 1;
		end_while(r, level);
	}
	;

for_loop:
	FOR VARIABLE FROM INT TO INT DO {
		if (!isVariableCreated(currentTable, $1)) {
			cell_t *cell = (cell_t*) malloc(sizeof(cell_t));
			initializeCell(cell, $2, TYPE_INT);
			insertHashTable(currentTable, cell);

			generate_declaration(r, level, $2, TYPE_INT);
		}

		start_for(r, level, $2, atoi($4), atoi($6));
		level += 1;

		free($2);
		free($4);
		free($6);
	} '\n' expression END FOR {
		level -= 1;
		end_for(r, level);
	}
	| FOR VARIABLE FROM INT TO INT STEP INT DO {
		if (!isVariableCreated(currentTable, $1)) {
			cell_t *cell = (cell_t*) malloc(sizeof(cell_t));
			initializeCell(cell, $2, TYPE_INT);
			insertHashTable(currentTable, cell);

			generate_declaration(r, level, $2, TYPE_INT);
		}

		start_for_step(r, level, $2, atoi($4), atoi($6), atoi($8));
		level += 1;

		free($2);
		free($4);
		free($6);
		free($8);
	} '\n' expression END FOR {
		level -= 1;
		end_for(r, level);
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
		size_t length;

		if (atoi($3) == 0) {
			yyerror("Division par zero");
		}
		
		length = strlen($1) + strlen($3) + 4;
		$$ = malloc_check(sizeof(char) * length);
		snprintf($$, length, "%s / %s", $1, $3);

		free($1);
		free($3);
	}
	| multiply_divide '*' number {
		size_t length;
		
		length = strlen($1) + strlen($3) + 4;
		$$ = malloc_check(sizeof(char) * length);
		snprintf($$, length, "%s * %s", $1, $3);

		free($1);
		free($3);
	}
	| multiply_divide '%' number {
		size_t length;

		if (!(strlen($3) == 1 && isalpha($3[0])) && atoi($3) == 0) {
			printf("Test: \"%s\"", $3);
			yyerror("Division par zero via modulo");
		}
		
		length = strlen($1) + strlen($3) + 4;
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
		cell_t *cell;
		size_t length;

		if (!isVariableCreated(currentTable, $1)) {
			yyerror("Variable inexistante dans opération");
		}

		cell = findHashTable(currentTable, $1);

		if (cell->type == TYPE_BOOLEAN) {
			yyerror("Impossible d'effectuer des opérations avec un booleen");
		}

		length = strlen($1) + 1;
		$$ = malloc_check(sizeof(char) * length);
		snprintf($$, length, "%s", $1);

		free($1);
	}
	;

%%

int main(int argc, char *argv[]) {
	hashList = (hashList_t*) malloc(sizeof(hashList_t));
	initializeHashList(hashList);

	if (argc == 2) {
		r = fopen(argv[1], "w");
	}
	else {
		r = fopen("result.c", "w");
	}

	/* Correspond au nombre maximum de variables pouvant être ajoutées à un "Ecrire" */
	queue = createQueue(255);

	#if YYDEBUG
		yydebug = 1;
	#endif 

	yyparse();
	yylex_destroy();

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

int isFunctionCreated(hashList_t *list, char *function) {
	return !(findHashList(list, function) == NULL);
}