include \masm64\include64\masm64rt.inc

Computer STRUCT
    serialNum1 dq ?
    price1 dq ?    
    name1 dd ?
    ownerSurname1 dd ?
    size1 dq ?    
Computer ENDS

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

.data		; ������ ����������
    params MSGBOXPARAMSA <>     ; ������������� ��������� ���������
    PC1 Computer <1,2,"Best PC","BLABLA",5>    
    PC2 Computer <5,4,"123","IBM",4>
    PC3 Computer <3,3,"142","Apple",1>

    num1 dq 3 	; ���������� ���������
    res1 dq ? 	; ���������� ����������

    title1 db "������������ ������ 4_1_2. ���������",0  ; ��������� ���� ������
    txt1 db "������ ������������������ ��������. ��������� �������� ���� ������ � ����������: �������� �����, ����, ��������, ������� ���������, ������ �������� � ������. ��������� ������� ���� ����������.",10,10,			; ����� ��������� 
    "Result: %d",10,         ; ����� ���������� � ������ ����������
    "Author: Ivan Saltykov",0
    buf1 dq 3 dup(0),0

.code                   ; ������ ����
    entry_point proc    ; ����� �����
    xor rax,rax         ; ������� �������� RAX
    mov rax,PC1.price1  ; ������ ����� ������� ��
    add rax,PC2.price1  ; ����������� ���� ������� ��
    add rax,PC3.price1  ; ����������� ���� �������� ��

    xor rdx,rdx  	      ; ������� �������� RDX
    div num1            ; /3
 
    mov res1,rax	      ; ������ ���������� � ���������� ����������

    ;invoke wsprintf,ADDR buf1,ADDR text1,res1,ADDR res1     ; �������������� ������ � ������
    ;invoke MessageBox,0,ADDR buf1,ADDR title1,MB_ICONINFORMATION    ; ����� ������� ����
    ;invoke ExitProcess,0

    invoke wsprintf,ADDR buf1,ADDR txt1,res1
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

entry_point endp	; ����� ������
end