ASSN = 1
CLASS= cs143
CLASSDIR= ../..
SRC= stack.cl README 
LSRC= Makefile atoi.cl stack.test

CC=gcc
CFLAGS=-g

.c.o:
	${CC} ${CFLAGS} -c $<

# Define a target to compile the stack.s from stack.cl and atoi.cl
stack.s: stack.cl atoi.cl
	${CLASSDIR}/bin/coolc $^

# Target for compiling
compile: stack.s

# Define a target for testing
test: compile
	@echo "Running test with stack.test..."
	${CLASSDIR}/bin/spim -file stack.s < stack.test

# Clean up generated files
clean:
	rm -f *.s core *~
