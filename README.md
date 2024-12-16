# COOL-Language-Compiler

**# COOL Compiler Project

This project implements various stages of a compiler for the COOL programming language, as part of a course assignment. The project is divided into multiple phases, each focusing on a specific aspect of the compiler development process.

## Table of Contents

- [Project Overview](#project-overview)
- [Project Phases](#project-phases)
  - [Phase 1: Stack Machine Interpreter](#phase-1-stack-machine-interpreter)
  - [Phase 2: Lexical Analyzer](#phase-2-lexical-analyzer)
  - [Phase 3: Bison Parser](#phase-3-bison-parser)
- [Dependencies](#dependencies)
- [Setup and Compilation](#setup-and-compilation)
- [Usage](#usage)
- [Contact](#contact)

---

## Project Overview

This project involves creating and integrating multiple components of a compiler for the COOL programming language. COOL (Classroom Object-Oriented Language) is a simple object-oriented programming language designed for educational purposes.

Each phase builds upon the previous one, culminating in a functional compiler capable of processing COOL programs.

---

## Project Phases

### Phase 1: Example on COOL Language Syntax that do these requirements:-

#### Features
- **`int`**: Pushes an integer onto the stack.
- **`+`**: Pushes a `+` operator onto the stack.
- **`s`**: Pushes an `s` operator onto the stack for swapping.
- **`e`**: Evaluates the top of the stack based on the following:
  - Adds two integers if `+` is at the top.
  - Swaps the top two elements if `s` is at the top.
- **`d`**: Displays the contents of the stack.
- **`x`**: Stops the interpreter.


### Phase 2: Lexical Analyzer

#### Overview
In this phase, a lexical analyzer (scanner) is implemented using **Flex** for C++ or **JLex** for Java. The scanner identifies and classifies tokens in COOL programs.

#### Features
- Token recognition using regular expressions.
- Handles COOL-specific tokens as defined in the COOL language specification.
- Supports state-based processing for nested structures like comments.

#### Tools Used
- **Flex**: For generating a lexical analyzer in C++.
- **JLex**: For generating a lexical analyzer in Java.

### Phase 3: Bison Parser

#### Overview
This phase implements a parser for COOL programs using **Bison**. The parser validates the syntax of COOL programs and generates parse trees.

#### Features
- Implements parsing rules in a `.y` file.
- Processes COOL programs and validates their syntax.
- Tests provided for both valid and invalid COOL programs (`good.cl`, `bad.cl`, `test.cl`, `stack.cl`).

---

## Dependencies

- **Flex** or **JLex**: For lexical analysis.
- **Bison**: For syntax parsing.
- **SPIM**: For executing MIPS assembly code.
- **C++ Compiler**: GCC or equivalent.
- **Cool Tools**: Available in the `student-dist` directory.

---

## Setup and Compilation

1. Clone the project repository:
   ```bash
   git clone <repository-url>
   cd cool-compiler
    ```

Compile the code:
For the stack machine interpreter:
```bash
coolc stack.cl atoi.cl
spim -file stack.s
```
For the lexical analyzer:
```bash
flex lexer.l
gcc lex.yy.c -o lexer
./lexer < test.cl
```
For the parser:
```bash
bison -d parser.y
gcc parser.tab.c -o parser
./parser < test.cl
```
Usage
Run the stack machine interpreter:
```bash
./stack.s
```
Run the lexical analyzer:
```bash
./lexer <input_file>
```
Run the Bison parser:
```bash
./parser <input_file>
```
