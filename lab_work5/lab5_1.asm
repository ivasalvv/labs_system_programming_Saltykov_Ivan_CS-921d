include \masm64\include64\masm64rt.inc  ; ����������� ����������
    
MSGBOXPARAMSA STRUCT    ; ���������� ��������� ���������
    cbSize DWORD ?,?
    hwndOwner QWORD ?
    hInstance QWORD ?
    lpszText QWORD ?
    lpsztitle1 QWORD ?
    dwStyle DWORD ?,?
    lpszIcon QWORD ?
    dwContextHelpId QWORD ?
    lpfnMsgBoxCallback QWORD ?
    dwLanguageId DWORD ?,?
MSGBOXPARAMSA ENDS

array STRUCT   ; ������ ���������� ���������������� ���������
    el1 dq ?
    el2 dq ?
    el3 dq ?
    el4 dq ?
    el5 dq ?
    el6 dq ?
    el7 dq ?
    el8 dq ?
array ENDS     ; ����� ���������� ���������������� ���������

.data?
    hInstance dq ? ; ���������� ��������
    hWnd      dq ? ; ���������� ����
    hIcon     dq ? ; ���������� ������
    hCursor   dq ? ; ���������� �������
    sWid      dq ? ; ������ �������� (�����. �������� �� x)
    sHgt      dq ? ; ������ �������� (�����. �������� �� y)
    hImage    dq ?
    hStatic   dq ?

.data
    params MSGBOXPARAMSA <> ; ���������� �������� ��������� ���������

    mas1 db 'Cheerful and full of energy, enthusiastic, vivacious eagle-eyed. ' ; �������������� �����
    len1 equ ($-mas1)/type mas1     ; ����������� ���������� ������ � ������� mas1
    countWord dq 0                  ; ������� ����
    countE db 0                     ; ������� ������ ��������
    resE array <-1,?,?,?,?,?,?,?>    ; ������������� 1 ������ ������� �    

    title1 db "������������ ������ 5-1. ��������� �������",0
    task db "����� ����� �� 8 ����, ����������� ���������. ���������� ���������� ���������� ����� � � ������ �����.", 0
    buf1 dq 12 dup(0),0
    ifmt1 db "���������:",10,
    "����� 1: %d",10,
    "����� 2: %d",10,
    "����� 3: %d",10,
    "����� 4: %d",10,
    "����� 5: %d",10,
    "����� 6: %d",10,
    "����� 7: %d",10,
    "����� 8: %d",0

    classname db "template_class",0
    BSIZE1 equ 100                              ; ���-�� ������ ������������ � ����
    fName BYTE "result.txt",0                   ; �������� ����� ��� ������
    fHandle dq ?                                ; ���������� �����
    cWritten dq ?                               ; ������ ��� ������ �������� ������ 

.code
entry_point proc
    GdiPlusBegin                               ; initialise GDIPlus
    mov hInstance,rv(GetModuleHandle,0)        ; ��������� � ���������� ����������a ��������
    mov hIcon,  rv(LoadIcon,hInstance,10)      ; �������� � ���������� ����������a ������
    mov hCursor,rv(LoadCursor,0,IDC_ARROW)     ; �������� ������� � ����������
    mov sWid,rv(GetSystemMetrics,SM_CXSCREEN)  ; ��������� ���. �������� �� � �������� 
    mov sHgt,rv(GetSystemMetrics,SM_CYSCREEN)  ; ��������� ���. �������� �� y ��������
    mov hImage,rv(ResImageLoad,20)             ; ������ �������� Bitmap
    call main
    GdiPlusEnd                                 ; GdiPlus cleanup
    invoke ExitProcess,0
    ret
entry_point endp

main proc
    LOCAL wc  :WNDCLASSEX           ; ���������� ��������� ����������
    LOCAL lft :QWORD                ; ���. ���������� ���������� � ����� 
    LOCAL top :QWORD                ; � ���������� ������ �� ����� ���. ����.
    LOCAL wid :QWORD
    LOCAL hgt :QWORD
    mov wc.cbSize,SIZEOF WNDCLASSEX     ; �����. ������ ���������
    mov wc.style,CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW ; ����� ����
    mov wc.lpfnWndProc,ptr$(WndProc)    ; ����� ��������� WndProc
    mov wc.cbClsExtra,0	               ; ���������� ������ ��� ��������� ������
    mov wc.cbWndExtra,0                 ; ���������� ������ ��� ��������� ����
    mrm wc.hInstance,hInstance          ; ���������� ���� ����������� � ���������
    mrm wc.hIcon,  hIcon                ; ����� ������
    mrm wc.hCursor,hCursor              ; ����� �������
    mrm wc.hbrBackground,0              ; hBrush ���� ����
    mov wc.lpszMenuName,0               ; ���������� ���� � ��������� � ������ ������� ����
    mov wc.lpszClassName,ptr$(classname); ��� ������
    mrm wc.hIconSm,hIcon
    invoke RegisterClassEx,ADDR wc      ; ����������� ������ ����
    mov wid,960   ; ������ ����������������� ���� � ��������
    mov hgt,540   ; ������ ����������������� ���� � ��������
    mov rax,sWid  ; �����. �������� �������� �� x
    sub rax,wid   ; ������ � = �(��������) - �(���� ������������)
    shr rax,1     ; ��������� �������� �
    mov lft,rax

    mov rax, sHgt ; �����. �������� �������� �� y
    sub rax, hgt
    shr rax, 1
    mov top, rax
    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES, \
    ADDR classname,ADDR title1, \
    WS_OVERLAPPED or WS_VISIBLE or WS_SYSMENU,\
    lft,top,wid,hgt,0,0,hInstance,0
    mov hWnd,rax ; ���������� ����������� ����
    call msgloop
    ret
