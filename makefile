FLAGS = -Wall -O3 -Werror -ansi -pedantic -D_POSIX_C_SOURCE=200809L
LIBS = -lm -lfl

algorithm: y.tab.o lex.yy.o hashTable.o list.o cell.o queue.o memoryUtils.o hashList.o codeGenerator.o
	gcc ${FLAGS} y.tab.o lex.yy.o hashTable.o list.o cell.o queue.o memoryUtils.o hashList.o codeGenerator.o -o algorithm.out ${LIBS}

memoryUtils.o: libs/memoryUtils.h libs/memoryUtils.c
	gcc ${FLAGS} -c libs/memoryUtils.c

codeGenerator.o: libs/codeGenerator.h libs/codeGenerator.c libs/cell.c
	gcc ${FLAGS} -c libs/codeGenerator.c

cell.o: libs/cell.h libs/cell.c
	gcc ${FLAGS} -c libs/cell.c

list.o: libs/list.h libs/list.c
	gcc ${FLAGS} -c libs/list.c

hashTable.o: libs/hashTable.h libs/hashTable.c
	gcc ${FLAGS} -c libs/hashTable.c

queue.o: libs/queue.h libs/queue.c
	gcc ${FLAGS} -c libs/queue.c

hashList.o: libs/hashList.h libs/hashList.c
	gcc ${FLAGS} -c libs/hashList.c

y.tab.o : y.tab.h y.tab.c
	gcc ${FLAGS} -c y.tab.c

y.tab.c y.tab.h : algorithm.yacc.y
	yacc -d algorithm.yacc.y --verbose

lex.yy.o : lex.yy.c y.tab.h
	gcc -c lex.yy.c

lex.yy.c : algorithm.l 
	flex algorithm.l

run:
	./algorithm.out $(fileout) < $(filein)
	gcc $(fileout) -o $(basename $(fileout)).out

clean:
	rm -f y.tab.*
	rm -f lex.yy.*
	rm -f algorithm algorithm.exe
	rm -rf *.out
	rm -f *.o
	rm -f *~
	rm -f *.stackdump
