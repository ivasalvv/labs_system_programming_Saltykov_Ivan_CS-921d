include \masm64\include64\mylibrary.inc  ; ����������� ����� ����������

.data               ; ������ ����������
    res1 dq ?       ; ���������� ����������
    const1 dd 4
    const2 dq 0.1
    const3 dq 1
    const4 dd 8

    title1 db "������������ ������ 3_2. �����������",0     ; ��������� ���� ������
    txt1 db "����� �������� �, ��� ������� ����������� ������� 8*arctg(0,1) + arctg(x) = �/4.",10,10
    txt2 db "���������: %d",10,10,
    "�����: �������� ����.",0
    buf1 dq 1 dup(0),0

.code               ; ��������� �������� ����
entry_point proc
    finit           ; ������������� ������������
    fld const2      ; �������� 0.1
    fild const3     ; 
    fpatan          ; arctg(0.1)
    fimul const4    ; *8

    fldpi           ; �������� ����� �
    fidiv const1    ; �/4

    fsub st(0),st(1)
    fptan           ; tg(8*arctg(0.1)+arctg(x))
    FXCH st(1)      ; ������������ st(1) � st(0)
    
    fisttp res1

invoke wsprintf,ADDR buf1,ADDR txt1, res1    ; �������������� ������ � ������
invoke MessageBox,0,ADDR buf1,ADDR title1,MB_ICONINFORMATION    ; ����� ����
invoke ExitProcess,0    ; ���������� ������ ���������

entry_point endp        ; ����� ������
end