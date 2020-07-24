DATA SEGMENT;�������ݶ�
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
	NUM DB 4 DUP(?)	;����λ
	LENGTHS DB 0	;���ݳ���
	JUDGE DB 0	;��������ж�
DATA ENDS

CODE SEGMENT;��������
	ASSUME CS:CODE,DS:DATA
;BINPUT---------------------------------------------------------------------------------------------------
;����������
BINPUT PROC NEAR
	MOV CX,4
	MOV DI,0
	MOV AL,0
BINITNUM:
	MOV NUM[DI],AL;��ʼ��NUM����
	INC DI
LOOP BINITNUM
	MOV AL,LENGTHS
	MOV AL,0
	MOV LENGTHS,AL;��ʼ��NUM������Ϣ

	;�����ʾ��Ϣ
	MOV CX,41
	MOV DI,0
OUTBINF:
	MOV DL,BINF[DI];�����ʾ��Ϣ
	INC DI
	MOV AH,2
	INT 21H
LOOP OUTBINF

	MOV DX,0205H ;Ԥ�ù���λ�ã�DH�� 	DL��
	MOV AH,2
	INT 10H

	;����
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
	PUSH AX   ;���������AL
	MOV AL,2  
	MUL CL
	MOV CL,AL
	POP AX
	ADD CL,AL
	SUB CL,'0'
	INC BL
	;ÿ�ĸ�һ��ת��ʮ������
	CMP BL,4
	JNZ BCONTINUE  ;δ��4�����������(1)��Ҫ��������(2)��βB����һ��
	MOV NUM[DI],CL ;��������λ
	MOV DL,LENGTHS
	INC DL
	MOV LENGTHS[0],DL
	INC DI
	MOV BL,0
	MOV CL,0
	JMP BC
BCONTINUE:
BC:
	CMP AL,'B';�ж��Ƿ����
	JNZ INBNUM

	MOV DL,0AH
	MOV AH,2
	INT 21H
	MOV DL,0DH
	MOV AH,2
	INT 21H
	MOV AL,0
	JMP BQUIT
BOUTE: ;���������Ϣ��ʾ
	MOV DX,0405H
	MOV AH,2
	INT 10H
	MOV CX,11;ѭ��11��
	MOV DI,0
OUTBE:
	MOV DL,INERROR[DI]
	INC DI
	MOV AH,2
	INT 21H
LOOP OUTBE
	MOV AL,1
	JMP BQUIT
BOUTE2: ;���������Ϣ��ʾ
	MOV DX,0405H
	MOV AH,2
	INT 10H
	MOV CX,14;ѭ��14��
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
;ʮ��������
DINPUT PROC NEAR
	MOV CX,4;ѭ���Ĵ�
	MOV DI,0
	MOV AL,0
DINITNUM:;��ʼ������λ
	MOV NUM[DI],AL
	INC DI
LOOP DINITNUM
	MOV AL,LENGTHS
	MOV AL,0
	MOV LENGTHS,AL;��ʼ�����ݳ���
	;�����ʾ��Ϣ

	MOV CX,42
	MOV DI,0
OUTDINF:;�����ʾ��Ϣ
	MOV DL,DINF[DI]
	INC DI
	MOV AH,2
	INT 21H
LOOP OUTDINF

	MOV DX,0205H
	MOV AH,2
	INT 10H

	;����
	MOV DI,0
	MOV DL,0
	MOV CX,0
INDNUM:
	MOV AH,1
	INT 21H
	;ʮ������������
	CMP AL,'D';D/space��β�������
	JZ DC
	CMP AL,13
	JZ DC
	CMP AL,'0';0~9֮�ⱨ��
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
	JMP INDNUM ;һֱ���뵽����Ϊֹ��Ȼ��ת16Ϊ���	
DC:	MOV AX,CX;���úñ�����DXAX
	MOV DX,0
	MOV DI,3
	MOV BX,16
HCONT:
	DIV BX
	MOV NUM[DI],DL;��������λ,�����������N[3]-->N[2]-->N[1]--->N[0]
	MOV DX,0
	SUB DI,1
	CMP AX,0;�����Ƿ���0
	JNZ HCONT
	MOV AL,4
	MOV LENGTHS,AL

	MOV DL,0AH;����
	MOV AH,2
	INT 21H
	MOV DL,0DH
	MOV AH,2
	INT 21H
	MOV AL,0
	JMP DQUIT
DOUTE:;������Ϣ��ʾ
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
DOUTE2: ;���������Ϣ��ʾ
	MOV DX,0405H
	MOV AH,2
	INT 10H
	MOV CX,14;ѭ��14��
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
	MOV JUDGE,AL;������������ж�λ(����AL=1)
RET
DINPUT ENDP

