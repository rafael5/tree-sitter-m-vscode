PAT ;tree-sitter-m: pattern matching, postconditionals, dot blocks
 ; Exercises @keyword (defaultLibrary) on pattern letters,
 ; @keyword on the `:` of a postconditional, @operator on dot-block
 ; prefixes (the leading `.` / `..`).
 ;
 ; --- standard pattern codes (A C E L N P U) ----------------------
 ; Each letter-code is its own pattern_letter node — the highlighter
 ; lights every letter individually so multi-letter codes like 1ANP
 ; show three coloured letters in a row.
 ;
 I "ABC"?3U W "3 upper",!
 I "abc"?3L W "3 lower",!
 I "Abc1"?1U2L1N W "Title-case + digit",!
 I "12345"?5N W "5 digits",!
 I "John Doe"?1U.L1" "1U.L W "First Last",!
 I "abc XYZ"?1.E W "any char any count",!
 I "@#$%"?4P W "4 punctuation",!
 I "  "?2C W "2 control chars",!
 ;
 ; --- multi-letter pattern codes (YDB / IRIS / VistA dialect) -----
 ; "?.ANP" means any number of A-N-P — three pattern_letter nodes
 ; in a row.
 ;
 I "Hello123!"?.ANP W "alpha+numeric+punct any",!
 I "X42"?1A1.AN W "letter then alphanumeric",!
 ;
 ; --- pattern alternation -----------------------------------------
 I "yes"?1(1"yes",1"no",1"maybe") W "matches one of three",!
 I "1+2"?1(1.N,1"+",1.N) W "expression-shape",!
 ;
 ; --- negated pattern match (the `'?` on the match operator) ------
 I "ABC"'?3N W "not 3 digits",!
 ;
 ; --- pattern with indirection ------------------------------------
 S PAT="3U"
 I "ABC"?@PAT W "matches indirected pattern",!
 ;
 ; --- command postconditionals ------------------------------------
 ; The colon between the keyword and the condition is a @keyword
 ; (treated as part of the postcond syntax), so it should colour
 ; differently from a normal arithmetic colon.
 S X=5
 W:X>0 "positive",!
 W:X<0 "negative",!
 D:X=5 SUB1
 Q:X<0
 K:X=0 X
 ;
 ; --- per-argument postconditionals -------------------------------
 ; DO/GOTO accept `:cond` on each argument: D LBL:cond,LBL2:cond2
 D SUB1:X>0,SUB2:X>5
 G SUB1:X=0,SUB2:X=99
 ;
 ; --- dot blocks (single + nested) --------------------------------
 ; The leading dots before each line are dot_block_prefix → @operator.
 F I=1:1:3 D
 . W "outer ",I,!
 . I I=2 D
 . . W "  middle",!
 . . F J=1:1:2 D
 . . . W "    inner ",J,!
 . . . W "    still inner",!
 ;
 ; --- dot block with command on the same line ---------------------
 F K=1:1:2 D
 . S TMP=K*10  W "tmp=",TMP,!
 ;
 Q
SUB1 W "sub1",! Q
SUB2 W "sub2",! Q
