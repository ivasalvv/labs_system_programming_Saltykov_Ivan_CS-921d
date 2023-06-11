include \masm64\include64\masm64rt.inc

.data
    a1 dq 8     ; инициализация переменных
    b1 dq 256
    c1 dq 8
    d1 dq 4
    e1 dq 8
    f1 dq 16
    g1 dq 2
    res1 dq ?   ; переменная для результата 1
    res2 dq ?   ; переменная для результата 2
    tick1 dq ?  ; переменная количества тактов 1
    tick2 dq ?  ; переменная количества тактов 2
    
    title1 db " Лабораторная работа №2. Команды сдвига",0
    txt1 db "Уравнение a+b/c/d+efg",10,10, 
    "Результат:",10,
    "Арифметические операции: %d",10,
    "Арифметические сдвиги: %d",10,10,
    "Количество тактов:",10, 
    "Для арифметических операций: %d",10, 
    "Для арифметических сдвигов: %d",10,10,
    "Автор: Иван Салтыков",0
    buf1 dq 3 dup(0),0

.code
entry_point proc
    mov r10, rdx    ; запись R10 в RAX
    rdtsc           ; получение числа тактов
    xchg rdi, rax   ; обмен значениями регистров

    xor rdx,rdx     ; очистка RDX
    mov rax,b1      ; запись b1 в RAX
    div c1          ; b/c
    div d1          ; b/c/d
    mov rsi,rax     ; запись RAX в регистр промежуточного результата
    mov rax,e1      ; запись e1 в RAX
    mul f1          ; e*f
    mul g1          ; e*f*g
    add rax,rsi     ; b/c/d+efg
    add rax,a1      ; a+b/c/d+efg
    mov res1,rax    ; запись RAX в переменную результата 1
    
    rdtsc           ; получение числа тактов
    sub rax, rdi    ; вычитание из последнего числа тактов предыдущего числа
    mov tick1, rax  ; пересылка RAX в tick1

    mov r10, rdx    ; запись RDX в R10
    rdtsc           ; получение числа тактов
    xchg rdi, rax   ; обмен значениями регистров
    
    xor rdx,rdx     ; инициализация регистра rdx
    mov rax,b1      ; запись b1 в регистр RAX
    sar rax,5       ; b/c/d
    mov rax,rsi     ; запись RAX в регистр промежуточного результата
    mov rax,e1      ; запись e1 в RAX
    sal rax,5       ; efg
    add rax,rsi     ; b/c/d+efg
    add rax,a1      ; a+b/c/d+efg
    mov res2,rax    ; запись RAX в переменную результата 2

    rdtsc           ; получение числа тактов
    sub rax, rdi    ; вычитание из последнего числа тактов предыдущего числа
    mov tick2, rax  ; пересылка rax в tick2


invoke wsprintf,ADDR buf1,ADDR txt1,res1,res2,tick1,tick2       ; преобразование данных в строку
invoke MessageBox,0,ADDR buf1,ADDR title1,MB_ICONINFORMATION    ; вызов окна с результатом
invoke ExitProcess,0

entry_point endp
end