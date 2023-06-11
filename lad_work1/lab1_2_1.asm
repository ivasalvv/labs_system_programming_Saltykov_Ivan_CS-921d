include \masm64\include64\masm64rt.inc	; ����������� ����������
count PROTO arg1:QWORD,arg2:QWORD,arg3:QWORD,arg4:QWORD,arg5:QWORD,arg6:QWORD,arg7:QWORD

.data	    ; ������ ����������
 a1 dq 3    ; ���������� �1
 b1 dq 4    ; ���������� b1
 c1 dq 5    ; ���������� c1
 d1 dq 6    ; ���������� d1
 e1 dq 50   ; ���������� e1
 f1 dq 7    ; ���������� f1
 g1 dq 10   ; ���������� g1
 res1 dq 0  ; ���������� ���������
 
title1 db "������������ ������ 1_2. ��������� � �����������",0 ; ��������� ���� ������
txt1 db "���������� ���������� ��������� abcd � ef/g",10,
"���������: %d",10,"����� ���������� � ������: %ph",10,10,
"�����: �������� �.�",0
buf1 dq 3 dup(0),0

.code                   ; ��������� �������� ����
count proc arg1:QWORD, arg2:QWORD, arg3:QWORD,arg4:QWORD,arg5:QWORD,arg6:QWORD,arg7:QWORD
mov rax,rcx             ; ���������� � � RAX
mul rdx                 ; *b
mul r8                  ; *c
mul r9                  ; *d
mov rsi,rax             ; ���������� RAX � ������� �������������� ����������
mov rax,[rbp+30h]       ; ���������� e � RAX
xor rcx,rcx             ; ������� ������� ����� ��������������
mov rcx,[rbp+38h]       ; ���������� f � RAX
mul rcx                 ; *f
mov rcx,[rbp+40h]       ; ���������� g � RAX
div rcx                 ; /g
sub rsi,rax             ; abcd-ef/g
mov res1,rsi            ; ������ ���������� � ���������� ����������

ret
count endp
entry_point proc

invoke count,a1,b1,c1,d1,e1,f1,g1
invoke wsprintf,ADDR buf1,ADDR txt1,res1,ADDR res1
invoke MessageBox,0,ADDR buf1,ADDR title1,MB_ICONINFORMATION
invoke ExitProcess,0

entry_point endp        ; ����� ������
end