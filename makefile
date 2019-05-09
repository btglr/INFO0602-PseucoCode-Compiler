algorithm: y.tab.o lex.yy.o hashTable.o list.o cell.o
	gcc -o algorithm y.tab.o lex.yy.o hashTable.o list.o cell.o -lm -lfl

cell.o: libs/cell.h libs/cell.c
	gcc -c libs/cell.c

list.o: libs/list.h libs/list.c
	gcc -c libs/list.c

hashTable.o: libs/hashTable.h libs/hashTable.c
	gcc -c libs/hashTable.c

y.tab.o : y.tab.h y.tab.c
	gcc -c y.tab.c

y.tab.c y.tab.h : algorithm.yacc.y
	yacc -d algorithm.yacc.y --verbose

lex.yy.o : lex.yy.c y.tab.h
	gcc -c lex.yy.c

lex.yy.c : algorithm.l 
	flex algorithm.l

clean:
	rm -f y.tab.*
	rm -f lex.yy.*
	rm -f algorithm algorithm.exe
	rm -f *.o
	rm -f *~
	rm -f *.stackdump