;HINPUT---------------------------------------------------------------------------------------------------
;ʮ����������
HINPUT PROC NEAR
	MOV CX,4
	MOV DI,0
	MOV AL,0
HINITNUM:;��ʼ������λ
	MOV NUM[DI],AL
	INC DI
LOOP HINITNUM
	MOV AL,LENGTHS
	MOV AL,0
	MOV LENGTHS,AL;��ʼ�����ݳ���

	;�����ʾ��Ϣ
	MOV CX,46
	MOV DI,0
OUTHINF:;�����ʾ��Ϣ
	MOV DL,HINF[DI]
	INC DI
	MOV AH,2
	INT 21H
LOOP OUTHINF
	MOV DX,0205H
	MOV AH,2
	INT 10H

	;����
	MOV DX,0
	MOV DI,0
	MOV DL,0
	MOV CX,0
INHNUM:;ʮ�����Ƶ���������
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
LADD:;0~9���ݴ�������λ
	CMP AL,'0'
	JB HOUTE
	SUB AL,'0'
	MOV NUM[DI],AL
	INC DH
	JMP HC
HADD:;A~F���ݴ�������λ
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
	CMP AL,'H';�ж��Ƿ��β
	JNZ INHNUM
	MOV AL,LENGTHS;HҲ����LENGTHS++,���ԣ�1
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

HOUTE: ;���������Ϣ��ʾ
	MOV DX,0405H
	MOV AH,2
	INT 10H
	MOV CX,11;ѭ��11��
	MOV DI,0
OUTBE:
	MOV DL,INERROR[DI]
	INC DI
	MOV AH,2
	INT 21H
LOOP OUTBE
	MOV AL,1
	JMP HQUIT
HOUTE2: ;���������Ϣ��ʾ
	MOV DX,0405H
	MOV AH,2
	INT 10H
	MOV CX,14;ѭ��14��
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
;���������
BOUTPUT PROC NEAR
	MOV AL,JUDGE;������������ж�λѡ���Ƿ������1��������� 0����û����
	CMP AL,1
	JZ BOEND
	MOV CL,LENGTHS;����NUM���鼸λ��ѭ������
	MOV AX,0
	MOV DI,0
GETHNUM:;ѭ�����������ݶ�ȡ��AX����ǰAL=0;
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
BCONT:;��AX��������
	DIV BX
	PUSH DX;����ѹջ,������
	MOV DX,0
	INC DI ;��¼��ѹջ����
	CMP AX,0
	JNZ BCONT

	MOV DX,0405H;�����ʾλ��
	MOV AH,2
	INT 10H
	
	MOV CX,25;ѭ��25��
	MOV BX,0
	MOV AH,2
BIOUT:;�������������ʾ
	MOV DL,BO[BX]
	INT 21H
	INC BL
LOOP BIOUT

BOUT:;�Զ�������ʽ���
	POP DX;��ջ��ȡ����
	ADD DL,'0'
	;MOV AH,2
	;INT 21H
	
	
	mov ah,09h
    mov al,dl  ;��ʾ���ַ�
    mov cx,1    ;�ַ���ʾ����
    mov bl,04h ;�ַ���ɫ��Ϣ
    mov bh,00  ;ҳ������
    int 10h    ;�ڵ�ǰ��괦��ʾһ������ɫΪ��ɫ��ǰ��ɫΪ��ɫ���ַ�
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
;ʮ�������
DOUTPUT PROC NEAR
	MOV AL,JUDGE;������������ж�λѡ���Ƿ����
	CMP AL,1
	JZ DOEND
	MOV CL,LENGTHS
	MOV AX,0
	MOV DI,0
GETNUM:;���������ݶ�ȡ��AX
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
CONTS:;��AX������ʮ
	DIV BX
	PUSH DX;����ѹջ,������
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
DIOUT:;�����Ϣ������ʾ
	MOV DL,DO[BX]
	INT 21H
	INC BL
LOOP DIOUT

DOUT:;��ʮ������ʽ���
	POP DX;��ջ��ȡ����
	ADD DL,'0'
	;MOV AH,2
	;INT 21H
	
	
	mov ah,09h
    mov al,dl  ;��ʾ���ַ�
    mov cx,1    ;�ַ���ʾ����
    mov bl,04h ;�ַ���ɫ��Ϣ
    mov bh,00  ;ҳ������
    int 10h    ;�ڵ�ǰ��괦��ʾһ������ɫΪ��ɫ��ǰ��ɫΪ��ɫ���ַ�
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
;ʮ���������
HOUTPUT PROC NEAR
	MOV AL,JUDGE;������������ж�λѡ���Ƿ����
	CMP AL,1
	JZ HOEND
	MOV CX,25
	MOV DI,0
	MOV AH,2

	MOV DX,0405H
	MOV AH,2
	INT 10H

