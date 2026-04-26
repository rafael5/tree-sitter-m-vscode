CMDS ;tree-sitter-m: every command keyword
 ; Exercises @keyword.
 ; What to look for: every uppercase command at column 1 below should
 ; pick up the @keyword semantic-token colour. Argless and argful
 ; forms should both colour the keyword (not the argument).
 ;
 ; --- ANSI commands (canonical forms) -----------------------------
 BREAK
 CLOSE 1
 DO ^OTHER
 ELSE  WRITE "no"
 FOR I=1:1:5 DO
 . WRITE I,!
 GOTO LATER
 HALT
 HANG 1
 IF X=1 WRITE "yes"
 JOB ^WORKER
 KILL X,Y,Z
 LOCK +^ALPHA
 MERGE A=B
 NEW X,Y
 OPEN 1
 QUIT
 READ X
 SET X=1,Y=2
 TCOMMIT
 TRESTART
 TROLLBACK
 TSTART
 USE 1
 VIEW
 WRITE "x"
 XECUTE "S X=1"
 ;
 ; --- IRIS extensions ---------------------------------------------
 CATCH EX
 CONTINUE
 ELSEIF X=2 WRITE "two"
 PRINT
 RETURN X
 THROW
 TRY
 WHILE X<10 SET X=X+1
 ;
 ; --- ANSI but rare-used ------------------------------------------
 ABLOCK ^GLO
 ASSIGN
 ASTART
 ASTOP
 AUNBLOCK ^GLO
 ESTART
 ESTOP
 ETRIGGER
 KSUBSCRIPTS
 KVALUE
 RLOAD
 RSAVE
 THEN
 ;
 ; --- Z extensions (YDB / IRIS / multi-vendor) --------------------
 ZALLOCATE ^X
 ZBREAK
 ZCOMPILE
 ZCONTINUE
 ZDEALLOCATE ^X
 ZEDIT
 ZGOTO
 ZHALT
 ZHELP
 ZINSERT
 ZKILL
 ZLINK
 ZLOAD
 ZMESSAGE
 ZNSPACE
 ZPRINT
 ZREMOVE
 ZRUPDATE
 ZSAVE
 ZSHOW
 ZSTEP
 ZSU
 ZSYSTEM
 ZTCOMMIT
 ZTRAP
 ZTRIGGER
 ZTSTART
 ZWITHDRAW
 ZWRITE
 ZYDECODE
 ZYENCODE
 ZZDUMP
 ZZPRINT
 ZZWRITE
 Z
 Q
LATER ; jump target
 W "later",!
 Q
