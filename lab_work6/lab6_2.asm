include \masm64\include64\masm64rt.inc

IDI_ICON EQU 1001
 
.data?
    hInstance dq ? ; ���������� ��������
    hWnd      dq ? ; ���������� ����
    hIcon     dq ? ; ���������� ������
    hCursor   dq ? ; ���������� �������
    sWid      dq ? ; ������ �������� (�����. �������� �� x)
    sHgt      dq ? ; ������ �������� (�����. �������� �� y) 
    
.data
    color1 dd 97123
    mas dd 720
    alpha dd 0.0    ; ������� ���������� 
    delta dd 0.0175 ; ���� ������
    centerX dq ?    ; �������� �� X 
    centerY dq ?    ; �������� �� Y
    tmp dd 0        ; ��������� ����������
    divK dd 80.0    ; ���������� �����������
    xR dd 0.        ; ���������� �������
    yR dd 0.0
    temp1 dd 0
    x1 dd 0.0
    x2 dq 2.0
	
    classname db "template_class",0
    caption db "����������� ������ 6-2. ������� ������",0

PaintCa macro
    ; invoke DestroyWindow,hWnd             ; ����������� ����
    invoke BeginPaint, hWnd, addr ps        ; ����� ������� ������ ���������
    mov hdc, rax                            ; ����������� ���������
    invoke GetClientRect, hWnd, addr rect   ; ������ � ��������� rect 

    invoke GetSystemMetrics,SM_CXSCREEN     ; ��������� ������ ������ � ��������
    shr rax,1                               ; ����������� �������� ������ �� X
    mov centerX,320
    invoke GetSystemMetrics,SM_CYSCREEN     ; ��������� ������ ������ � ��������
    shr rax,1                               ; ����������� �������� ������ �� Y
    mov centerY,260
    mov r10d,mas                            ; ���������� ���������� ������
    mov temp1,r10d

    finit                       ; ������������� ������������
    
cycle1:                      
    fld alpha                   ; �������� a
    fmul x2                     ; 2a
    fcos                        ; cos(2a)
    fld divK                    ; �������� ������������ ��������
    fmul                        ; cos(2a)*divK
    fld alpha                   ; �������� a
    fcos                        ; cos(a)
    fmul x2                     ; 2cos(a)
    fmul divK                   ; divK*2cos(a)
    fsub
    fild centerY                ; �������� ������ ������ �� Y
    fadd                        ; centerY + a*divK*cos(a)
    fistp dword ptr yR          ; ���������� Y ��� ��������� �� �����

    fld alpha                   ; �������� a
    fmul x2                     ; 2a
    fsin                        ; cos(2a)
    fld divK                    ; �������� ������������ ��������
    fmul                        ; cos(2a)*divK
    fld alpha                   ; �������� a
    fsin                        ; sin(a)
    fmul x2                     ; 2sin(a)
    fmul divK                   ; divK*2cos(a)
    fsub                        ; a*divK*cos(a)

    fild centerX                ; �������� ������ ������ �� X
    fadd                        ; centerX + a*divK*sin(a)
    fistp dword ptr xR          ; ���������� X

    invoke Sleep,1              ; �������� ��� ���������
    invoke SetPixel, hdc, xR, yR, color1	; ��������� ����� �������
    movss XMM3,delta
    addss XMM3,alpha
    movss alpha,XMM3

    dec temp1   		; ���������� ��������
    jz _end       		; ����������� ���������
    jmp cycle1			; ����������� � ������ �����
    
_end:
    endm

CursorCa macro
    invoke GetSystemMetrics,SM_CXSCREEN ; ��������� ������ ������ � ��������
    shr rax,1                           ; ����������� �������� ������ �� X
    mov centerX,rax
    invoke GetSystemMetrics,SM_CYSCREEN ; ��������� ������ ������ � ��������
    shr rax,1                           ; ����������� �������� ������ �� Y
    mov centerY,rax
    mov r10d,mas                        ; ���������� ���������� ������
    mov temp1,r10d
	
    finit                               ; ������������� ������������

cycle2:                      
    fld alpha           ; �������� �����
    fmul x2             ; 2�
    fcos                ; cos(2a)
    fld divK            ; �������� ������������ ��������
    fmul                ; divK*cos(2a)
    fld alpha           ; �������� �
    fcos                ; cos(a)
    fmul x2             ; 2cos(a)
    fmul divK           ; divK*2cos(a)
    fsub

    fild centerY        ; �������� ������ ������ �� Y
    fadd                ; centerY + a*divK*cos(a) 
    fistp dword ptr yR  ; ���������� Y ��� ��������� �� �����

    fld alpha           ; �������� �
    fmul x2             ; 2a
    fsin                ; sin(2a)
    fld divK            ; �������� ������������ ��������
    fmul
    fld alpha           ; �������� �
    fsin                ; sin(a)
    fmul x2             ; 2sin(a)
    fmul divK           ; divK*2sin(a) st1 = divk*cos(2a)
    fsub                ; a*divK*cos(a)

    fild centerX      
    fadd                ; xR := centerX + ...
    fistp dword ptr xR  ; ���������� X

    invoke Sleep,1              ; �������� ��� ���������
    invoke SetCursorPos,xR,yR   ; ������������ ������� �� xR, yR 
    movss XMM3,delta
    addss XMM3,alpha
    movss alpha,XMM3

dec temp1   ; ���������� �������� ������
dec temp1   ; ���������� �������� ������
jz _end2    ; ��������� ���������
jmp cycle2  ; ������� � ������ �����

