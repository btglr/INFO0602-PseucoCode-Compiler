%{
#include "y.tab.h"
#include <string.h>
void yyerror(const char *erreurMsg);
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
(?i:de) { return FROM; }

 /* On oblige à utiliser le "à" car sinon on ne peut utiliser a comme variable */
(?i:à) { return TO; }
(?i:par) { return STEP; }

(?i:algorithme) { return BEGIN_ALGORITHM; }
(?i:procédure|procedure) { return BEGIN_PROCEDURE; }
(?i:fonction) { return BEGIN_FUNCTION; }
(?i:fin) { return END; }

(?i:entier|booléen|booleen) {
	strcpy(yylval.string, yytext);
	return VARIABLE_TYPE;
}
 /* (?i:bool[é|e]en) { return TYPE_BOOLEAN; } */

"=="|"!=" { return COMPARISON_OPERATOR; }
 /* "+"|"-"|"/"|"*"|"%" { return OPERATION_OPERATOR; } */
"(" { return OPENING_PARENTHESIS; }
")" { return CLOSING_PARENTHESIS; }
 /* "=" { return ASSIGNMENT_OPERATOR; } */
"+" { return OPERATOR_PLUS; }
"-" { return OPERATOR_MINUS; }
"*" { return OPERATOR_MULTIPLY; }
"/" { return OPERATOR_DIVIDE; }
"%" { return OPERATOR_MODULO; }

[0-9]+ {
	yylval.integer = atoi(yytext);
	return INT;
}

(?i:vrai|faux) {
	yylval.integer = (strcmp(yytext, "vrai") == 0) ? 1 : 0;
	return BOOLEAN;
}

[a-zA-Z_$][a-zA-Z0-9_$]* {
	strcpy(yylval.variable, yytext);
	return VARIABLE;
}

\".+\" {
	strcpy(yylval.output, yytext);
	return STRING;
}

[\:,=\n] {
	return *yytext;
}

[ \t] ;

. { ECHO; }

%%

void yyerror(const char *erreurMsg) {
	fprintf(stderr, "\n Erreur '%s' sur '%s'.\n", erreurMsg, yytext);
	exit(EXIT_FAILURE);
}