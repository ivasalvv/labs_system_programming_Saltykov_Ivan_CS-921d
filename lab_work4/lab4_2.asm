include \masm64\include64\masm64rt.inc

IDI_ICON EQU 1001
MSGBOXPARAMSA STRUCT    ; ���������� ��������� ���������
    cbSize DWORD ?,?
    hwndOwner QWORD ?
    hInstance QWORD ?
    lpszText QWORD ?
    lpszCaption QWORD ?
    dwStyle DWORD ?,?
    lpszIcon QWORD ?
    dwContextHelpId QWORD ?
    lpfnMsgBoxCallback QWORD ?
    dwLanguageId DWORD ?,?
MSGBOXPARAMSA ENDS

mSub macro a, b ;; ������ � ������ mSub
    fld a       ;; �������� a
    fld b       ;; �������� b
    fsub        ;; a-b
endm            ;; ��������� �������

.data
    params MSGBOXPARAMSA <>     ; ������������� ��������� ���������
    hInstance dq ?              ; ���������� ��������
    hWnd      dq ?              ; ���������� ����
    hIcon     dq ?              ; ���������� ������
    hCursor   dq ?              ; ���������� �������
    sWid      dq ?              ; ������ �������� (�����. �������� �� x)
    sHgt      dq ?              ; ������ �������� (�����. �������� �� y) 
    classname db "template_class",0
    caption db "��������� ���������� ��������������� ���������",0
	
    title1 db "������������ ������ 4-2. �������",0
    txt1 db "�������� �� ���������� ��������� ���������� ���������, � ������� ���� �� ���������� ���������� ��������� ���.",10,10
    txt2 db "���������: 3,5(a � b) � (a � b)/5,1",10,10
    txt3 db "�����: Ivan Salikov, KN-921d",0

    buf dq 30 dup(?),0      ; ������ ��� ������
    buf1 dq 3 dup(?),0      ; ������ ��� ������
    buf2 db 80 dup(?),0     ; ������ ��� ������
    buf3 dq buf2,0          ; ������ ��� ������
    buf4 db 16 dup(?),0     ; ������ ��� ������

    const1 real4 3.5        ; ���������� ���������
    const2 real4 5.1        ; ���������� ���������
    a1 real4 3.7
    b1 real4 5.2
    res1 real8 0.0          ; ���������� ����������
    res2 dq 0               ; ���������� ����������

.code
entry_point proc
    finit           ; ������������� �����
    mSub [a1],[b1]  ; a-b
    fmul const1     ; 3.5(a-b)
    
    mSub [a1],[b1]  ; a-b
    fdiv const2     ; (a-b)/5.1
    fsub            ; 3.5(a-b)-(a-b)/5.1
    fst res1        ; ��������� ����������
    fistp res2      ; ��������� ����������

    mov hInstance,rv(GetModuleHandle,0)         ; ��������� � ���������� ����������a ��������
    mov hIcon,  rv(LoadIcon,hInstance,10)       ; �������� � ���������� ����������a ������
    mov hCursor,rv(LoadCursor,0,IDC_ARROW)      ; �������� ������� � ����������
    mov sWid,rv(GetSystemMetrics,SM_CXSCREEN)   ; ��������� ���. �������� �� � �������� 
    mov sHgt,rv(GetSystemMetrics,SM_CYSCREEN)   ; ��������� ���. �������� �� y ��������
    call main                                   ; ����� ��������� main
    invoke ExitProcess,0
	ret
entry_point endp

