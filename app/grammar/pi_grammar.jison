
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
\s*"="\s*             return 'EQL'
\s*">"\s*             return 'MORE'
\s*"<"\s*             return 'LESS'
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
    | simple_e
        {$$ = $1;}
    | '(' object ')'
        {$$ = fn_arr_obj($2);}
    ;



group_e
    : '(' e ')'
         {$$ = {code: 'group', value: $2};}
    ;

simple_e
    : method_chain
        {$$ = {code: 'chain', value: $1};}
    | val
        {$$ = {code: 'simple', value: $1};}
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
       {$$ = [{code: 'res', name: $1}, {code: 'call', name: 'view', args: [fn_arr_obj($3)]}];}
    | 'RES' '(' val ')'
       {$$ = [{code: 'res', name: $1}, {code: 'call', name: 'get', args: [$3]}];}
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
        {$$ = fn_arr_obj(tmp);}
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
    | STRING
         {$$ = yytext.replace(/(^['"]|['"]$)/g,'');}
    | BOOL
         {$$ = yytext;}
    ;

op
    : 'EQL'
        {$$ = yytext.replace(/(^\s+|\s+$)/g,'');}
    | 'MORE'
        {$$ = yytext.replace(/(^\s+|\s+$)/g,'');}
    | 'LESS'
        {$$ = yytext.replace(/(^\s+|\s+$)/g,'');}
    ;

cond
    : simple_e op simple_e
         {$$ = {left: $1, right: $3, type: $2};}
    ;

ternary
    : cond 'TIF' e 'TELSE' e
        {$$ = {code: 'if', cond: $1, left: $3, right: $5};}
    | simple_e 'TIF' e 'TELSE' e
        {$$ = {code: 'if', cond: {left: $1, type: 'bool'}, left: $3, right: $5};}
    ;