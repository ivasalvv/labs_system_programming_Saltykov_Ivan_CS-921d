include \masm64\include64\mylibrary.inc  ; ����������� ����� ����������

.data               ; ������ ����������
    arrA dq -41, -6, 4, -2, 0      ; ������ �
    len1 equ ($-arrA)/type arrA     ; ������ ������� �
    res1 dq ?                       ; ���������� ����������

    BSIZE1 equ 50               ; ������ ������ ��� ������ � ����               
    fName db "result.txt",0     ; �������� ����� ��� ������
    fHandle dq ?                ; ���������� �����
    cWritten dq ?
    fmt db "������������ �� ������������� ����� ������: %d",0   ; ����� ��� ������ � ����

    title1 db "������������ ������ 3_1. ������ � �������",0     ; ��������� ���� ������
    txt1 db "����� ������ � �� N = 20 ���������. �������� ��������� ����������� ������������� �� ������������� ��������� ������� �.",10,10
    txt2 db "���������: %d",10,10,
    "�����: �������� ����.",0
    buf1 dq 1 dup(0),0

.code           ; ��������� �������� ����
entry_point proc
    xor rax,rax     ; ������� �������� RAX
    xor rsi,rsi     ; ������� �������� RSI
    xor rbp,rbp     ; ������� �������� RBP
    xor r10,r10     ; ������� �������� R10

    mov rcx,len1            ; �������� ���-�� ������
    lea rbp,byte ptr arrA   ; ��������� ��������� � ������ ������� �
    mov rsi,[rbp]           ; ������ ������� �������� � ������� RSI

@1:
    mov r10,[rbp]   ; ������ �������� � ������� R10
    cmp r10,0       ; ��������� �������� � ����
    jge NotFit      ; ���� ����� ������ 0
    
    cmp r10,rsi     ; ��������� ��������� 
    jg Fit          ; ���� ����� ������ ��� ������
    jl NotFit       ; ���� ����� ������ ��� ������

Fit:
    mov rsi,r10     ; ������ ����� � ������� �������������� ����������

NotFit:
    add rbp,type arrA   ; ����������� �� ��������� �������

dec ecx     ; ��������� ���������� ���������� ������
jnz @1      ; ������� � ������ �����
jmp _end    ; ������� � ����� ���������

_end:               ; ����� ���������
    mov res1,rsi    ; ������ � ���������� ����������
 
    xor rsi,rsi     ; ������� �������� RSI
    lea rsi,buf1    ; ��������� ��������� � ������ ������
    invoke wsprintf, ADDR [rsi], ADDR fmt, res1 ; �������������� ������ � ������

    invoke CreateFile,ADDR fName,GENERIC_WRITE,0,0,CREATE_ALWAYS,FILE_ATTRIBUTE_ARCHIVE,0   ; �������� �����
    mov fHandle,rax                     ; ���������� ����������� �����
    invoke WriteFile,fHandle,ADDR buf1,BSIZE1,ADDR cWritten,0   ; ������ � ����
    invoke CloseHandle, fHandle         ; ������� ���������� �����

    invoke wsprintf,ADDR buf1,ADDR txt1, res1   ; �������������� ������ � ������
    invoke MessageBox,0,ADDR buf1,ADDR title1,MB_ICONINFORMATION    ; ����� ����
    invoke ExitProcess,0    ; ���������� ������ ���������

entry_point endp        ; ����� ������
end