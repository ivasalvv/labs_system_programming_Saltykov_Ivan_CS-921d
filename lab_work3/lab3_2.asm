include \masm64\include64\mylibrary.inc  ; подключение своей библиотеки

.data               ; секция переменных
    res1 dq ?       ; переменная результата
    const1 dd 4
    const2 dq 0.1
    const3 dq 1
    const4 dd 8

    title1 db "Лабораторная работа 3_2. Сопроцессор",0     ; заголовок окна вывода
    txt1 db "Найти значение х, при котором выполняется функция 8*arctg(0,1) + arctg(x) = п/4.",10,10
    txt2 db "Результат: %d",10,10,
    "Автор: Салтыков Иван.",0
    buf1 dq 1 dup(0),0

.code               ; директива сегмента кода
entry_point proc
    finit           ; инициирование сопроцессора
    fld const2      ; загрузка 0.1
    fild const3     ; 
    fpatan          ; arctg(0.1)
    fimul const4    ; *8

    fldpi           ; загрузка числа п
    fidiv const1    ; п/4

    fsub st(0),st(1)
    fptan           ; tg(8*arctg(0.1)+arctg(x))
    FXCH st(1)      ; перестановка st(1) в st(0)
    
    fisttp res1

invoke wsprintf,ADDR buf1,ADDR txt1, res1    ; преобразование данных в строку
invoke MessageBox,0,ADDR buf1,ADDR title1,MB_ICONINFORMATION    ; вызов окна
invoke ExitProcess,0    ; завершение работы программы

entry_point endp        ; точка выхода
end