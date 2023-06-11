include \masm64\include64\masm64rt.inc

.data		; секция переменных
e1 dq 120 	; переменная e1
b1 dq 2		; переменная b1
d1 dq 4 	; переменная d1
c1 dq 5 	; переменная c1
num1 dq 6 	; переменная константа
num2 dq 14 	; переменная константа
res1 dq 0 	; переменная результата

title1 db "Лабораторная работа 1_1. Выполнение арифметических операций",0	; заголовок окна вывода
text1 db "Уравнение e/4b – d/14c",10,						; вывод выражения 
"Результат: %d",10,"Адрес переменной в памяти: %ph",10,10,	; вывод результата и адреса переменной
"Автор: Салтиков І.О.",0
buf1 dq 3 dup(0),0

.code		     ; секция кода
entry_point proc     ; точка входа
xor rax,rax	; очистка регистра RAX
xor rdx,rdx  	; очистка регистра RDX
 mov rax,e1   	; запись переменной e1 в RAX
div num1    ; /4
mul b1	    ; *b
xor rsi,rsi  	; очистка регистра промежуточного результата
 mov rsi,rax	; запись RAX в регистр RSI
xor rax,rax  	; очистка регистра RAX
xor rdx,rdx  	; очистка регистра RDX
 mov rax,d1 	; запись d1 в RAX
div num2    ; /14
mul c1	    ; *c
sub rsi,rax ; e/4b – d/14c
 mov res1,rsi	; запись результата в переменную результата

invoke wsprintf,ADDR buf1,ADDR text1,res1,ADDR res1
invoke MessageBox,0,ADDR buf1,ADDR title1,MB_ICONINFORMATION
invoke ExitProcess,0

entry_point endp	; точка выхода
end