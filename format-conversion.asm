DATA SEGMENT;定义数据段
	MENU1 DB "********************************************************************************"
	MENU2 DB "*                            convertion scale number                           *"
	MENU3 DB "*                                                                              *"
	MENU4 DB "*                           [1] binary to decimal                              *"
	MENU5 DB "*                           [2] binary to hexadecimal                          *"
	MENU6 DB "*                           [3] decimal to binary                              *"
	MENU7 DB "*                           [4] decimal to hexadecimal                         *"
	MENU8 DB "*                           [5] hexadecimal to binary                          *"
	MENU9 DB "*                           [6] hexadecimal to decimal                         *"
	MENU10 DB "*                           [0] quit                                           *"
	MENU11 DB "*                                                                              *"
	MENU12 DB "*                                                                              *"
	MENU13 DB "* binary within 16bit      decimal within 65535       hexadecimal within FFFFH *"
	MENU14 DB "*                  tip:input number to select the application                  *"
	MENU15 DB "********************************************************************************"
	BO DB "binary number:           "
	DO DB "decimal number:          "
	HO DB "hexadecimal number:      "
	BINF DB "please input a binary number (End with B) "
	DINF DB "please input a decimal number (End with D) "
	HINF DB "please input a hexadecimal number (End with H) "
	ENDINF DB "please enter any key to continue"
	INERROR DB "input error"
	INOVERFLOW DB "input overflow"
	NUM DB 4 DUP(?)	;数据位
	LENGTHS DB 0	;数据长度
	JUDGE DB 0	;输入错误判断
DATA ENDS

CODE SEGMENT;定义代码段
	ASSUME CS:CODE,DS:DATA
;BINPUT---------------------------------------------------------------------------------------------------
;二进制输入
BINPUT PROC NEAR
	MOV CX,4
	MOV DI,0
	MOV AL,0
BINITNUM:
	MOV NUM[DI],AL;初始化NUM数据
	INC DI
LOOP BINITNUM
	MOV AL,LENGTHS
	MOV AL,0
	MOV LENGTHS,AL;初始化NUM长度信息

	;输出提示信息
	MOV CX,41
	MOV DI,0
OUTBINF:
	MOV DL,BINF[DI];输出提示信息
	INC DI
	MOV AH,2
	INT 21H
LOOP OUTBINF

	MOV DX,0205H ;预置光标的位置，DH行 	DL列
	MOV AH,2
	INT 10H

	;输入
	MOV DI,0
	MOV DX,0
	MOV BL,0
	MOV CL,0
INBNUM:
	MOV AH,1
	INT 21H
	CMP AL,'B'
	JZ BC
	CMP AL,'0'
	JB BOUTE
	CMP AL,'1'
	JG BOUTE
	CMP DH,15
	JG BOUTE2
	INC DH
	PUSH AX   ;保护输入的AL
	MOV AL,2  
	MUL CL
	MOV CL,AL
	POP AX
	ADD CL,AL
	SUB CL,'0'
	INC BL
	;每四个一组转换十六进制
	CMP BL,4
	JNZ BCONTINUE  ;未满4个有两种情况(1)需要继续输入(2)结尾B单独一组
	MOV NUM[DI],CL ;填入数据位
	MOV DL,LENGTHS
	INC DL
	MOV LENGTHS[0],DL
	INC DI
	MOV BL,0
	MOV CL,0
	JMP BC
BCONTINUE:
BC:
	CMP AL,'B';判断是否结束
	JNZ INBNUM

	MOV DL,0AH
	MOV AH,2
	INT 21H
	MOV DL,0DH
	MOV AH,2
	INT 21H
	MOV AL,0
	JMP BQUIT
BOUTE: ;输入错误信息提示
	MOV DX,0405H
	MOV AH,2
	INT 10H
	MOV CX,11;循环11次
	MOV DI,0
OUTBE:
	MOV DL,INERROR[DI]
	INC DI
	MOV AH,2
	INT 21H
LOOP OUTBE
	MOV AL,1
	JMP BQUIT
BOUTE2: ;输入错误信息提示
	MOV DX,0405H
	MOV AH,2
	INT 10H
	MOV CX,14;循环14次
	MOV DI,0
OUTBE2:
	MOV DL,INOVERFLOW[DI]
	INC DI
	MOV AH,2
	INT 21H
