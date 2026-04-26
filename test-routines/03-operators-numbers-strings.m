OPS ;tree-sitter-m: operators, numbers, strings, comments
 ; Exercises @operator, @number, @string, @comment.
 ; What to look for:
 ;   - All operators (=, +, -, *, /, \, #, **, _, =, <, >, [, ], ]],
 ;     !, &, ', plus the negated compounds '=, '<, '>, '[, '], ']],
 ;     '&, '!, plus YDB/IRIS shorthand >=, <=, !=) → @operator.
 ;   - Numbers in every M form → @number.
 ;   - Strings, including escaped "" → @string (the doubled quote
 ;     usually colours like an escape; our TextMate marks it
 ;     constant.character.escape).
 ;   - This whole block of commentary → @comment.
 ;
 ; --- numbers ------------------------------------------------------
 S A=0,B=42,C=-3,D=3.14,E=.5,F=1E10,G=1.5E-3,H=2.71828
 ;
 ; --- strings ------------------------------------------------------
 S S1="simple"
 S S2="with ""embedded"" quotes"
 S S3="" ; empty
 S S4="multi word string with: punctuation; and ?marks!"
 ;
 ; --- arithmetic operators ----------------------------------------
 W A+B,!                 ; addition
 W B-C,!                 ; subtraction
 W B*D,!                 ; multiplication
 W B/D,!                 ; division
 W B\3,!                 ; integer division
 W B#7,!                 ; modulo
 W 2**8,!                ; power
 W -B,!                  ; unary minus
 W +B,!                  ; unary plus (numeric coerce)
 ;
 ; --- string operator ---------------------------------------------
 W "a"_"b"_"c",!         ; concatenation
 ;
 ; --- relational --------------------------------------------------
 W A=B,!                 ; equal
 W A<B,!                 ; less than
 W A>B,!                 ; greater than
 W S1["impl",!           ; contains
 W S1]"a",!              ; follows lexically
 W S1]]"a",!             ; sorts after canonically
 ;
 ; --- logical -----------------------------------------------------
 W A&B,!                 ; AND
 W A!B,!                 ; OR
 W 'A,!                  ; NOT (unary)
 ;
 ; --- negated comparisons (compound, single operator node) -------
 ; Note: real M is written with no space around operators — the
 ; compound forms `'[`, `']`, `']]` lex as a single operator token
 ; only when the rhs follows immediately.
 W A'=B,!
 W A'<B,!
 W A'>B,!
 W S1'["z",!
 W S1'](S1_"a"),!
 W S1']]"z",!
 W A'&B,!
 W A'!B,!
 ;
 ; --- YDB / IRIS shorthands ---------------------------------------
 W A>=B,!                ; sugar for '<
 W A<=B,!                ; sugar for '>
 W A!=B,!                ; sugar for '=
 ;
 Q
