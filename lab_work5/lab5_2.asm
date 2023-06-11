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

fpuMacr macro ; ������ �������� a-e/b
fld _e
fdiv _b
fld _a
fsubr
endm ;; ��������� �������

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

    title1 db "������������ ������ 5-2. MMX �������",0
    task1 db "��������� �������� ����������� �������� ����� ����� 2-� ��������. ���� ������ ����� ������ 55, �� ��������� �������� a � e/b � de, ��� a, b, c, d � ������������ �����; ����� � ��������� �������� a � e/b.", 0
    buf1 dq 12 dup(0),0
    txt1 db "���������: %I64d",10,0
    _a real4 20.1    ; ���������� ����������
    _b real4 5.2
    _c real4 2.8
    _d real4 1.3
    _e real4 6.7
    res1 real4 0.0
    
    arr1 dw 1,15,3,4             ; ������ ����� arr1
    len1 equ ($-arr1)/type arr1 ; ������ ������� arr1
    
    arr2 dw 5,6,7,5             ; ������ ����� arr2
    len2 equ ($-arr2)/type arr2 ; ���������� ����� �������
    
    arr3 dw (len1+len2) dup(0)  ; ������ ������ ��� ����� ��������

    classname db "template_class",0
    
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
                    invoke MsgboxI,hWin,ptr$(task1),"���������� � �������",MB_OK,10
            .case 102   ; ���� ������ ����� �������
                .code
                    movq MM0,QWORD PTR arr1     ; �������� ������� ����� arr1
                    movq MM1,QWORD PTR arr2     ; �������� ������� ����� arr2
                    paddw MM0,MM1               ; ������������ ����������� ��������
                    movq QWORD PTR arr3,MM0     ; ���������� ����������

                    pextrw rax,mm0,1            ; ����������� ������� ����� � EAX
                    emms                        ; ��������� MMX-�������
                    cmp eax,55      ; �������� ������ �� 55
                    jg MoreThan55   ; ���� ����� ������ 55
                    jmp LessThan55  ; ���� ����� ������

                MoreThan55: 
                    fpuMacr  ; a-e/b
                    fld _d                  ; �������� d
                    fmul _e                 ; d*e
                    fsub                    ; a-e/b-de
                    fisttp res1 ; ���������� ����������
                    jmp _end    ; ������� � �����

                LessThan55: 
                    fpuMacr  ; a-e/b
                    fisttp res1             ; ���������� ����������

                _end:
                    invoke wsprintf,ADDR buf1,ADDR txt1,res1
                    invoke MsgboxI,hWin,ADDR buf1,"���������",MB_OK,10

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