
/* description: Parses end executes mathematical expressions. */

/* lexical grammar */
%lex
%%

\s+                   /* skip whitespace */
[0-9]+("."[0-9]+)?\b  return 'NUMBER'
":"                   return ':'
"?"                   return '?'
","                   return ','
"("                   return '('
")"                   return ')'
['"].*['"]            return 'STRING'
(true|false)          return 'BOOL'
\@                    return 'CMP'
\w[\w\d]*             return 'KEY'
"."                   return '.'
<<EOF>>               return 'EOF'
.                     return 'INVALID'

/lex

%right '?'

%start expressions

%% /* language grammar */

expressions
    : e EOF
        { typeof console !== 'undefined' ? console.log($1) : print($1);
          return $1; }
    ;

e
    : '(' e ')'
        {$$ = {code: 'group', value: $2};}
    | method_chain
        {$$ = {code: 'method', value: $1};}
    | NUMBER
        {$$ = {code: 'simple', value: Number(yytext)};}
    | STRING
        {$$ = {code: 'simple', value: yytext.replace(/(^['"]|['"]$)/g,'')};}
    | BOOL
        {$$ = {code: 'simple', value: (yytext == 'true')};}
    ;

method_chain
    : method
        {$$ = {code: 'method', value: $1};}
    | CMP method_chain
        {$$ = {code: 'cmp', value: $2};}
    | method '.' method_chain
        {$$ = {code: 'chain', target: $1, rest: $3};}
    ;

method
    : key
        {$$ = {code: 'prop', value: $1};}
    | key '(' args ')'
        {$$ = {code: 'call', name: $1, args: $3};} 
    ;

key
   : KEY
       {$$ = yytext;} 
   ;

args
    : e ',' args
       {$$ = {code: 'args', first: $1, rest: $3};} 
    | e
       {$$ = {code: 'arg', value: $1};}
   ;

ternary
    : e '?' e ':' e
        {$$ = {code: 'if', cond: $1, left: $3, right: $5};}
    ;