LOOP OUTBE2
	MOV DL,0AH
	MOV AH,2
	INT 21H
	MOV DL,0DH
	MOV AH,2
	INT 21H

	MOV AL,1
BQUIT:
	MOV JUDGE,AL
RET
BINPUT ENDP



;DINPUT---------------------------------------------------------------------------------------------------
;十进制输入
DINPUT PROC NEAR
	MOV CX,4;循环四次
	MOV DI,0
	MOV AL,0
DINITNUM:;初始化数据位
	MOV NUM[DI],AL
	INC DI
LOOP DINITNUM
	MOV AL,LENGTHS
	MOV AL,0
	MOV LENGTHS,AL;初始化数据长度
	;输出提示信息

	MOV CX,42
	MOV DI,0
OUTDINF:;输出提示信息
	MOV DL,DINF[DI]
	INC DI
	MOV AH,2
	INT 21H
LOOP OUTDINF

	MOV DX,0205H
	MOV AH,2
	INT 10H

	;输入
	MOV DI,0
	MOV DL,0
	MOV CX,0
INDNUM:
	MOV AH,1
	INT 21H
	;十进制输入限制
	CMP AL,'D';D/space结尾都会结束
	JZ DC
	CMP AL,13
	JZ DC
	CMP AL,'0';0~9之外报错
	JB DOUTE
	CMP AL,'9'
	JG DOUTE
	MOV DX,0 ;CX=CX*10+AX
	PUSH AX
	MOV AX,10
	MUL CX
	MOV CX,AX
	POP AX
	SUB AL,'0'
	ADD CL,AL
	JO DOUTE2	
	ADC CH,0 
	JMP INDNUM ;一直输入到结束为止，然后转16为存放	
DC:	MOV AX,CX;设置好被除数DXAX
	MOV DX,0
	MOV DI,3
	MOV BX,16
HCONT:
	DIV BX
	MOV NUM[DI],DL;存入数据位,除数倒叙存入N[3]-->N[2]-->N[1]--->N[0]
	MOV DX,0
	SUB DI,1
	CMP AX,0;看商是否是0
	JNZ HCONT
	MOV AL,4
	MOV LENGTHS,AL

	MOV DL,0AH;换行
	MOV AH,2
	INT 21H
	MOV DL,0DH
	MOV AH,2
	INT 21H
	MOV AL,0
	JMP DQUIT
DOUTE:;错误信息提示
	MOV DX,0405H
	MOV AH,2
	INT 10H
	MOV CX,11
	MOV DI,0
OUTDE:
	MOV DL,INERROR[DI]
	INC DI
	MOV AH,2
	INT 21H
LOOP OUTDE
	MOV DL,0AH
	MOV AH,2
	INT 21H
	MOV DL,0DH
	MOV AH,2
	INT 21H
	JMP DQUIT
DOUTE2: ;输入错误信息提示
	MOV DX,0405H
	MOV AH,2
	INT 10H
	MOV CX,14;循环14次
	MOV DI,0
OUTDE2:
	MOV DL,INOVERFLOW[DI]
	INC DI
	MOV AH,2
	INT 21H
LOOP OUTDE2
	MOV DL,0AH
	MOV AH,2
	INT 21H
	MOV DL,0DH
	MOV AH,2
	INT 21H


	MOV AL,1
DQUIT:
	MOV JUDGE,AL;跟新输入错误判断位(错误AL=1)
RET
DINPUT ENDP

;HINPUT---------------------------------------------------------------------------------------------------
;十六进制输入
HINPUT PROC NEAR
	MOV CX,4
	MOV DI,0
	MOV AL,0
HINITNUM:;初始化数据位
	MOV NUM[DI],AL
	INC DI
LOOP HINITNUM
	MOV AL,LENGTHS
	MOV AL,0
	MOV LENGTHS,AL;初始化数据长度

	;输出提示信息
	MOV CX,46
	MOV DI,0
OUTHINF:;输出提示信息
	MOV DL,HINF[DI]
	INC DI
	MOV AH,2
	INT 21H
LOOP OUTHINF
	MOV DX,0205H
	MOV AH,2
	INT 10H

	;输入
	MOV DX,0
	MOV DI,0
	MOV DL,0
	MOV CX,0
