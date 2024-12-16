/*
*  cool.y
*  Parser definition for the COOL language.
*
*  Ahmed Reda Elsayed 20210018
*  Mohamed Ehab Tawfik 20210331
*  Reem Waleed Sarhan 20211042
*  Saif El din Hazem 20210165
*
*  Video link: https://drive.google.com/drive/folders/1T3S-q3dm3Mak3X6ykNDA8PQgCjh5cAG-?usp=sharing
*/
%{
  #include <iostream>
  #include "cool-tree.h"
  #include "stringtab.h"
  #include "utilities.h"
  
  extern char *curr_filename;
  
  
  /* Locations */
  #define YYLTYPE int              /* the type of locations */
  #define cool_yylloc curr_lineno  /* use the curr_lineno from the lexer
  for the location of tokens */
    
    extern int node_lineno;          /* set before constructing a tree node
    to whatever you want the line number
    for the tree node to be */
      
      
      #define YYLLOC_DEFAULT(Current, Rhs, N)         \
      Current = Rhs[1];                             \
      node_lineno = Current;
    
    
    #define SET_NODELOC(Current)  \
    node_lineno = Current;
    
    
    
    void yyerror(char *s);        /*  defined below; called for each parse error */
    extern int yylex();           /*  the entry point to the lexer  */
    
    /************************************************************************/
    /*                DONT CHANGE ANYTHING IN THIS SECTION                  */
    
    Program ast_root;	      /* the result of the parse  */
    Classes parse_results;        /* for use in semantic analysis */
    int omerrs = 0;               /* number of errors in lexing and parsing */
    %}
    
    /* A union of all the types that can be the result of parsing actions. */
    %union {
      Boolean boolean;
      Symbol symbol;
      Program program;
      Class_ class_;
      Classes classes;
      Feature feature;
      Features features;
      Formal formal;
      Formals formals;
      Case case_;
      Cases cases;
      Expression expression;
      Expressions expressions;
      char *error_msg;
    }
    
    %token CLASS 258 ELSE 259 FI 260 IF 261 IN 262 
    %token INHERITS 263 LET 264 LOOP 265 POOL 266 THEN 267 WHILE 268
    %token CASE 269 ESAC 270 OF 271 DARROW 272 NEW 273 ISVOID 274
    %token <symbol>  STR_CONST 275 INT_CONST 276 
    %token <boolean> BOOL_CONST 277
    %token <symbol>  TYPEID 278 OBJECTID 279 
    %token ASSIGN 280 NOT 281 LE 282 ERROR 283
    
    /*  DON'T CHANGE ANYTHING ABOVE THIS LINE, OR YOUR PARSER WONT WORK       */
    /**************************************************************************/
        
    /* Declare types for the grammar's non-terminals. */
    %type <program> program
    %type <classes> class_list
    %type <class_> class
    
    /* You will want to change the following line. */
    %type <feature> feature
    %type <feature> declare_method
    %type <feature> declare_attr
    %type <features> features
    %type <formal> formal
    %type <formals> formals
    %type <case_> case
    %type <cases> cases
    %type <expression> expression
    %type <expression> expression_with_block
    %type <expression> expression_dispatch
    %type <expression> let_in_expression
    %type <expression> let_in_assign
    %type <expressions> expressions_with_block
    %type <expressions> expressions_with_args
    
    /* Precedence declarations go here. */
    %right ASSIGN
    %precedence NOT
    %nonassoc '<' '=' LE
    %left '+' '-'
    %left '*' '/'
    %precedence ISVOID
    %precedence '~'
    %precedence '@'
    %precedence '.'
    %%
    /* 
    Save the root of the abstract syntax tree in a global variable.
    */

    /*This is the augmented grammar start rule */
    program	
    : class_list	
    { 
      @$ = @1; 
      ast_root = program($1); 
    }
    ;
    /*create node inside list of nodes*/
    class_list
    : class			/* single class */
    { 
      @$ = @1;
      $$ = single_Classes($1);
      parse_results = $$; 
    }
    | class_list class	/* several classes */
    { 
      @$ = @2;
      $$ = append_Classes($1,single_Classes($2)); 
      parse_results = $$; 
    }
    ;
    
    /* If no parent is specified, the class inherits from the Object class. */
    class	: CLASS TYPEID '{' features '}' ';'
    { 
      @$ = @6;
      $$ = class_($2,idtable.add_string("Object"), $4, stringtable.add_string(curr_filename));
    }
    | CLASS TYPEID INHERITS TYPEID '{' features '}' ';'
    { 
      @$ = @8;
      $$ = class_($2, $4, $6, stringtable.add_string(curr_filename)); 
    }
    | error ';' 
    { }
    ;

    /*
    * Features are a list of class features. Each class feature is either an attribute or a method.
    */
    features
    : feature
    { 
      @$ = @1; 
      $$ = single_Features($1); 
    }
    | features feature
    { 
      @$ = @2; 
      $$ = append_Features($1, single_Features($2)); 
    }
    |
    { 
      $$ = nil_Features(); 
    }
    ;

    feature
    :
    declare_attr
    { 
      @$ = @1; 
      $$ = $1;
    }
    | declare_method
    { 
      @$ = @1; 
      $$ = $1;
    }
    | error ';' 
    { }
    ;

    /*
    * Attributes are a list of attribute declarations. 
    * (object identifier, a type identifier, and an expression)
    */
    declare_attr
    : OBJECTID ':' TYPEID ';'
    { 
      @$ = @4;
      $$ = attr($1, $3, no_expr()); 
    }
    | OBJECTID ':' TYPEID ASSIGN expression ';'
    { 
      @$ = @6;
      $$ = attr($1, $3, $5); 
    }
    | OBJECTID ':' TYPEID ASSIGN '{' expression '}' ';'
    { 
      @$ = @8;
      $$ = attr($1, $3, $6); 
    }
    | error ';' 
    { }
    ;

    /*
    * Methods are a list of method declarations.
    * (object identifier, a list of formal parameters, a type identifier, and an expression)
    */
    declare_method
    : OBJECTID '(' formals ')' ':' TYPEID '{' expression '}' ';'
    { 
      @$ = @10;
      $$ = method($1, $3, $6, $8); 
    }
    | error ';' 
    { }
    ;

    /*
    * Formals are a list of formal parameters.
    * Each formal parameter is a pair of an object identifier and a type identifier.
    * For example, (x : Int, y : String)
    */
    formals
    : formal
    { 
      @$ = @1;
      $$ = single_Formals($1); 
    }
    | formals ',' formal
    { 
      /* CHECK THIS LINE AGAIN */
      @$ = @3; 
      $$ = append_Formals($1, single_Formals($3)); 
    }
    |
    { 
      $$ = nil_Formals(); 
    }
    ;

    formal
    : OBJECTID ':' TYPEID
    { 
      @$ = @3; 
      $$ = formal($1, $3); 
    }
    | error
    { }
    ;

    /*
    * Cases are a list of case branches.
    * (object identifier, a type identifier, and an expression)
    * For example, (x : Int => 5, y : String => "hello")
    */
  cases
    : case
    { 
      @$ = @1; 
      $$ = single_Cases($1); 
    }
    | cases case
    { 
      @$ = @2; 
      $$ = append_Cases($1, single_Cases($2)); 
    }
    |
    { 
      $$ = nil_Cases(); 
    }
    ;

  /*
  * DARROW: This is the case branch separator.
  */
  case
    : OBJECTID ':' TYPEID DARROW expression ';'
    { 
      @$ = @6;
      $$ = branch($1, $3, $5); 
    }
    | error ';'
    { }
    ;

  /* ------------------------------------------- */

  expression 
  : 
    OBJECTID ASSIGN expression 
    {
      @$ = @3;
      $$ = assign($1, $3);
    }
    | expression_dispatch 
    {
      /*
      * This is a function call.
      */
      @$ = @1;
      $$ = $1;
    }
    | IF expression THEN expression
    {
      @$ = @4;
      $$ = cond($2,$4, no_expr());
    }
    | LET let_in_expression 
    {
      @$ = @2;
      $$ = $2;
    }
    
    | WHILE expression LOOP expression POOL
    {
      @$ = @5;
      $$ = loop($2, $4);
    }
    | IF expression THEN expression ELSE expression FI
    {
      @$ = @4;
      $$ = cond($2,$4,$6);
    }
    | CASE expression OF cases ESAC
    {
      @$ = @5;
      $$ = typcase($2, $4);
    }
    | '{' expressions_with_block '}'
    {
      @$ = @2;
      $$ = block($2);
    }
    | ISVOID expression 
    {
      /*
      * This is a type check operator that returns true if the expression is void.
      */
      @$ = @2;
      $$ = isvoid($2);
    }
    | NEW TYPEID 
    {
      /*
      * This is a new operator that creates a new object of the specified type.
      */
      @$ = @2;
      $$ = new_($2);
    }
    | expression '-' expression
    {
      @$ = @3;
      $$ = sub($1, $3);
    }
    | expression '+' expression
    {
      @$ = @3;
      $$ = plus($1, $3);
    }
    | expression '*' expression
    {
      @$ = @3;
      $$ = mul($1, $3);
    }
    | expression '/' expression
    {
      @$ = @3;
      $$ = divide($1, $3);
    }
    | OBJECTID  ':=' expression
    {
    /*
    * This is another assignment operator.
    */
      @$ = @3;
      $$ = assign($1, $3);
    }
    | NOT expression {
      /*
      * This operator is Logical NOT.
      */
      @$ = @2;
      $$ = comp($2);
    }
    | '~' expression
    {
      /* 
      * This operator is Bitwise NOT.
      */
      @$ = @2;
      $$ = neg($2);
    }
    | expression '<' expression
    {
      @$ = @3;
      $$ = lt($1, $3);
    }
    | expression LE expression
    {
      @$ = @3;
      $$ = leq($1, $3);
    }
    | expression '=' expression
    {
      @$ = @3;
      $$ = eq($1, $3);
    }
    | '(' expression ')'
    {
      @$ = @2;
      $$ = $2;
    }
    | STR_CONST
    {
      @$ = @1;
      $$ = string_const($1);
    }
    | BOOL_CONST 
    {
      @$ = @1;
      $$ = bool_const($1); 
    }
    | INT_CONST 
    {
      @$ = @1;
      $$ = int_const($1);
    }
    | OBJECTID 
    {
      @$ = @1;
      $$ = object($1); 
    }
    | error ';' { yyerrok; }
    ;

  expressions_with_block : 
    expressions_with_block expression_with_block 
    {
      @$ = @2;
      $$ = append_Expressions($1,single_Expressions($2));
    }
    |
      expression_with_block 
    {
      @$ = @1;
      $$ = single_Expressions($1);
    }
    | error ';' { yyerrok; }
    ;

   expression_with_block  : 
    expression ';' 
    {
      $$ = $1;
    }
    ;


    /*
    * Dispatch is a function call. It can be a dynamic dispatch or a static dispatch.
    */
    expression_dispatch : 
    OBJECTID '(' ')'
    {
      @$ = @3;
      $$ = dispatch(object(idtable.add_string("self")), $1, nil_Expressions());
    }
    | OBJECTID '(' expression expressions_with_args  ')'
    {
      @$ = @3;
      $$ = dispatch(object(idtable.add_string("self")), $1, append_Expressions(single_Expressions($3), $4));
    }
    | OBJECTID '(' expression ')'
    {
      @$ = @3;
      $$ = dispatch(object(idtable.add_string("self")), $1, single_Expressions($3));
    }
    | expression '.' OBJECTID '(' ')'
    { 
      @$ = @5;
      $$ = dispatch($1, $3, nil_Expressions());
    }
    | expression '.' OBJECTID '(' expression ')'
    {
      @$ = @6;
      $$ = dispatch($1, $3, single_Expressions($5));
    }
    | expression '.' OBJECTID '(' expression expressions_with_args ')'
    {
      @$ = @7;
      $$ = dispatch($1, $3, append_Expressions(single_Expressions($5), $6));
    }
    | expression '@' TYPEID '.' OBJECTID '(' ')'
    {
      @$ = @7;
      $$ = static_dispatch($1, $3, $5, nil_Expressions());
    }
    | expression '@' TYPEID '.' OBJECTID '(' expression ')'
    {
      @$ = @8;
      $$ = static_dispatch($1, $3, $5, single_Expressions($7));
    }
    | expression '@' TYPEID '.' OBJECTID '(' expression expressions_with_args ')'
    {
      @$ = @9;
      $$ = static_dispatch($1, $3, $5, append_Expressions(single_Expressions($7), $8));
    }
    ;

    expressions_with_args : 
    expressions_with_args ',' expression
    {
      @$ = @3;
      $$ = append_Expressions($1, single_Expressions($3));
    }
    |',' expression 
    {
      @$ = @1;
      $$ = single_Expressions($2);
    }            
    ;


    let_in_assign  :
    {
      $$ = no_expr();
    }
    | ASSIGN expression 
    {
      @$ = @2;
      $$ = $2;
    }
    ;

    /*
    * Let expression is a list of variable declarations followed by an expression.
    */
    let_in_expression  : 
      OBJECTID ':' TYPEID let_in_assign ',' let_in_expression
    {      
      @$ = @6;
      $$ = let($1, $3, $4, $6);
    }
    |
      OBJECTID ':' TYPEID let_in_assign IN expression 
    {
      @$ = @6;
      $$ = let($1, $3, $4, $6);
    } 
    | error ',' { yyerrok; }
    ;
    
    /* end of grammar */
    %%
    
    /* This function is called automatically when Bison detects a parse error. */
    
    void yyerror(char *s)
    {
      extern int curr_lineno;
      
      cerr << "\"" << curr_filename << "\", line " << curr_lineno << ": " \
      << s << " at or near ";
      print_cool_token(yychar);
      cerr << endl;
      omerrs++;
      
      if(omerrs>50) {fprintf(stdout, "More than 50 errors\n"); exit(1);}
    }
    