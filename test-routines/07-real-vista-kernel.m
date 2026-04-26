DEMO ;tree-sitter-m: realistic VistA Kernel-style routine
 ;;1.0;TREE-SITTER-M;**1**;APR 26, 2026;Build 1
 ;
 ; Kitchen-sink test: a real-looking VistA Kernel routine that
 ; exercises every aspect of the highlighter in one place. Every
 ; semantic-token category our provider knows about should appear
 ; somewhere in this file. Use this as your "if everything looks
 ; right here, the plug-in is working" check.
 ;
 ; What you should see:
 ;   * the doubled-semicolon doc-comment header above (the
 ;     ";;1.0;..." line) → @comment (themes often distinguish
 ;     section / doc comments, but ours treat both as @comment).
 ;   * commands: N, K, S, I, F, D, W, Q, MERGE, LOCK, etc.
 ;   * intrinsic functions: $D, $G, $L, $P, $E, $$, $S
 ;   * special variables: $X, $Y, $H, $J, $T
 ;   * Kernel vendor SVs: $PD, $PT (vendor_sv_extension)
 ;   * extrinsic + entry refs: $$ADD^MATH, ^XUSESIG, etc.
 ;   * by-ref params: .X, .Y, .RESULT
 ;   * naked global refs: ^("...")
 ;   * pattern match incl. multi-letter codes: ?1A.AN
 ;   * postconditional + per-arg postcond
 ;   * dot blocks: . W I, . . F J=...
 ;   * indirection: @NAME, @NAME@(SUBS)
 ;   * format control: !, #, ?40, *65
 ;
 N DFN,IEN,DA,X,Y,Z,RESULT,LIST,ITEM
 ;
 ; lookup pattern that any VistA file-handling routine would have
 S DFN=$G(^DPT(IEN,0)) Q:DFN=""
 S NAME=$P(DFN,U,1)
 S DOB=$P(DFN,U,3)
 ;
 ; field extraction with naked global navigation
 S ^DPT(IEN,0)="Smith,John^M^2940101"
 S ^("KEY")="lookup"           ; naked: ^DPT(IEN,"KEY")
 S X=$$AGE^XLFDT(DOB,DT)
 ;
 ; pattern matching (Kernel idiom for "valid SSN")
 S SSN="123-45-6789"
 I SSN?3N1"-"2N1"-"4N W "valid SSN format",!
 ;
 ; multi-letter pattern: any number of alpha+numeric+punctuation
 I NAME?1A.ANP W "name shape ok",!
 ;
 ; dot block over a list with nested control flow
 S LIST=$LISTBUILD("alpha","beta","gamma")
 F I=1:1:$LISTLENGTH(LIST) D
 . S ITEM=$LISTGET(LIST,I)
 . W ?5,I,") ",ITEM,!
 . I ITEM["beta" D
 . . W ?10,"(matched beta)",!
 . . F J=1:1:3 W ?15,"j=",J,!
 ;
 ; postconditionals — command-level and per-arg
 W:$D(^DPT(IEN)) "patient exists",!
 D:DT>0 PROCESS,FINISH:RESULT>0
 Q:'$D(^DPT(IEN))
 ;
 ; transaction
 TSTART
 S ^DPT(IEN,0,"AUDIT",$H)="modified by "_$J
 TCOMMIT
 ;
 ; locks (multi-target, +/- variants)
 LOCK +^DPT(IEN):5
 LOCK -^DPT(IEN)
 LOCK +(^DPT(IEN),^XUSER($J))
 ;
 ; merge
 MERGE ^XTMP("WORK")=^DPT(IEN)
 ;
 ; intrinsic-rich expression with operators
 S RESULT=$S($D(X):X*2,1:0)+$L(NAME)*$LISTLENGTH(LIST)
 S RESULT=RESULT_$E(NAME,1,3)_$P("a^b^c","^",2)
 ;
 ; format-control-rich WRITE
 W !,?10,"== Patient Report ==",!
 W ?5,"DFN: ",DFN,!
 W ?5,"Name: ",NAME,!
 W ?5,"DOB: ",DOB,!
 W ?5,"Age: ",X," (as of $H=",$H,")",!
 W #,*65,*66,*67,!         ; eject + write A B C as chars
 ;
 ; vendor SV extensions (Kernel-flavoured)
 W "TermType: ",$PD,!
 W "DeviceParm: ",$PT,!
 ;
 ; indirection (name + subscript variants)
 S NM="^DPT"
 S @NM@(IEN,"FLAG")=1
 W @NM@(IEN,"FLAG"),!
 S NM2="NAME"
 W "Name via @@: ",@NM2,!
 ;
 ; extrinsic call with by-ref output
 S RESULT=0
 D ADDOUT^MATH(.RESULT,X,$LISTLENGTH(LIST))
 W "Computed: ",RESULT,!
 ;
 ; numeric local-label call (rare but legal)
 D 99
 ;
 ; YDB / IRIS Z extensions in a real-world spot
 ZWRITE LIST
 ZSHOW "S":^XTMP("DEBUG")
 ;
 Q
;
PROCESS ; helper
 W "processing...",!
 S RESULT=$RANDOM(100)
 Q
;
FINISH(N) ; helper with formals
 W "finished with ",N,!
 Q
;
99 ; numeric local label
 W "ninety-nine reached",!
 Q
