IND ;tree-sitter-m: indirection, extrinsic calls, globals, format control
 ; Exercises @function (extrinsic_function children + entry_reference
 ; children + numeric_label_call), @variable (global_variable),
 ; @operator (the `@` of indirection + format_control + format_tab).
 ;
 ; --- name indirection --------------------------------------------
 ; `@expr` substitutes the name. The `@` is its own operator node.
 S NAME="X"
 S @NAME=42                       ; sets X
 W @NAME,!                        ; reads X
 W "indirected: ",@NAME,!
 ;
 ; --- subscript indirection ---------------------------------------
 ; `@expr@(subs)` — the second `@` is also an operator marker.
 S G="^GBL"
 S @G@("a")=1
 S @G@("a","b")=2
 W @G@("a"),!
 ;
 ; --- nested indirection (@@) -------------------------------------
 S NM1="NM2",NM2="X"
 W @@NM1,!                        ; resolves NM1→NM2→X
 ;
 ; --- indirection in entry_reference ------------------------------
 S RTN="OTHER"
 D LABEL^@RTN                     ; routine slot is indirection
 D @("LABEL^"_RTN)                ; the whole entry-ref via indirection
 ;
 ; --- globals -----------------------------------------------------
 ; ^G — global_variable node. With or without subscripts, with leading %.
 S ^GBL=1
 S ^GBL("alpha")=2
 S ^GBL("a","b","c")=3
 S ^%SYS=99                       ; system global with %
 W ^GBL,^GBL("alpha"),^%SYS,!
 ;
 ; --- naked global reference --------------------------------------
 ; After ^GBL("a","b"), `^("c")` means ^GBL("a","c").
 S ^GBL("x","y")=10
 S ^("z")=20                      ; naked — same parent as previous
 W ^GBL("x","y"),^GBL("x","z"),!
 ;
 ; --- system globals (^$JOB / ^$ROUTINE) --------------------------
 W $D(^$JOB),!
 W $D(^$ROUTINE("OTHER")),!
 ;
 ; --- extrinsic function calls ------------------------------------
 ; `$$LABEL[^RTN][(args)]` — the LABEL and RTN are @function nodes.
 S V1=$$CALC                      ; local label
 S V2=$$CALC(1,2)                 ; with args
 S V3=$$CALC^MATH                 ; with routine
 S V4=$$CALC^MATH(1,2)            ; with both
 S V5=$$^MATH                     ; routine entry, no label
 S V6=$$^MATH(1,2)
 S V7=$$@RTN                      ; routine via indirection
 S V8=$$@("CALC^"_RTN)
 S V9=$$12^MATH(1)                ; numeric label call
 W V1,V2,V3,V4,V5,V6,V7,V8,V9,!
 ;
 ; --- numeric local-label call ------------------------------------
 ; `D 12(arg)` — numeric_label_call (number → @function).
 D 12(5)
 D 100
 ;
 ; --- entry references in DO / GOTO -------------------------------
 D LABEL                          ; local label
 D LABEL^OTHER                    ; with routine
 D LABEL^OTHER(A,B)               ; with args
 D ^OTHER                         ; routine only
 G LATER:X>0                      ; with postcond
 ;
 ; --- format control in WRITE -------------------------------------
 ; `!` newline, `#` page eject, `?N` tab to column, `*N` write char.
 W !                              ; newline only
 W #                              ; page eject
 W ?20,"col 20",!                 ; format_tab
 W ?(20+5),"col 25",!             ; format_tab with expression
 W *65,*66,*67,!                  ; ASCII A,B,C
 W "x",!,"y",!,"z",!
 W ?5,"indent",?20,"col20",!
 ;
 Q
LABEL ; jump target with no formals
 W "label hit",!
 Q
LATER ; another target
 W "later hit",!
 Q
12 ; numeric label
 W "twelve hit",!
 Q
100 ; another numeric label
 W "hundred hit",!
 Q
CALC(A,B) ; extrinsic
 Q (A+B)*2
