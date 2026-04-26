FUNC ;tree-sitter-m: intrinsic functions and special variables
 ; Exercises @function (defaultLibrary) and @variable (defaultLibrary, readonly).
 ; What to look for:
 ;   - $A, $C, $D, $EXTRACT, etc. should colour as @function (typically
 ;     a "library function" style — yellow / gold in many themes).
 ;   - $H, $I, $J, $X, $Y, $ZJOB etc. should colour as a defaultLibrary
 ;     readonly variable (often italic or with a "constant" tint).
 ;
 ; --- string functions --------------------------------------------
 W $ASCII("A"),!         ; → 65
 W $CHAR(65,66,67),!     ; → "ABC"
 W $EXTRACT("hello",2,4),!
 W $FIND("hello","ll"),!
 W $JUSTIFY("x",5),!
 W $LENGTH("hello"),!
 W $PIECE("a^b^c","^",2),!
 W $REVERSE("hello"),!
 W $TRANSLATE("hello","l","L"),!
 ;
 ; --- math / numeric ----------------------------------------------
 W $RANDOM(100),!
 W $INCREMENT(^CTR),!
 W $FNUMBER(1234.567,",",2),!
 ;
 ; --- structure ---------------------------------------------------
 W $DATA(^GBL),!
 W $GET(^GBL("missing"),"default"),!
 W $ORDER(^GBL("")),!
 W $QUERY(^GBL("")),!
 W $NEXT(^GBL("")),!     ; deprecated but recognised
 ;
 ; --- list functions (YDB / IRIS) ---------------------------------
 W $LIST($LISTBUILD(1,2,3),2),!
 W $LISTBUILD("a","b","c"),!
 W $LISTLENGTH($LISTBUILD(1,2,3)),!
 W $LISTGET($LISTBUILD(1,2,3),2),!
 ;
 ; --- system / introspection --------------------------------------
 W $NAME(^GBL("a","b")),!
 W $QLENGTH("^GBL(1,2,3)"),!
 W $QSUBSCRIPT("^GBL(1,2,3)",2),!
 W $SELECT(X>0:"pos",X<0:"neg",1:"zero"),!
 W $TEST,!
 W $TEXT(+0),!
 W $VIEW(0),!
 ;
 ; --- IRIS / YDB Z* functions -------------------------------------
 W $ZABS(-5),!
 W $ZBITAND($ZBITSTR(8,1),$ZBITSTR(8,0)),!
 W $ZCONVERT("hello","U"),!
 W $ZDATE($H),!
 W $ZFIND("hello","l",1,1),!
 W $ZSEARCH("*.m"),!
 W $ZTRANSLATE("hello","el","EL"),!
 ;
 ; --- abbreviated forms (parser handles every prefix) -------------
 W $A("X"),$E("hi",1,1),$L("hi"),$P("a^b","^",1),!
 ;
 ; --- intrinsic special variables (no parens) ---------------------
 W "$D=",$D,!            ; ambiguous: $D() is $DATA, bare $D is $DEVICE
 W "$ECODE=",$ECODE,!
 W "$ESTACK=",$ESTACK,!
 W "$ETRAP=",$ETRAP,!
 W "$H=",$H,!
 W "$HOROLOG=",$HOROLOG,!
 W "$I=",$I,!            ; $IO
 W "$J=",$J,!            ; $JOB
 W "$K=",$K,!            ; $KEY
 W "$P=",$P,!            ; $PRINCIPAL — ambiguous with $P() = $PIECE
 W "$Q=",$Q,!            ; $QUIT
 W "$ST=",$ST,!          ; $STACK or $STORAGE — ambiguous
 W "$STORAGE=",$STORAGE,!
 W "$SY=",$SY,!          ; $SYSTEM
 W "$T=",$T,!            ; $TEST
 W "$TLEVEL=",$TLEVEL,!
 W "$X=",$X,!
 W "$Y=",$Y,!
 ;
 ; --- IRIS / YDB Z-special variables ------------------------------
 W "$ZJOB=",$ZJOB,!
 W "$ZNAME=",$ZNAME,!
 W "$ZNSPACE=",$ZNSPACE,!
 W "$ZPI=",$ZPI,!
 W "$ZPOS=",$ZPOS,!
 W "$ZTIMEZONE=",$ZTIMEZONE,!
 W "$ZTRAP=",$ZTRAP,!
 W "$ZVERSION=",$ZVERSION,!
 ;
 Q