main endp

msgloop proc
    LOCAL msg    :MSG
    LOCAL pmsg   :QWORD
    mov pmsg, ptr$(msg) ; ��������� ������ ��������� ���������
    jmp gmsg            ; ������� � GetMessage()
    mloop:
    invoke TranslateMessage,pmsg
    invoke DispatchMessage,pmsg
    gmsg:
    test rax, rv(GetMessage,pmsg,0,0,0) ; ���� GetMessage �� ������ ����
    jnz mloop
    ret
    msgloop endp

WndProc proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
.switch uMsg
    .case WM_COMMAND    ; ���� ������� ����
        .switch wParam
            .case 101   ; ���� ������ ����� ���������� � �������
                .code
                    invoke MsgboxI,hWin,ptr$(task),"���������� � �������",MB_OK,10
            .case 102   ; ���� ������ ����� �������
                .code
                    xor rsi,rsi     ; ������� �������� RSI
                    xor rcx,rcx     ; ������� �������� RCX
                    xor r11,r11     ; ������� �������� R11
                    xor r12,r12     ; ������� �������� R12
                    xor r13,r13     ; ������� �������� R13

                    lea r12,resE    ; ��������� ������� � ������               
                    lea rsi,mas1    ; �������� ������ ������� mas1
                    mov r14, ' '    ; �������� �������
                    mov r15, 'e'    ; �������� ������� �        
                    mov rcx, len1   ; ��������� � ������� ������������ �������� ����
                    cld             ; ����������� - ����� (������� DF)
                
                cycle:
                    lodsb           ; �������� ������
                    cmp rax,r15     ; ���������� � �
                    je foundE       ; ������� ���� ������� �
                    cmp rax,r14     ; ���������� � ��������
                    je foundSpace   ; ������� ���� ������ ������

                    add rdi,1       ; ������� �� ��������� ������
                    loop cycle      ; ������� � ������ �����
                    jmp _end        ; ���� ���� ����� ��������

                foundE:
                    add r11,1   ; ���������� ���������� ���-�� �
                    jmp cycle   ; ������� � ������ �����

                foundSpace:
                    mov [r12],r11   ; ������ ���-�� � � ������ �����������
                    add r12,8       ; ����������� �� ��������� ������� �������
                    mov r11,0       ; ������� �������� ���-�� ���������� �
                    jmp cycle       ; ������� � ������ �����
	
                _end:
                    invoke wsprintf,ADDR buf1,ADDR ifmt1,resE.el1,resE.el2,resE.el3,resE.el4,resE.el5,resE.el6,resE.el7,resE.el8
                    invoke MessageBox,0,addr buf1,addr title1,MB_OK     ; ����� ������ �� �����

            .case 103   ; ���� ������� ���������� � ����
                .data
                    msg1 db "���������� ���������� � ����.",0   ; ����������� � ������
                    const1 dq -1
                .code
                    mov rax,resE.el1
                    cmp rax,const1
                    je NoResult
                    jne HaveResult
                    
                NoResult:
                    invoke MsgboxI,hWin,"��������� ���������� �����������. ��������� ������ � ������.","������",MB_OK,10
                    jmp _end2
                        
                HaveResult:
                    invoke MsgboxI,hWin,ptr$(msg1),"���������� � ����",MB_OK,10 ; ����� ���� � ������������
                    invoke CreateFile,ADDR fName,GENERIC_WRITE,0,0,CREATE_ALWAYS,FILE_ATTRIBUTE_ARCHIVE,0
                    mov fHandle,rax
                    invoke WriteFile,fHandle,ADDR buf1,BSIZE1,ADDR cWritten,0   ; ������ ���������� � ����

                _end2:
                    xor rax,rax

            .case 104   ; ���� ������ ����� ���������� �� ������
                .data
                    msgtxt db "�����: Saltikov Ivan",10,10,"������: KN-921d",0 ; ����� ������ �� ������
                .code
                    invoke MsgboxI,hWin,ptr$(msgtxt),"���������� �� ������",MB_OK,10

            .case 105   ; ���� ������ ����� �� ���������
                .data
                    msg db "����� �� ���������.",0                  ; ����� ����������� � ������
                .code
                    invoke MsgboxI,hWin,ptr$(msg),"�����",MB_OK,10
                    rcall SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,0 ; ����������� ����
                    .endsw
            
            .case WM_CREATE
                invoke CreateWindowEx,WS_EX_LEFT,"STATIC",0,WS_CHILD or WS_VISIBLE or SS_BITMAP,\
                0,0,0,0,hWin,hInstance,0,0    
                mov hStatic,rax
                invoke SendMessage,hStatic,STM_SETIMAGE,IMAGE_BITMAP,hImage ; ��������� ����

                invoke LoadMenu,hInstance,100   ; ��������� ���� �� exe-�����
                invoke SetMenu,hWin,rax         ; ��������� ���� � �����
                .return 0
            .case WM_CLOSE
                invoke SendMessage,hWin,WM_DESTROY,0,0
            .case WM_DESTROY 
                invoke PostQuitMessage,NULL
            .endsw

    invoke DefWindowProc,hWin,uMsg,wParam,lParam
    ret
WndProc endp
end