_end2:
    endm

.code
entry_point proc
    mov hInstance,rv(GetModuleHandle,0)         ; ��������� � ���������� ����������a ��������
    mov hIcon,  rv(LoadIcon,hInstance,10)       ; �������� � ���������� ����������a ������
    mov hCursor,rv(LoadCursor,0,IDC_ARROW)      ; �������� ������� � ����������
    mov sWid,rv(GetSystemMetrics,SM_CXSCREEN)   ; ��������� ���. �������� �� � �������� 
    mov sHgt,rv(GetSystemMetrics,SM_CYSCREEN)   ; ��������� ���. �������� �� y ��������
    ; mov hBrush,rvcall(CreateSolidBrush,00C4C4C4h)
    call main                                   ; ����� ��������� main
    rcall ExitProcess,0
    ret
entry_point endp

msgloop proc
    LOCAL msg  :MSG
    LOCAL pmsg :QWORD
    mov pmsg, ptr$(msg)      ; ��������� ������ ��������� ���������
    jmp gmsg                 ; jump directly to GetMessage()
    
mloop:
    rcall TranslateMessage,pmsg
    rcall DispatchMessage,pmsg
    
gmsg:
    test rax, rvcall(GetMessage,pmsg,0,0,0) ; ���� GetMessage �� ������ ����
    jnz mloop
    ret
msgloop endp

main proc
    LOCAL wc  :WNDCLASSEX               ; ���������� ��������� ����������
    LOCAL lft :QWORD                    ; ���. ���������� ���������� � ����� 
    LOCAL top :QWORD                    ; � ���������� ������ �� ����� ���. ����.
    LOCAL wid :QWORD
    LOCAL hgt :QWORD
    LOCAL rect:RECT                     ; �������������� ����� ��� ���������
    LOCAL ps:PAINTSTRUCT                ; �������������� ����� ��� ���������
    LOCAL hdc:HDC                       ; �������������� ����� ��� ����� ����
    mov wc.cbSize,SIZEOF WNDCLASSEX     ; ���������� ������ ���������
    mov wc.style,CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW ; ����� ����
    mov wc.lpfnWndProc,ptr$(WndProc)    ; ����� ��������� WndProc
    mov wc.cbClsExtra,0                 ; ���������� ������ ��� ��������� ������
    mov wc.cbWndExtra,0                 ; ���������� ������ ��� ��������� ����
    mrm wc.hInstance,hInstance          ; ���������� ��� ����������� � ���������
    mrm wc.hIcon,  hIcon                ; ����� ������
    mrm wc.hCursor,hCursor              ; ����� �������
    mrm wc.hbrBackground,0              ; hBrush ���� ����
    mov wc.lpszMenuName,0               ; ���������� ��� � ��������� � ������ ������� ����
    mov wc.lpszClassName,ptr$(classname); ��� ������
    mrm wc.hIconSm,hIcon
    invoke RegisterClassEx,ADDR wc      ; ���������� ������ ����
    mov wid, 640                        ; ������ ����������������� ���� � ��������
    mov hgt, 640                        ; ������ ����������������� ���� � ��������
    mov rax,sWid                        ; ���������� �������� �������� �� x
    sub rax,wid                         ; ������ � = �(��������) - �(���� ������������)
    shr rax,1                           ; ��������� �������� �
    mov lft,rax
    mov rax, sHgt                       ; ���������� �������� �������� �� y
    sub rax, hgt 						;
    shr rax, 1 							;
    mov top, rax 						;
    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES, \
        ADDR classname,ADDR caption, \
        WS_OVERLAPPED or WS_VISIBLE or WS_SYSMENU,\
        lft,top,wid,hgt,0,0,hInstance,0
    mov hWnd,rax ; ���������� ����������� ����
    PaintCa
    call msgloop
    ret
main endp

WndProc proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
LOCAL dfbuff[260]:BYTE
LOCAL pbuff :QWORD
LOCAL rect:RECT             ; ������������ ����� �� ��������� RECT
LOCAL ps:PAINTSTRUCT        ; ������������ ����� �� ��������� 
LOCAL hdc:HDC               ; ������������ ����� �� ����� ����
    
.switch uMsg
    .case WM_COMMAND
        .switch wParam
            .case 10003
                rcall SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL
					
            .case 10002
                invoke MsgboxI,hWin,"������� �������","��������� �������",MB_OK,10
                PaintCa
					
            .case 10004
                invoke MsgboxI,hWin,"���������� �������","� �������...",MB_OK,10
                CursorCa
					
            .case 10005
                .data
                    Task db "���������� ������� �������� �� ������. ���������� ������ � ������������� ����������� �������� �� ��������:",10,"X = 2Rcost(1+cost);",10,"Y = 2Rsint(1+cost);",10,"�� R � ����� ����������.",0
                .code
                    invoke MsgboxI,hWin,ptr$(Task),"��������",MB_OK,10
					
            .case 10001
                .data
                    msgtxt db "�����: ���� ��������",10,"������: ��-921�",0
                .code
                    invoke MsgboxI,hWin,ptr$(msgtxt),"�����",MB_OK,10
        .endsw

    .case WM_CREATE
        rcall LoadMenu,hInstance,10000
        rcall SetMenu,hWin,rax
        .return 0

    .case WM_CLOSE
        rcall SendMessage,hWin,WM_DESTROY,0,0
			
    .case WM_DESTROY
        rcall PostQuitMessage,NULL
.endsw

rcall DefWindowProc,hWin,uMsg,wParam,lParam
ret
WndProc endp
end

