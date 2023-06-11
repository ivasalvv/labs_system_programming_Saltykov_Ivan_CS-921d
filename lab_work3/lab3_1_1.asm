include \masm64\include64\mylibrary.inc  ; подключение своей библиотеки

.data               ; секция переменных
    arrA dq -41, -6, 4, -2, 0      ; массив А
    len1 equ ($-arrA)/type arrA     ; длинна массива А
    res1 dq ?                       ; переменная результата

    BSIZE1 equ 50               ; размер буфера для вывода в файл               
    fName db "result.txt",0     ; название файла для вывода
    fHandle dq ?                ; дескриптор файла
    cWritten dq ?
    fmt db "Максимальное из отрицательных чисел масива: %d",0   ; текст для вывода в файл

    title1 db "Лабораторная работа 3_1. Работа с файлами",0     ; заголовок окна вывода
    txt1 db "Задан массив А из N = 20 элементов. Написать программу определения максимального из отрицательных элементов массива А.",10,10
    txt2 db "Результат: %d",10,10,
    "Автор: Салтыков Иван.",0
    buf1 dq 1 dup(0),0

.code           ; директива сегмента кода
entry_point proc
    xor rax,rax     ; очистка регистра RAX
    xor rsi,rsi     ; очистка регистра RSI
    xor rbp,rbp     ; очистка регистра RBP
    xor r10,r10     ; очистка регистра R10

    mov rcx,len1            ; указание кол-ва циклов
    lea rbp,byte ptr arrA   ; установка указателя в начало массива А
    mov rsi,[rbp]           ; запись первого элемента в регистр RSI

@1:
    mov r10,[rbp]   ; запись элемента в регистр R10
    cmp r10,0       ; сравнение элемента с нулём
    jge NotFit      ; если число больше 0
    
    cmp r10,rsi     ; сравнение элементов 
    jg Fit          ; если число больше чем первое
    jl NotFit       ; если число меньше чем первое

Fit:
    mov rsi,r10     ; запись числа в регистр промежуточного результата

NotFit:
    add rbp,type arrA   ; перемещение на следующий элемент

dec ecx     ; декремент переменной количества циклов
jnz @1      ; переход в начало цикла
jmp _end    ; переход в конец программы

_end:               ; конец программы
    mov res1,rsi    ; запись в переменную результата
 
    xor rsi,rsi     ; очистка регистра RSI
    lea rsi,buf1    ; установка указателя в начало буфера
    invoke wsprintf, ADDR [rsi], ADDR fmt, res1 ; преобразование данных в строку

    invoke CreateFile,ADDR fName,GENERIC_WRITE,0,0,CREATE_ALWAYS,FILE_ATTRIBUTE_ARCHIVE,0   ; создание файла
    mov fHandle,rax                     ; сохранение дескриптора файла
    invoke WriteFile,fHandle,ADDR buf1,BSIZE1,ADDR cWritten,0   ; запись в файл
    invoke CloseHandle, fHandle         ; закрыть дескриптор файла

    invoke wsprintf,ADDR buf1,ADDR txt1, res1   ; преобразование данных в строку
    invoke MessageBox,0,ADDR buf1,ADDR title1,MB_ICONINFORMATION    ; вызов окна
    invoke ExitProcess,0    ; завершение работы программы

entry_point endp        ; точка выхода
end