INHNUM:;十六进制的输入限制
	MOV AH,1
	INT 21H
	CMP AL,'H'
	JZ HC
	CMP DH,3
	JG HOUTE2
	CMP AL,'9'
	JNG LADD
	CMP AL,'H'
	JNG HADD
LADD:;0~9数据存入数据位
	CMP AL,'0'
	JB HOUTE
	SUB AL,'0'
	MOV NUM[DI],AL
	INC DH
	JMP HC
HADD:;A~F数据存入数据位
	CMP AL,'A'
	JB HOUTE
	SUB AL,'A'
	ADD AL,10
	MOV NUM[DI],AL
	INC DH
HC:
	INC DI;DI++
	MOV BL,LENGTHS;LENGTHS++
	INC BL
	MOV LENGTHS,BL
	CMP AL,'H';判断是否结尾
	JNZ INHNUM
	MOV AL,LENGTHS;H也会让LENGTHS++,所以－1
	SUB AL,1
	MOV LENGTHS,AL
	MOV DL,0AH
	MOV AH,2
	INT 21H
	MOV DL,0DH
	MOV AH,2
	INT 21H
	MOV AL,0
	JMP HQUIT

HOUTE: ;输入错误信息提示
	MOV DX,0405H
	MOV AH,2
	INT 10H
	MOV CX,11;循环11次
	MOV DI,0
OUTBE:
	MOV DL,INERROR[DI]
	INC DI
	MOV AH,2
	INT 21H
LOOP OUTBE
	MOV AL,1
	JMP HQUIT
HOUTE2: ;输入错误信息提示
	MOV DX,0405H
	MOV AH,2
	INT 10H
	MOV CX,14;循环14次
	MOV DI,0
OUTBE2:
	MOV DL,INOVERFLOW[DI]
	INC DI
	MOV AH,2
	INT 21H
LOOP OUTBE2
	MOV DL,0AH
	MOV AH,2
	INT 21H
	MOV DL,0DH
	MOV AH,2
	INT 21H

	MOV AL,1
HQUIT:
	MOV JUDGE,AL
RET

HINPUT ENDP

;BOUTPUT---------------------------------------------------------------------------------------------------
;二进制输出
BOUTPUT PROC NEAR
	MOV AL,JUDGE;根据输入错误判断位选择是否输出，1代表出错了 0代表没出错
	CMP AL,1
	JZ BOEND
	MOV CL,LENGTHS;存了NUM数组几位，循环几次
	MOV AX,0
	MOV DI,0
GETHNUM:;循环将数据数据读取到AX，当前AL=0;
	MOV BX,16
	MUL BX
	MOV BL,NUM[DI]
	MOV DL,NUM[DI];()
	INC DI
	ADD AL,BL
	ADC AH,0
LOOP GETHNUM

	MOV DX,0
	MOV DI,0
	MOV BX,2
BCONT:;将AX连续除二
	DIV BX
	PUSH DX;余数压栈,存数据
	MOV DX,0
	INC DI ;记录被压栈几次
	CMP AX,0
	JNZ BCONT

	MOV DX,0405H;输出显示位置
	MOV AH,2
	INT 10H
	
	MOV CX,25;循环25次
	MOV BX,0
	MOV AH,2
BIOUT:;输出数据类型提示
	MOV DL,BO[BX]
	INT 21H
	INC BL
LOOP BIOUT

BOUT:;以二进制形式输出
	POP DX;出栈获取数据
	ADD DL,'0'
	;MOV AH,2
	;INT 21H
	
	
	mov ah,09h
    mov al,dl  ;显示的字符
    mov cx,1    ;字符显示数量
    mov bl,04h ;字符颜色信息
    mov bh,00  ;页码设置
    int 10h    ;在当前光标处显示一个背景色为黑色，前景色为红色的字符
    MOV AH,03H
    INT 10H
    INC DL
    MOV AH,02H
    INT 10H
	
	SUB DI,1
	CMP DI,0
	JNZ BOUT
	
	MOV DL,'B'
	MOV AH,2
	INT 21H
	MOV DL,0AH
	MOV AH,2
	INT 21H
	MOV DL,0DH
	MOV AH,2
	INT 21H
BOEND:
RET
	
BOUTPUT ENDP

