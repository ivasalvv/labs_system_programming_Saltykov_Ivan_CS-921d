include \masm64\include64\masm64rt.inc

.data                           ; ������ ����������
    arrA dq 90, 32, 72, 22, 31, 11      ; ������ �
    len1 equ ($-arrA)/type arrA ; ������ ������� �
    arrB dq len1 dup(?), 0      ; ������ �

    a1 dq 1 ; ���������� ����������
    a2 dq 1
    a3 dq 1
 
    title1 db "������������ ������ 2. ������������ �����",0
    txt1 db "�������: ����� ������ � �� 40 ���������. ���������� ������� ������ � �� ��������� ������� �, ��� 0,2 � 5 ��� ����� ����.",10,10,
    "���������: ",10,
    "B[1]: %d",10,
    "B[2]: %d",10,
    "B[3]: %d",10,
    10,"�����: �������� ����",0
    buf1 dq 3 dup(0),0

.code               ; ��������� �������� ����
entry_point proc
    xor rcx,rcx     ; ������� �������� RCX
    xor rbp,rbp     ; ������� �������� RBP
    xor rdi,rdi     ; ������� �������� RDI
    xor rax,rax     ; ������� �������� RAX

    mov rcx, len1   ; ������ ������ ������� � RCX       
    lea rbp, arrA   ; ��������� ��������� �� ������ ������� �
    lea rdi, arrB   ; ��������� ��������� �� ������ ������� �
    mov rax, 0

m1: 
    xor rax,rax     ; ������� �������� RAX
    xor rbx,rbx     ; ������� �������� RBX
    xor rdx,rdx     ; ������� �������� RDX       
    mov r10, [rbp]  ; ������ �������� ������� � � ������� R10

    bt r10, 0       ; �������� 0 ����
    setc al         ; ������ ���������� � AL 
    cmp al, dl      ; ��������� ���� � 0
    jne BitsNotZero ; ���� 0 ��� ����� �� ������� ��������

    bt r10, 2       ; �������� 2 ����
    setc al         ; ������ ���������� � AL 
    cmp al, dl      ; ��������� ���� � 0
    jne BitsNotZero ; ���� 2 ��� ����� �� ������� ��������

    bt r10, 5       ; �������� 5 ����
    setc al         ; ������ ���������� � AL 
    cmp al, dl      ; ��������� ���� � 0
    je BitsZero     ; ���� ��� ��������� ���� = 0
    jne BitsNotZero ; ���� 5 ��� ����� �� ������� ��������

BitsZero:
    mov [rdi], r10      ; ������ � ������ � ������� �� �
    add rdi, type arrB  ; ����������� �� ��������� ������� ������� �

BitsNotZero:
    add rbp, type arrA  ; ����������� �� ��������� ������� ������� �

dec ecx     ; ���������� �������� ���-�� ������
jnz m1
jmp _end    ; ������� � �����

_end:
xor rax,rax             ; ������� �������� RAX
xor rbx,rbx             ; ������� �������� RBP
lea rbx,byte ptr arrB   ; ��������� ��������� � ������ ������� �
mov rax,[rbx]           ; ������ �� ������� � � ������� RAX
mov a1,rax              ; ������ �� RAX � ���������� res1
xor rax,rax             ; ������� �������� RAX
add rbx,type arrB       ; ������������� �� ��������� ������� �������
mov rax,[rbx]           ; ������ �� ������� � � ������� RAX
mov a2,rax              ; ������ �� RAX � ���������� res2
xor rax,rax             ; ������� �������� RAX
add rbx,type arrB       ; ������������� �� ��������� ������� �������
mov rax,[rbx]           ; ������ �� ������� � � ������� RAX
mov a3,rax              ; ������ �� RAX � ���������� res2

invoke wsprintf,ADDR buf1,ADDR txt1,a1,a2,a3    ; �������������� ������ � ������
invoke MessageBox,0,ADDR buf1,ADDR title1,MB_ICONINFORMATION    ; ����� ���� � �����������
invoke ExitProcess,0

entry_point endp
end