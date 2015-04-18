
/* description: Parses end executes html-inlined functions. */

/* lexical grammar */
%lex
%%

\s\s+                   /* skip whitespace */
[0-9]+("."[0-9]+)?\b  return 'NUMBER'
\s+":"\s+             return 'TELSE'
":"\s*              return ':'
\s+"?"\s+             return 'TIF'
"?"                   return '?'
","\s*                return ','
"("                   return '('
")"                   return ')'
\"(\\\"|[^\"])*\"     return 'STRING'
\'(\\\'|[^\'])*\'     return 'STRING'
(true|false)          return 'BOOL'
[A-Z][\w\d]*          return 'RES'
\w[\w\d]*             return 'KEY'
"."                   return '.'
\s*("="|">="|">"|"<"|"<=")\s* return 'OP'
\s*("+"|"-")\s* return 'OP2'
\s*("/"|"*")\s* return 'OP3'
<<EOF>>               return 'EOF'
.                     return 'INVALID'

/lex

%{
  var fn_arr_obj = function(arr){ 
     var tmp = {};
     for(var i=0,size=arr.length; i<size; i+=2)
       tmp[arr[i]] = arr[i+1];
     return tmp;
  };
%}

%left 'OP'
%left 'OP2'
%left 'OP3'
%left 'TIF'

%start expressions

%% /* language grammar */

expressions
    : e EOF
        { return $1; }
    ;

e
    : group_e
        {$$ = $1;}       
    | ternary
        {$$ = $1;}
    | cond
        {$$ = $1;}
    | simple_e
        {$$ = $1;}
    | '(' object ')'
        {$$ = {code: 'simple', value: fn_arr_obj($2)};}
    ;



group_e
    : '(' e ')'
         {$$ = $2;}
    ;

simple_e
    : method_chain
        {$$ = {code: 'chain', value: $1};}
    | val
        {$$ = {code: 'simple', value: $1};}

    | simple_e 'OP' simple_e
         {$$ = {code: 'op', left: $1, right: $3, type: $2.trim()};}
    | simple_e 'OP2' simple_e
         {$$ = {code: 'op', left: $1, right: $3, type: $2.trim()};}
    | simple_e 'OP3' simple_e
         {$$ = {code: 'op', left: $1, right: $3, type: $2.trim()};}
    ;

method_chain
    : method
        {$$ = $1;}
    | method '.' method_chain
        {$$ = $1.concat($3);}
    ;

method
    : resource
        {$$ = $1;}
    | key
        {$$ = [{code: 'prop', name: $1}];}
    | key '(' args ')'
        {$$ = [{code: 'call', name: $1, args: $3}];} 
    ;

resource
    : 'RES' '(' object ')'
       {$$ = [{code: 'res', name: $1}, {code: 'call', name: 'view', args: [{code: 'simple', value: fn_arr_obj($3)}]}];}
    | 'RES' '(' val ')'
       {$$ = [{code: 'res', name: $1}, {code: 'call', name: 'get', args: [{code: 'simple', value: $3}]}];}
    | 'RES'
       {$$ = [{code: 'res', name: $1}];}
    ;

key
   : KEY
       {$$ = yytext;} 
   ;

args
    : group_e ',' args
        {$$ = [$1].concat($3);} 
    | simple_e ',' args
        {$$ = [$1].concat($3);} 
    | e
        {$$ = [$1];}
    | object
        {$$ = [{code: 'simple', value: fn_arr_obj($1)}];}
    |
        {$$ = [];}
   ;

object
    : key_val ',' object
        {$$ = $1.concat($3);}
    | key_val
        {$$ = $1;}
    ;

key_val
    : key ':' val
         {$$ = [$1,$3];}
    ;

val
    : NUMBER
         {$$ = Number(yytext);}
    | BOOL
         {$$ = yytext=="true";}
    | STRING
         {$$ = yytext.replace(/(^['"]|['"]$)/g,'');}
    ;


ternary

    : simple_e 'TIF' e 'TELSE' e
        {$$ = {code: 'if', cond: $1, left: $3, right: $5};}
    ;