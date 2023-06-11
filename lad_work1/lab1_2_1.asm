include \masm64\include64\masm64rt.inc	; подключение библиотеки
count PROTO arg1:QWORD,arg2:QWORD,arg3:QWORD,arg4:QWORD,arg5:QWORD,arg6:QWORD,arg7:QWORD

.data	    ; секция переменных
 a1 dq 3    ; переменная а1
 b1 dq 4    ; переменная b1
 c1 dq 5    ; переменная c1
 d1 dq 6    ; переменная d1
 e1 dq 50   ; переменная e1
 f1 dq 7    ; переменная f1
 g1 dq 10   ; переменная g1
 res1 dq 0  ; переменная результат
 
title1 db "Лабораторная работа 1_2. Процедуры с параметрами",0 ; заголовок окна вывода
txt1 db "Вычесление результата выражения abcd — ef/g",10,
"Результат: %d",10,"Адрес переменной в памяти: %ph",10,10,
"Автор: Салтиков І.О",0
buf1 dq 3 dup(0),0

.code                   ; директива сегмента кода
count proc arg1:QWORD, arg2:QWORD, arg3:QWORD,arg4:QWORD,arg5:QWORD,arg6:QWORD,arg7:QWORD
mov rax,rcx             ; записываем а в RAX
mul rdx                 ; *b
mul r8                  ; *c
mul r9                  ; *d
mov rsi,rax             ; записываем RAX в регистр промежуточного результата
mov rax,[rbp+30h]       ; записываем e в RAX
xor rcx,rcx             ; очищаем регистр перед использованием
mov rcx,[rbp+38h]       ; записываем f в RAX
mul rcx                 ; *f
mov rcx,[rbp+40h]       ; записываем g в RAX
div rcx                 ; /g
sub rsi,rax             ; abcd-ef/g
mov res1,rsi            ; запись результата в переменную результата

ret
count endp
entry_point proc

invoke count,a1,b1,c1,d1,e1,f1,g1
invoke wsprintf,ADDR buf1,ADDR txt1,res1,ADDR res1
invoke MessageBox,0,ADDR buf1,ADDR title1,MB_ICONINFORMATION
invoke ExitProcess,0

entry_point endp        ; точка выхода
end