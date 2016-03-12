
all: main

main: main.o sunpos.o
	g++ -o rainbow main.o sunpos.o

main.o: main.cpp sunpos.h
	g++ -c -Wall -g main.cpp sunpos.h

sunpos.o: sunpos.cpp sunpos.h
	g++ -c -Wall -g sunpos.cpp sunpos.h

clean:
	rm *.o *.gch rainbow