;DOUTPUT---------------------------------------------------------------------------------------------------
;十进制输出
DOUTPUT PROC NEAR
	MOV AL,JUDGE;根据输入错误判断位选择是否输出
	CMP AL,1
	JZ DOEND
	MOV CL,LENGTHS
	MOV AX,0
	MOV DI,0
GETNUM:;将数据数据读取到AX
	MOV BX,16
	MUL BX
	MOV BL,NUM[DI]
	INC DI
	ADD AL,BL
	ADC AH,0
LOOP GETNUM

	MOV DX,0
	MOV DI,0
	MOV BX,10
CONTS:;将AX连续除十
	DIV BX
	PUSH DX;余数压栈,存数据
	MOV DX,0
	INC DI
	CMP AX,0
	JNZ CONTS

	MOV DX,0405H
	MOV AH,2
	INT 10H

	MOV CX,25
	MOV BX,0
	MOV AH,2
DIOUT:;输出信息类型提示
	MOV DL,DO[BX]
	INT 21H
	INC BL
LOOP DIOUT

DOUT:;以十进制形式输出
	POP DX;出栈获取数据
	ADD DL,'0'
	;MOV AH,2
	;INT 21H
	
	
	mov ah,09h
    mov al,dl  ;显示的字符
    mov cx,1    ;字符显示数量
    mov bl,04h ;字符颜色信息
    mov bh,00  ;页码设置
    int 10h    ;在当前光标处显示一个背景色为黑色，前景色为红色的字符
    MOV AH,03H
    INT 10H
    INC DL
    MOV AH,02H
    INT 10H
	
	
	
	SUB DI,1
	CMP DI,0
	JNZ DOUT
	
	MOV DL,'D'
	MOV AH,2
	INT 21H
	MOV DL,0AH
	MOV AH,2
	INT 21H
	MOV DL,0DH
	MOV AH,2
	INT 21H
DOEND:
RET
DOUTPUT ENDP

;HOUTPUT---------------------------------------------------------------------------------------------------
;十六进制输出
HOUTPUT PROC NEAR
	MOV AL,JUDGE;根据输入错误判断位选择是否输出
	CMP AL,1
	JZ HOEND
	MOV CX,25
	MOV DI,0
	MOV AH,2

	MOV DX,0405H
	MOV AH,2
	INT 10H

HIOUT:;输出信息类型提示
	MOV DL,HO[DI]
	INT 21H
	INC DI
LOOP HIOUT


	MOV CL,LENGTHS;获取数据长度
	MOV AX,0
	MOV DI,0

HOUT:;以十六进制形式输出
	MOV DL,NUM[DI]
	CMP DL,10
	JG TOH
	ADD DL,'0'
	JMP HNEXT
TOH:;A~F输出处理
	ADD DL,'A'
	SUB DL,10
HNEXT:
	;MOV AH,2
	;INT 21H
	
	PUSH CX
	mov ah,09h
    mov al,DL  ;显示的字符
    mov cx,1    ;字符显示数量
    mov bl,04h ;字符颜色信息
    mov bh,00  ;页码设置
    int 10h    ;在当前光标处显示一个背景色为黑色，前景色为红色的字符
    MOV AH,03H
    INT 10H
    INC DL
    MOV AH,02H
    INT 10H
    POP CX
	    
	INC DI
LOOP HOUT

	MOV DL,'H'
	MOV AH,2
	INT 21H
	MOV DL,0AH
	MOV AH,2
	INT 21H
	MOV DL,0DH
	MOV AH,2
	INT 21H
HOEND:
RET
HOUTPUT ENDP

;MYMENU---------------------------------------------------------------------------------------------------
;菜单
MYMENU PROC NEAR
	MOV AX,0003H; 80×25 彩色文本方式 
	INT 10H
	
	MOV CX,1200
	MOV DI,0
	MOV AH,2
SHOW:
	MOV DL,MENU1[DI]
	INT 21H
	INC DI
LOOP SHOW
	
RET
MYMENU ENDP

;INPUTMENU---------------------------------------------------------------------------------------------------
;输入边框
INPUTMENU PROC NEAR 
	MOV AX,0003H;清屏  
	INT 10H
	
	MOV DX,0000H
	MOV AH,2
	INT 10H
	MOV CX,80