HIOUT:;�����Ϣ������ʾ
	MOV DL,HO[DI]
	INT 21H
	INC DI
LOOP HIOUT


	MOV CL,LENGTHS;��ȡ���ݳ���
	MOV AX,0
	MOV DI,0

HOUT:;��ʮ��������ʽ���
	MOV DL,NUM[DI]
	CMP DL,10
	JG TOH
	ADD DL,'0'
	JMP HNEXT
TOH:;A~F�������
	ADD DL,'A'
	SUB DL,10
HNEXT:
	;MOV AH,2
	;INT 21H
	
	PUSH CX
	mov ah,09h
    mov al,DL  ;��ʾ���ַ�
    mov cx,1    ;�ַ���ʾ����
    mov bl,04h ;�ַ���ɫ��Ϣ
    mov bh,00  ;ҳ������
    int 10h    ;�ڵ�ǰ��괦��ʾһ������ɫΪ��ɫ��ǰ��ɫΪ��ɫ���ַ�
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
;�˵�
MYMENU PROC NEAR
	MOV AX,0003H; 80��25 ��ɫ�ı���ʽ 
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
;����߿�
INPUTMENU PROC NEAR 
	MOV AX,0003H;����  
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
	CMP AL,'1';ѡ����1
	JZ CASE1
	CMP AL,'2';ѡ����2
	JZ CASE2
	CMP AL,'3';ѡ����3
	JZ CASE3
	CMP AL,'4';ѡ����4
	JZ CASE4
	CMP AL,'5';ѡ����5
	JZ CASE5
	CMP AL,'6';ѡ����6
	JZ CASE6
	CMP AL,'0';ѡ����0
	JZ CASE0
	MOV AH,1
	INT 21H
	JMP BEGIN
CASE1:;����1
	CALL INPUTMENU
	CALL BINPUT
	CALL DOUTPUT
	MOV DX,0505H
	MOV AH,2
	INT 10H
	MOV CX,32
	MOV DI,0
	MOV AH,2
ENDTIP1:;���ܽ�������
	MOV DL,ENDINF[DI]
	INT 21H
	INC DI
LOOP ENDTIP1
	MOV AH,1
	INT 21H
	JMP BEGIN
CASE2:;����2
	CALL INPUTMENU
	CALL BINPUT
	CALL HOUTPUT
	MOV DX,0505H
	MOV AH,2
	INT 10H
	MOV CX,32
	MOV DI,0
	MOV AH,2
ENDTIP2:;���ܽ�������
	MOV DL,ENDINF[DI]
	INT 21H
	INC DI
LOOP ENDTIP2
	MOV AH,1
	INT 21H
	JMP BEGIN
CASE3:;����3
	CALL INPUTMENU
	CALL DINPUT
	CALL BOUTPUT
	MOV DX,0505H
	MOV AH,2
	INT 10H
	MOV CX,32
	MOV AH,2
	MOV DI,0
ENDTIP3:;���ܽ�������
	MOV DL,ENDINF[DI]
	INT 21H
	INC DI
LOOP ENDTIP3
	MOV AH,1
	INT 21H
	JMP BEGIN
CASE4:;����4
	CALL INPUTMENU
	CALL DINPUT
	CALL HOUTPUT
	MOV DX,0505H
	MOV AH,2
	INT 10H
	MOV CX,32
	MOV DI,0
	MOV AH,2
ENDTIP4:;���ܽ�������
	MOV DL,ENDINF[DI]
	INT 21H
	INC DI
LOOP ENDTIP4
	MOV AH,1
	INT 21H
	JMP BEGIN
CASE5:;����5
	CALL INPUTMENU
	CALL HINPUT
	CALL BOUTPUT
	MOV DX,0505H
	MOV AH,2
	INT 10H
	MOV CX,32
	MOV DI,0
	MOV AH,2
ENDTIP5:;���ܽ�������
	MOV DL,ENDINF[DI]
	INT 21H
	INC DI
LOOP ENDTIP5
	MOV AH,1
	INT 21H
	JMP BEGIN
CASE6:;����6
	CALL INPUTMENU
	CALL HINPUT
	CALL DOUTPUT
	MOV DX,0505H
	MOV AH,2
	INT 10H
	MOV CX,32
	MOV DI,0
	MOV AH,2
ENDTIP6:;���ܽ�������
	MOV DL,ENDINF[DI]
	INT 21H
	INC DI
LOOP ENDTIP6
	MOV AH,1
	INT 21H
	JMP BEGIN
CASE0:;����0
	MOV AH,4CH
   	INT 21H
CODE ENDS
    END START








