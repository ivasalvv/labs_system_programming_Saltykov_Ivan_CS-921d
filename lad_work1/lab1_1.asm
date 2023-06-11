include \masm64\include64\masm64rt.inc

.data		; ������ ����������
e1 dq 120 	; ���������� e1
b1 dq 2		; ���������� b1
d1 dq 4 	; ���������� d1
c1 dq 5 	; ���������� c1
num1 dq 6 	; ���������� ���������
num2 dq 14 	; ���������� ���������
res1 dq 0 	; ���������� ����������

title1 db "������������ ������ 1_1. ���������� �������������� ��������",0	; ��������� ���� ������
text1 db "��������� e/4b � d/14c",10,						; ����� ��������� 
"���������: %d",10,"����� ���������� � ������: %ph",10,10,	; ����� ���������� � ������ ����������
"�����: �������� �.�.",0
buf1 dq 3 dup(0),0

.code		     ; ������ ����
entry_point proc     ; ����� �����
xor rax,rax	; ������� �������� RAX
xor rdx,rdx  	; ������� �������� RDX
 mov rax,e1   	; ������ ���������� e1 � RAX
div num1    ; /4
mul b1	    ; *b
xor rsi,rsi  	; ������� �������� �������������� ����������
 mov rsi,rax	; ������ RAX � ������� RSI
xor rax,rax  	; ������� �������� RAX
xor rdx,rdx  	; ������� �������� RDX
 mov rax,d1 	; ������ d1 � RAX
div num2    ; /14
mul c1	    ; *c
sub rsi,rax ; e/4b � d/14c
 mov res1,rsi	; ������ ���������� � ���������� ����������

invoke wsprintf,ADDR buf1,ADDR text1,res1,ADDR res1
invoke MessageBox,0,ADDR buf1,ADDR title1,MB_ICONINFORMATION
invoke ExitProcess,0

entry_point endp	; ����� ������
end