IM:
	MOV AH,2
	MOV DL,'*'
	INT 21H
LOOP IM

	MOV CX,13
	MOV DH,13
IM2:
	MOV DL,0        
	MOV AH,2
	INT 10H
	MOV AH,2
	MOV DL,'*'
	INT 21H

	MOV DL,79
	MOV AH,2
	INT 10H
	MOV AH,2
	MOV DL,'*'
	INT 21H
	SUB DH,1
LOOP IM2

	MOV DX,0E00H
	MOV AH,2
	INT 10H
	MOV CX,80
IM15:
	MOV AH,2
	MOV DL,'*'
	INT 21H
LOOP IM15
	MOV DX,0105H
	MOV AH,2
	INT 10H
	

RET
INPUTMENU ENDP


START:
	MOV AX,DATA
	MOV DS,AX
BEGIN:
	CALL MYMENU
	MOV AH,1
	INT 21H
	CMP AL,'1';选择功能1
	JZ CASE1
	CMP AL,'2';选择功能2
	JZ CASE2
	CMP AL,'3';选择功能3
	JZ CASE3
	CMP AL,'4';选择功能4
	JZ CASE4
	CMP AL,'5';选择功能5
	JZ CASE5
	CMP AL,'6';选择功能6
	JZ CASE6
	CMP AL,'0';选择功能0
	JZ CASE0
	MOV AH,1
	INT 21H
	JMP BEGIN
CASE1:;功能1
	CALL INPUTMENU
	CALL BINPUT
	CALL DOUTPUT
	MOV DX,0505H
	MOV AH,2
	INT 10H
	MOV CX,32
	MOV DI,0
	MOV AH,2
ENDTIP1:;功能结束处理
	MOV DL,ENDINF[DI]
	INT 21H
	INC DI
LOOP ENDTIP1
	MOV AH,1
	INT 21H
	JMP BEGIN
CASE2:;功能2
	CALL INPUTMENU
	CALL BINPUT
	CALL HOUTPUT
	MOV DX,0505H
	MOV AH,2
	INT 10H
	MOV CX,32
	MOV DI,0
	MOV AH,2
ENDTIP2:;功能结束处理
	MOV DL,ENDINF[DI]
	INT 21H
	INC DI
LOOP ENDTIP2
	MOV AH,1
	INT 21H
	JMP BEGIN
CASE3:;功能3
	CALL INPUTMENU
	CALL DINPUT
	CALL BOUTPUT
	MOV DX,0505H
	MOV AH,2
	INT 10H
	MOV CX,32
	MOV AH,2
	MOV DI,0
ENDTIP3:;功能结束处理
	MOV DL,ENDINF[DI]
	INT 21H
	INC DI
LOOP ENDTIP3
	MOV AH,1
	INT 21H
	JMP BEGIN
CASE4:;功能4
	CALL INPUTMENU
	CALL DINPUT
	CALL HOUTPUT
	MOV DX,0505H
	MOV AH,2
	INT 10H
	MOV CX,32
	MOV DI,0
	MOV AH,2
ENDTIP4:;功能结束处理
	MOV DL,ENDINF[DI]
	INT 21H
	INC DI
LOOP ENDTIP4
	MOV AH,1
	INT 21H
	JMP BEGIN
CASE5:;功能5
	CALL INPUTMENU
	CALL HINPUT
	CALL BOUTPUT
	MOV DX,0505H
	MOV AH,2
	INT 10H
	MOV CX,32
	MOV DI,0
	MOV AH,2
ENDTIP5:;功能结束处理
	MOV DL,ENDINF[DI]
	INT 21H
	INC DI
LOOP ENDTIP5
	MOV AH,1
	INT 21H
	JMP BEGIN
CASE6:;功能6
	CALL INPUTMENU
	CALL HINPUT
	CALL DOUTPUT
	MOV DX,0505H
	MOV AH,2
	INT 10H
	MOV CX,32
	MOV DI,0
	MOV AH,2
ENDTIP6:;功能结束处理
	MOV DL,ENDINF[DI]
	INT 21H
	INC DI
LOOP ENDTIP6
	MOV AH,1
	INT 21H
	JMP BEGIN
CASE0:;功能0
	MOV AH,4CH
   	INT 21H
CODE ENDS
    END START








