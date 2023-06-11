include \masm64\include64\masm64rt.inc ; ����������� ����� ����������

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

.data               ; ������ ����������
    params MSGBOXPARAMSA <>     ; ������������� ��������� ���������
    title1 db "������������ ������ 7-1",0     ; ��������� ���� ������
    txt1 db "The new languge is added.",0    ; ����� ��� ������
    buf1 dq 1 dup(0),0              ; ����� ��� ������ ������
    value db "00000442"             ; ������ �����
    szFileName db "vizitka7-1.exe",0   ; �������� ����� ��� ������ ����������

.code               ; ��������� �������� ����
entry_point proc
    invoke LoadKeyboardLayout,ADDR value,KLF_ACTIVATE ; ��������� ���������
    invoke WinExec,addr szFileName,SW_SHOW  ; ����� ������������ � ������� ����������
    

    invoke wsprintf,ADDR buf1,ADDR txt1
    invoke WinExec,addr szFileName,SW_SHOW  ; ����� ������������ � ������� ����������
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

entry_point endp
end
