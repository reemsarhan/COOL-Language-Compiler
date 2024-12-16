/***************************************
*				Definitions			   *  
***************************************/
%{
    
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>
#include <stdint.h>

#define yylval cool_yylval
#define yylex  cool_yylex


#define MAX_STR_CONST 1025
#define YY_NO_UNPUT 

extern FILE *fin; /* we read from this file */



#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");
char string_buf[MAX_STR_CONST]; 
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;


char str[MAX_STR_CONST];
int strLen;
bool isNull;

%}


%option noyywrap
%x LC BC STRING


DARROW          =>
LE              <=
ASSIGN          <-

%% 

{DARROW}        { return (DARROW); } // Match "=>" and return the DARROW token
{LE}			{ return (LE); } // Match "<=" and return the LE token
{ASSIGN}		{ return (ASSIGN); } // Match "<-" and return the ASSIGN token

\n				{ curr_lineno++; }
[\t\r\v\f ]+	{}

"--"			{ BEGIN LC; }
"(\*"			{ BEGIN BC; }
"\*)"			{
	strcpy(cool_yylval.error_msg, "unmatched *)");
	return (ERROR);
}


<LC>\n		{ BEGIN 0; curr_lineno++; }
<LC>.			{}

<BC>\n		{ curr_lineno++; }
<BC>"\*)"	{ BEGIN 0; }
<BC><<EOF>>	{ 
	strcpy(cool_yylval.error_msg, "EOF in comment");
	BEGIN 0; 
	return (ERROR);
}

<BC>.			{}



 /*
  *  Keywords are case-insensitive except for the values true and false which must begin with a lower-case letter
  */

[Cc][Ll][Aa][Ss][Ss] 					{ return CLASS; }
[Ee][Ll][Ss][Ee] 						{ return ELSE; }
[Ff][Ii] 								{ return FI; }
[Ii][Ff] 								{ return IF; }
[Ii][Nn] 								{ return IN; }
[Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss] 		{ return INHERITS; }
[Ll][Ee][Tt] 							{ return LET; }
[Ll][Oo][Oo][Pp] 						{ return LOOP; }
[Pp][Oo][Oo][Ll] 						{ return POOL; }
[Tt][Hh][Ee][Nn] 						{ return THEN; }
[Ww][Hh][Ii][Ll][Ee] 					{ return WHILE; }
[Cc][Aa][Ss][Ee] 						{ return CASE; }
[Ee][Ss][Aa][Cc] 						{ return ESAC; }
[Oo][Ff] 								{ return OF; }
[Nn][Ee][Ww] 							{ return NEW; }
[Ll][Ee] 								{ return LE; }
[Nn][Oo][Tt] 							{ return NOT; }
[Ii][Ss][Vv][Oo][Ii][Dd]				{ return ISVOID; }     


t[Rr][Uu][Ee]      { 
                cool_yylval.boolean = 1;
                return (BOOL_CONST); 
            }

f[Aa][Ll][Ss][Ee]     { 
                cool_yylval.boolean = 0;
                return (BOOL_CONST); 
            }

"("         { return '('; }
")"         { return ')'; }
"{"         { return '{'; }
"}"         { return '}'; }
","         { return ','; }
";"         { return ';'; }
":"         { return ':'; }
"@"         { return '@'; }
"~"         { return '~'; }
"+"         { return '+'; }
"-"         { return '-'; }
"*"         { return '*'; }
"/"         { return '/'; }
"%"         { return '%'; }
"<"         { return '<'; }
"="         { return '='; }
"."         { return '.'; }



%{
/*
 *	String constants (C syntax)
 */
 %}


\"	{
	memset(str, 0, sizeof str);
	strLen = 0; 
	isNull = false;
	BEGIN STRING;
}

<STRING><<EOF>>	{
	strcpy(cool_yylval.error_msg, "EOF in string constant");
	BEGIN 0; 
	return (ERROR);
}

<STRING>\\.		{
	if (strLen >= MAX_STR_CONST) {
		strcpy(cool_yylval.error_msg, "String constant too long");
		BEGIN 0; 
		return (ERROR);
	} 
	switch(yytext[1]) {
		case '\\': str[strLen++] = '\\'; break;
		case 'n' : str[strLen++] = '\n'; break;
		case '\"': str[strLen++] = '\"'; break;
		case 'f' : str[strLen++] = '\f'; break;
		case 't' : str[strLen++] = '\t'; break;
		case 'b' : str[strLen++] = '\b'; break;
		case '0' : str[strLen++] = 0; 
			   isNull = true; break;
		default  : str[strLen++] = yytext[1];
	}
}

<STRING>\\\n	{ curr_lineno++; }
<STRING>\n		{
	curr_lineno++;
	strcpy(cool_yylval.error_msg, "Unterminated string constant");
	BEGIN 0; 
	return (ERROR);
}

<STRING>\"		{ 
	if (strLen > 1 && isNull) {
		strcpy(cool_yylval.error_msg, "String contains null character");
		BEGIN 0; 
		return (ERROR);
	}
	cool_yylval.symbol = stringtable.add_string(str);
	BEGIN 0; 
	return (STR_CONST);
}

<STRING>.		{ 
	if (strLen >= MAX_STR_CONST) {
		strcpy(cool_yylval.error_msg, "String constant too long");
		BEGIN 0; 
		return (ERROR);
	} 
	str[strLen++] = yytext[0]; 
}




%{
/*
 *	Integers
 */
 %}
 
 
[0-9]+				{ 
	cool_yylval.symbol = inttable.add_string(yytext); 
	return (INT_CONST);
}


%{
/*
 *	Classes
 */
 %}

[A-Z][A-Za-z0-9_]*	{
	cool_yylval.symbol = idtable.add_string(yytext);
	return (TYPEID);
}


%{
/*
 *	variables
 */
 %}
 
[a-z][A-Za-z0-9_]*	{
	cool_yylval.symbol = idtable.add_string(yytext);
	return (OBJECTID);
}


 %{
/*
 *		Handle errors such as invalid characters
 */
 %}
.	{
	strcpy(cool_yylval.error_msg, yytext); 
	return (ERROR); 
}

%%