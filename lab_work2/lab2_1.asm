include \masm64\include64\masm64rt.inc

.data
    a1 dq 8     ; ������������� ����������
    b1 dq 256
    c1 dq 8
    d1 dq 4
    e1 dq 8
    f1 dq 16
    g1 dq 2
    res1 dq ?   ; ���������� ��� ���������� 1
    res2 dq ?   ; ���������� ��� ���������� 2
    tick1 dq ?  ; ���������� ���������� ������ 1
    tick2 dq ?  ; ���������� ���������� ������ 2
    
    title1 db " ������������ ������ �2. ������� ������",0
    txt1 db "��������� a+b/c/d+efg",10,10, 
    "���������:",10,
    "�������������� ��������: %d",10,
    "�������������� ������: %d",10,10,
    "���������� ������:",10, 
    "��� �������������� ��������: %d",10, 
    "��� �������������� �������: %d",10,10,
    "�����: ���� ��������",0
    buf1 dq 3 dup(0),0

.code
entry_point proc
    mov r10, rdx    ; ������ R10 � RAX
    rdtsc           ; ��������� ����� ������
    xchg rdi, rax   ; ����� ���������� ���������

    xor rdx,rdx     ; ������� RDX
    mov rax,b1      ; ������ b1 � RAX
    div c1          ; b/c
    div d1          ; b/c/d
    mov rsi,rax     ; ������ RAX � ������� �������������� ����������
    mov rax,e1      ; ������ e1 � RAX
    mul f1          ; e*f
    mul g1          ; e*f*g
    add rax,rsi     ; b/c/d+efg
    add rax,a1      ; a+b/c/d+efg
    mov res1,rax    ; ������ RAX � ���������� ���������� 1
    
    rdtsc           ; ��������� ����� ������
    sub rax, rdi    ; ��������� �� ���������� ����� ������ ����������� �����
    mov tick1, rax  ; ��������� RAX � tick1

    mov r10, rdx    ; ������ RDX � R10
    rdtsc           ; ��������� ����� ������
    xchg rdi, rax   ; ����� ���������� ���������
    
    xor rdx,rdx     ; ������������� �������� rdx
    mov rax,b1      ; ������ b1 � ������� RAX
    sar rax,5       ; b/c/d
    mov rax,rsi     ; ������ RAX � ������� �������������� ����������
    mov rax,e1      ; ������ e1 � RAX
    sal rax,5       ; efg
    add rax,rsi     ; b/c/d+efg
    add rax,a1      ; a+b/c/d+efg
    mov res2,rax    ; ������ RAX � ���������� ���������� 2

    rdtsc           ; ��������� ����� ������
    sub rax, rdi    ; ��������� �� ���������� ����� ������ ����������� �����
    mov tick2, rax  ; ��������� rax � tick2


invoke wsprintf,ADDR buf1,ADDR txt1,res1,res2,tick1,tick2       ; �������������� ������ � ������
invoke MessageBox,0,ADDR buf1,ADDR title1,MB_ICONINFORMATION    ; ����� ���� � �����������
invoke ExitProcess,0

entry_point endp
end