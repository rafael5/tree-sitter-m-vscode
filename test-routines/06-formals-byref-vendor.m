FORMS ;tree-sitter-m: formals, by-reference, vendor SV extensions
 ; Exercises @parameter (formals + by_reference identifiers),
 ; @variable (defaultLibrary, readonly) on Kernel-style vendor SVs,
 ; @keyword on the `:` of postconditionals.
 ;
 ; The label here has formals — A, B, C should colour as @parameter
 ; (with the `declaration` modifier — themes that distinguish
 ; declaration-site parameters often italicise them).
 ;
 ; --- formals on the routine label and on local labels -----------
 ; Already declared: FORMS has none; LATER below has (A,B).
 ; CALC has (X,Y,Z).
 ;
 N RES,X,Y,Z
 S X=10,Y=20,Z=30
 ;
 ; --- pass-by-reference in DO and extrinsic calls ----------------
 ; `.VAR` — by_reference; the identifier inside should colour as
 ; @parameter (without declaration modifier — usage site).
 D MUTATE(.X,.Y,.Z)
 W "after mutate: X=",X," Y=",Y," Z=",Z,!
 ;
 S RES=$$ADDOUT(.X,1,2)           ; .X is by-ref; "1" and "2" are not
 W "RES=",RES,! W "X (mutated)=",X,!
 ;
 ; --- by-reference via indirection -------------------------------
 ; The grammar accepts `.identifier` and `.@expr` for pass-by-ref
 ; (you don't pass globals by-ref in M — they're already by-name).
 S NM="X"
 D MUTATE(.@NM,.Y,.Z)             ; pass X by reference via indirection
 W "X again: ",X,!
 ;
 ; --- Kernel-style vendor special-variable extensions -------------
 ; In real VistA, $PD and $PT are Kernel local-var idiom extending
 ; the special-variable space. The grammar recognises these as
 ; vendor_sv_extension (different node type from special_variable_keyword
 ; but mapped to the same @variable defaultLibrary/readonly scope).
 ; If you don't see them coloured the same as $X / $Y, the vendor
 ; extension recognition isn't firing.
 ;
 W $PD,!                          ; Kernel vendor SV
 W $PT,!                          ; Kernel vendor SV
 ;
 ; --- IRIS / YDB Z* commands as a refresher (also keyword) -------
 ZWRITE X,Y,Z
 ZSHOW "S"
 ;
 Q
;
LATER(A,B) ; formals A and B → @parameter (declaration)
 W "A=",A," B=",B,!
 Q (A+B)
;
CALC(X,Y,Z) ; formals X Y Z → @parameter (declaration)
 Q X+Y+Z
;
MUTATE(P,Q,R) ; by-ref formals; assigns through to caller's vars
 S P=P*10,Q=Q*10,R=R*10
 Q
;
ADDOUT(OUT,A,B) ; OUT is by-ref output, A B are inputs
 S OUT=A+B*100
 Q OUT*2
;
