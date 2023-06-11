include \masm64\include64\masm64rt.inc

.data                           ; секция переменных
    arrA dq 90, 32, 72, 22, 31, 11      ; массив А
    len1 equ ($-arrA)/type arrA ; длинна массива А
    arrB dq len1 dup(?), 0      ; массив В

    a1 dq 1 ; переменные результата
    a2 dq 1
    a3 dq 1
 
    title1 db "Лабораторная работа 2. Тестирование битов",0
    txt1 db "Задание: Задан массив А из 40 элементов. Необходимо создать массив В из элементов массива А, где 0,2 и 5 бит имеют нули.",10,10,
    "Результат: ",10,
    "B[1]: %d",10,
    "B[2]: %d",10,
    "B[3]: %d",10,
    10,"Автор: Салтыков Иван",0
    buf1 dq 3 dup(0),0

.code               ; директива сегмента кода
entry_point proc
    xor rcx,rcx     ; очистка регистра RCX
    xor rbp,rbp     ; очистка регистра RBP
    xor rdi,rdi     ; очистка регистра RDI
    xor rax,rax     ; очистка регистра RAX

    mov rcx, len1   ; запись длинны массива в RCX       
    lea rbp, arrA   ; установка указателя на начало массива А
    lea rdi, arrB   ; установка указателя на начало массива В
    mov rax, 0

m1: 
    xor rax,rax     ; очистка регистра RAX
    xor rbx,rbx     ; очистка регистра RBX
    xor rdx,rdx     ; очистка регистра RDX       
    mov r10, [rbp]  ; запись элемента массива А в регистр R10

    bt r10, 0       ; проверка 0 бита
    setc al         ; запись результата в AL 
    cmp al, dl      ; сравнение бита с 0
    jne BitsNotZero ; если 0 бит имеет не нулевое значение

    bt r10, 2       ; проверка 2 бита
    setc al         ; запись результата в AL 
    cmp al, dl      ; сравнение бита с 0
    jne BitsNotZero ; если 2 бит имеет не нулевое значение

    bt r10, 5       ; проверка 5 бита
    setc al         ; запись результата в AL 
    cmp al, dl      ; сравнение бита с 0
    je BitsZero     ; если все требуемые биты = 0
    jne BitsNotZero ; если 5 бит имеет не нулевое значение

BitsZero:
    mov [rdi], r10      ; запись в массив В элемент из А
    add rdi, type arrB  ; перемещение на следующий элемент массива В

BitsNotZero:
    add rbp, type arrA  ; перемещение на следующий элемент массива А

dec ecx     ; уменьшение счётчика кол-ва циклов
jnz m1
jmp _end    ; переход в конец

_end:
xor rax,rax             ; очистка регистра RAX
xor rbx,rbx             ; очистка регистра RBP
lea rbx,byte ptr arrB   ; установка указателя в начало массива С
mov rax,[rbx]           ; запись из массива С в регистр RAX
mov a1,rax              ; запись из RAX в переменную res1
xor rax,rax             ; очистка регистра RAX
add rbx,type arrB       ; переместиться на следующий элемент массива
mov rax,[rbx]           ; запись из массива С в регистр RAX
mov a2,rax              ; запись из RAX в переменную res2
xor rax,rax             ; очистка регистра RAX
add rbx,type arrB       ; переместиться на следующий элемент массива
mov rax,[rbx]           ; запись из массива С в регистр RAX
mov a3,rax              ; запись из RAX в переменную res2

invoke wsprintf,ADDR buf1,ADDR txt1,a1,a2,a3    ; преобразование данных в строку
invoke MessageBox,0,ADDR buf1,ADDR title1,MB_ICONINFORMATION    ; вывод окна с результатом
invoke ExitProcess,0

entry_point endp
end