main proc
    LOCAL wc  :WNDCLASSEX               ; ���������� ��������� ����������
    LOCAL lft :QWORD                    ; ���. ���������� ���������� � ����� 
    LOCAL top :QWORD                    ; � ���������� ������ �� ����� ���. ����.
    LOCAL wid :QWORD
    LOCAL hgt :QWORD
    mov wc.cbSize,SIZEOF WNDCLASSEX     ; �����. ������ ���������
    mov wc.style,CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW ; ����� ����
    mov wc.lpfnWndProc,ptr$(WndProc)    ; ����� ��������� WndProc
    mov wc.cbClsExtra,0                 ; ���������� ������ ��� ��������� ������
    mov wc.cbWndExtra,0                 ; ���������� ������ ��� ��������� ����
    mrm wc.hInstance,hInstance          ; ���������� ���� ����������� � ���������
    mrm wc.hIcon,  hIcon                ; ����� ������
    mrm wc.hCursor,hCursor              ; ����� �������
    mrm wc.hbrBackground,0              ; ���� ����
    mov wc.lpszMenuName,0               ; ���������� ���� � ��������� � ������ ������� ����
    mov wc.lpszClassName,ptr$(classname); ��� ������
    mrm wc.hIconSm,hIcon
    invoke RegisterClassEx,ADDR wc      ; ����������� ������ ����
    mov wid, 900                        ; ������ ����������������� ���� � ��������
    mov hgt, 300                        ; ������ ����������������� ���� � ��������
    mov rax,sWid                        ; �����. �������� �������� �� x
    sub rax,wid                         ; ������ � = �(��������) - �(���� ������������)
    shr rax,1                           ; ��������� �������� �
    mov lft,rax                         ;

    mov rax, sHgt       ; �����. �������� �������� �� y
    sub rax, hgt        ;
    shr rax, 1          ;
    mov top, rax        ;
    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES, \
    ADDR classname,ADDR caption, \
    WS_OVERLAPPED or WS_VISIBLE or WS_SYSMENU,\
    lft,top,wid,hgt,0,0,hInstance,0
    mov hWnd,rax        ; ���������� ����������� ����
    call msgloop
    ret
main endp

msgloop proc
    LOCAL msg    :MSG
    LOCAL pmsg   :QWORD
    mov pmsg, ptr$(msg) ; ��������� ������ ��������� ���������
    jmp gmsg            ; jump directly to GetMessage()
    mloop:
        invoke TranslateMessage,pmsg
        invoke DispatchMessage,pmsg
    
    gmsg:
        test rax, rv(GetMessage,pmsg,0,0,0) ; ���� GetMessage �� ������ ����
        jnz mloop
        ret
msgloop endp

    WndProc proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
    LOCAL hdc:HDC                   ; �������������� ����� ��� ����������� ����
    LOCAL ps:PAINTSTRUCT            ; ��� ��������� PAINTSTRUCT
    LOCAL rect:RECT                 ; ��� ��������� ��������� RECT
    LOCAL leng:QWORD
    .switch uMsg
    .case WM_DESTROY
        invoke PostQuitMessage,NULL
    .case WM_PAINT                      ; ���� ���� ��� � �������������
        invoke BeginPaint,hWnd, ADDR ps ; ����� ���������������� ���������
        mov hdc,rax                     ; ���������� ���������
	
    invoke fptoa,res1,buf3
    invoke TextOut,hdc,40,35,buf3,10

    ;invoke wsprintf,ADDR buf1,ADDR txt1        ; �������������� ������ � �����
    ;invoke wsprintf,ADDR buf2,ADDR txt2        ; �������������� ������ � �����
    ;invoke wsprintf,ADDR buf,ADDR txt3,res1   	; �������������� ������ � �����

    ;invoke TextOut,hdc,20,0,addr buf1,109      ; ����� ������ � ����
    ;invoke TextOut,hdc,20,20,addr buf2,35      ; ����� ������ � ����
    ;invoke TextOut,hdc,20,60,addr buf,30       ; ����� ������ � ����
 
    invoke wsprintf,ADDR buf1,ADDR txt1,ADDR txt2, ADDR txt3
    mov params.cbSize,SIZEOF MSGBOXPARAMSA  ; ������ ���������
    mov params.hwndOwner,0                  ; ���������� ���� ���������
    invoke GetModuleHandle,0                ; ��������� ����������� ���������
    mov params.hInstance,rax                ; ���������� ����������� ���������
    lea rax, buf1                           ; ����� ���������
    mov params.lpszText,rax
    lea rax,title1                          ; ����� �������� ����
    mov params.lpszCaption,rax
    mov params.dwStyle,MB_USERICON          ; ����� ����
    mov params.lpszIcon,IDI_ICON            ; ������ ������
    mov params.dwContextHelpId,0            ; �������� �������
    mov params.lpfnMsgBoxCallback,0
    mov params.dwLanguageId,LANG_NEUTRAL    ; ���� ���������
    lea rcx,params
    invoke MessageBoxIndirect   ; ����� ���� � ����������� ������ � �������
    invoke ExitProcess,0

    invoke EndPaint, hWnd, ADDR ps
    .endsw                                  ; ����� ��������� �� ���������
        invoke DefWindowProc,hWin,uMsg,wParam,lParam

ret
WndProc endp
end