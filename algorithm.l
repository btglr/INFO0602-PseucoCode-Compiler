%{
#include "libs/cell.h"
#include "y.tab.h"
#include <string.h>
#include <ctype.h>

void yyerror(const char *erreurMsg);
void toLowerString(char *);
%}

%%

(?i:pour) { return FOR; }
(?i:écrire|ecrire) { return WRITE_OUTPUT; }
(?i:lire) { return READ_INPUT; }
(?i:si) { return IF; }
(?i:sinon) { return ELSE; }
(?i:faire) { return DO; }
(?i:alors) { return THEN; }
(?i:"tant que") { return WHILE; }
(?i:retour) { return RETURN; }
(?i:"allant de") { return FROM; }

 /* On oblige à utiliser le "à" car sinon on ne peut utiliser a comme variable */
(?i:à) { return TO; }
(?i:par) { return STEP; }

(?i:algorithme) { return BEGIN_ALGORITHM; }
(?i:procédure|procedure) { return BEGIN_PROCEDURE; }
(?i:fonction) { return BEGIN_FUNCTION; }
(?i:fin) { return END; }

(?i:entier|booléen|booleen) {
	char *lower = strdup(yytext);
	toLowerString(lower);

	if (strcmp(lower, "entier") == 0) {
		yylval.vtype = TYPE_INT;
	}

	else {
		yylval.vtype = TYPE_BOOLEAN;
	}

	return VARIABLE_TYPE;
}
 /* (?i:bool[é|e]en) { return TYPE_BOOLEAN; } */

"=="|"!=" {
	yylval.string = strdup(yytext);
	return COMPARISON_OPERATOR;
}

 /* "+"|"-"|"/"|"*"|"%" { return OPERATION_OPERATOR; } */
 /* "(" { return OPENING_PARENTHESIS; }
	")" { return CLOSING_PARENTHESIS; } */
 /* "=" { return ASSIGNMENT_OPERATOR; } */
 /* "+" { return OPERATOR_PLUS; }
	"-" { return OPERATOR_MINUS; }
	"*" { return OPERATOR_MULTIPLY; }
	"/" { return OPERATOR_DIVIDE; }
	"%" { return OPERATOR_MODULO; } */

[0-9]+ {
	yylval.string = strdup(yytext);
	return INT;
}

(?i:vrai|faux) {
	char *lower = strdup(yytext);
	toLowerString(lower);

	yylval.string = (char*) malloc(sizeof(char) * 2);

	if (strcmp(lower, "vrai") == 0) {
		snprintf(yylval.string, 2, "%s", "1");
	}

	else {
		snprintf(yylval.string, 2, "%s", "0");
	}

	return BOOLEAN;
}

[a-zA-Z_$][a-zA-Z0-9_$]* {
	yylval.variable = strdup(yytext);
	return VARIABLE;
}

\"(?:\\.|[^\n"\\])*\" {
	yylval.string = strdup(yytext);
	return STRING;
}

[\:,=\n\(\)\*\+\-\/\%] {
	return *yytext;
}

[ \t] ;

. { ECHO; }

%%

void yyerror(const char *erreurMsg) {
	fprintf(stderr, "\n Erreur '%s' sur '%s'.\n", erreurMsg, yytext);
	exit(EXIT_FAILURE);
}

void toLowerString(char *str) {
	for(int i = 0; str[i]; i++){
		str[i] = tolower(str[i]);
	}
}