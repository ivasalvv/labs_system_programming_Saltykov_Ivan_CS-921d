include \masm64\include64\masm64rt.inc
.data?
    hInstance dq ?
    hIcon     dq ?
    hBmp      dq ?
    hStatic   dq ?

.data
    arr1 dq -1.3, 2.1, 3.8, 1.0, 5.4, 6.12, 7.54    ; массив 1
    arr2 dq -1., -5.0, -3.54, 1.5, -5.8, -6.53, 7.5 ; массив 2
    len1 dq 7           ; количество чисел в массивах   
    arr3 dq 7 dup(0)    ; результирующий массив
    countFirst dq 0
    countSecond dq 0
    
    fmt db "Масив 1:",10,"-1.3     2.1     3.8     1.0     5.4     6.12     7.54",10,10,
    "Массив 2:",10,"-1     -5.0     -3.54     1.5     -5.8     -6.53     7.5",10,10,
    "Результат:",10,"%d     %d     %d     %d     %d     %d     %d",10,0
    buf dq 12 dup(0),0

.code
entry_point proc
    GdiPlusBegin        ; инициализация GDIPlus
        mov hInstance, rv(GetModuleHandle,0)
        mov hIcon,rv(LoadImage,hInstance,10,IMAGE_ICON,32,32,LR_DEFAULTCOLOR)
        mov hBmp,rv(ResImageLoad,20)
        invoke DialogBoxParam,hInstance,100,0,ADDR main,hIcon
    GdiPlusEnd          ; GdiPlus очистка
        invoke ExitProcess,0
    ret
entry_point endp

main proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
    .switch uMsg
        .case WM_INITDIALOG ; сообщение о создании диал. окна
            invoke SendMessage,hWin,WM_SETICON,1,lParam
            mov hStatic, rv(GetDlgItem,hWin,102)
            invoke SendMessage,hStatic,STM_SETIMAGE,IMAGE_BITMAP,hBmp
        .return TRUE
        .case WM_COMMAND    ; сообщение от меню или кнопки
            .switch wParam
                .case 101   ; если выбран вывод информации о задании
                    .data
                        txt2 db "Выполнить параллельное сравнение массивов по 7-мь 64-разрядных вещественных числа. Если первый массив меньше второго, то выполнить операцию деления над массивами чисел, иначе – умножения.",0
                        titl2 db "Информация о задании",0
                    .code
                        invoke MsgboxI,hWin,ADDR txt2,ADDR titl2,MB_OK,10
                
                .case 102   ; если выбран вывод информации об авторе
                    .data
                        txt1 db "Автор: Saltikov Ivan",10,"Группа: KN-921d",0
                    .code
                        invoke MsgboxI,hWin,ADDR txt1,"Информация об авторе",MB_OK,10
                .case 103
                    .data
                        msg db "Выход из программы.",0                  ; вывод уведомления о выходе
                    .code
                        invoke MsgboxI,hWin,ptr$(msg),"Выход",MB_OK,10
                        rcall SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,0 ; уничтожение окна

                .case 1001  ; выполнение ЛР с SSE
                 .code
                    mov countFirst,0    ; обнуление переменной перед вычислениями
                    mov countSecond,0   ; обнуление переменной перед вычислениями
                    mov rcx,len1        ; кол-во циклов
                    lea rsi,arr1    ; установка указателя на массив 1
                    lea rdi,arr2    ; установка указателя на массив 2
                    lea rbx,arr3    ; установка указателя на массив 3
                    jmp cycleSSE    ; перейти в цикл проверки массива

                FirstOrEqualSSE:        ; если элемент первого массива >=
                    add countFirst,1    ; увеличение переменной на 1
                    jmp cycleSSE           ; переход в цикл

                SecondSSE:                 ; если элемент первого массива <
                    add countSecond,1   ; увеличение переменной на 1 

                cycleSSE:                  ; цикл попарного сравнения элементов
                    cmp rcx,0           ; проверка на завершение цикла
                    je nextSSE             ; переход на проверку какой массив больше
                    movsd XMM0,qword ptr[rsi]   ; получение элемента из массива 1
                    movsd XMM1,qword ptr[rdi]   ; получение элемента из массива 2

                    add rsi,8           ; переход на следующий элемент массива 1
                    add rdi,8           ; переход на следующий элемент массива 1
                    dec rcx             ; уменьшение счетчика циклов

                    comisd XMM0,XMM1    ; сравнение элементов

                    jnb FirstOrEqualSSE    ; если элемент первого массива больше
                    jb SecondSSE           ;
                loop cycleSSE

                nextSSE:
                    lea rsi,arr1    ; установка указателя на массив 1
                    lea rdi,arr2    ; установка указателя на массив 2
                    lea rbx,arr3    ; установка указателя на массив 3
                    mov rax,countFirst  
                    mov rbx,countSecond
                    cmp rax,rbx     ; проерка какой массив больше
                    ja MultiplicationSSE
        
                DivisionSSE:               ; деление массивов
                    movups XMM0,[rsi]   ; получение элемента из массива 1
                    movups XMM1,[rdi]   ; получение элемента из массива 2
                    divpd xmm0,xmm1     ; деление 2-х пар элементов

                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; пересылка в регистр EAX из MM0
                    mov arr3,rax            ; запись в результирующий массив
    
                    unpckhpd xmm0,xmm2      ; передача старшей половины числа в младшую
                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 2
                    mov arr3[8],rax         ; запись в результирующий массив
    
                    add rsi,16          ; перемещение указателя на следующий элемент
                    add rdi,16          ; перемещение указателя на следующий элемент
                    movups XMM0,[rsi]   ; получение элемента из массива 1
                    movups XMM1,[rdi]   ; получение элемента из массива 2
                    divpd xmm0,xmm1     ; деление 2-х пар элементов 

                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 3
                    mov arr3[16],rax        ; запись в результирующий массив
        
                    unpckhpd xmm0,xmm2      ; передача старшей половины числа в младшую
                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 4
                    mov arr3[24],rax        ; запись в результирующий массив
    
                    add rsi,16          ; перемещение указателя на следующий элемент
                    add rdi,16          ; перемещение указателя на следующий элемент
                    movups XMM0,[rsi]   ; получение элемента из массива 1
                    movups XMM1,[rdi]   ; получение элемента из массива 2
                    divpd xmm0,xmm1     ; деление 2-х пар элементов 

                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 5
                    mov arr3[32],rax        ; запись в результирующий массив

                    unpckhpd xmm0,xmm2      ; передача старшей половины числа в младшую
                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 6
                    mov arr3[40],rax        ; запись в результирующий массив

                    add rsi,16          ; перемещение указателя на следующий элемент
                    add rdi,16          ; перемещение указателя на следующий элемент
                    movups XMM0,[rsi]   ; получение элемента из массива 1
                    movups XMM1,[rdi]   ; получение элемента из массива 2
                    divpd xmm0,xmm1     ; деление 2-х пар элементов 

                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 7
                    mov arr3[48],rax        ; запись в результирующий массив
                    jmp _endSSE                ; переход в конец программы
    
                MultiplicationSSE:         ; умножение массивов
                    movups XMM0,[rsi]   ; получение элемента из массива 1
                    movups XMM1,[rdi]   ; получение элемента из массива 2
                    mulpd xmm0,xmm1     ; умножение двух пар элементов

                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 1
                    mov arr3,rax            ; запись в результирующий массив
    
                    unpckhpd xmm0,xmm2      ; передача старшей половины числа в младшую
                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 2
                    mov arr3[8],rax         ; запись в результирующий массив
    
                    add rsi,16          ; перемещение указателя на следующий элемент
                    add rdi,16          ; перемещение указателя на следующий элемент
                    movups XMM0,[rsi]   ; получение элемента из массива 1
                    movups XMM1,[rdi]   ; получение элемента из массива 2
                    mulpd xmm0,xmm1     ; умножение двух пар элементов

                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 3
                    mov arr3[16],rax        ; запись в результирующий массив
    
                    unpckhpd xmm0,xmm2      ; передача старшей половины числа в младшую
                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 4
                    mov arr3[24],rax        ; запись в результирующий массив
    
                    add rsi,16          ; перемещение указателя на следующий элемент
                    add rdi,16          ; перемещение указателя на следующий элемент
                    movups XMM0,[rsi]   ; получение элемента из массива 1
                    movups XMM1,[rdi]   ; получение элемента из массива 2
                    mulpd xmm0,xmm1     ; умножение двух пар элементов

                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 5
                    mov arr3[32],rax        ; запись в результирующий массив 

                    unpckhpd xmm0,xmm2      ; передача старшей половины числа в младшую
                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 6
                    mov arr3[40],rax        ; запись в результирующий массив

                    add rsi,16          ; перемещение указателя на следующий элемент
                    add rdi,16          ; перемещение указателя на следующий элемент
                    movups XMM0,[rsi]   ; получение элемента из массива 1
                    movups XMM1,[rdi]   ; получение элемента из массива 2
                    mulpd xmm0,xmm1     ; умножение двух пар элементов

                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 7
                    mov arr3[48],rax        ; запись в результирующий массив

                _endSSE:
                    mov r8,arr3         ; запись в регистр r8
                    mov r9,arr3[8]      ; запись в регистр r9
                    mov r10,arr3[16]    ; запись в регистр r10
                    mov r11,arr3[24]    ; запись в регистр r11
                    mov r12,arr3[32]    ; запись в регистр r12
                    mov r13,arr3[40]    ; запись в регистр r13
                    mov r14,arr3[48]    ; запись в регистр r14

                    invoke wsprintf, ADDR buf, ADDR fmt, r8,r9,r10,r11,r12,r13,r14
                    invoke MsgboxI,hWin,ADDR buf,"Результат вычислений SSE",MB_OK,10

                .case 1003  ; если выбрано выполнение ЛР с AVX
                    mov countFirst,0    ; обнуление переменной перед вычислениями
                    mov countSecond,0   ; обнуление переменной перед вычислениями
                    mov rcx,len1    ; кол-во циклов
                    lea rsi,arr1    ; установка указателя на массив 1
                    lea rdi,arr2    ; установка указателя на массив 2
                    lea rbx,arr3    ; установка указателя на массив 3
                    jmp cycleAVX       ; перейти в цикл проверки массива

                FirstOrEqualAVX:           ; если элемент первого массива >=
                    add countFirst,1    ; увеличение переменной на 1
                    jmp cycleAVX           ; переход в цикл

                SecondAVX:                 ; если элемент первого массива <
                    add countSecond,1   ; увеличение переменной на 1 

                cycleAVX:                  ; цикл попарного сравнения элементов
                    cmp rcx,0           ; проверка на завершение цикла
                    je nextAVX             ; переход на проверку какой массив больше
                    vmovsd XMM0,qword ptr[rsi]   ; получение элемента из массива 1
                    vmovsd XMM1,qword ptr[rdi]   ; получение элемента из массива 2

                    add rsi,8           ; переход на следующий элемент массива 1
                    add rdi,8           ; переход на следующий элемент массива 1
                    dec rcx             ; уменьшение счетчика циклов

                    vcomisd XMM0,XMM1    ; сравнение элементов

                    jnb FirstOrEqualAVX    ; если элемент первого массива больше
                    jb SecondAVX           ;
                loop cycleAVX

                nextAVX:
                    lea rsi,arr1    ; установка указателя на массив 1
                    lea rdi,arr2    ; установка указателя на массив 2
                    lea rbx,arr3    ; установка указателя на массив 3
                    mov rax,countFirst  
                    mov rbx,countSecond
                    cmp rax,rbx     ; проерка какой массив больше
                    ja MultiplicationAVX
        
                DivisionAVX:               ; деление массивов
                    vmovups XMM0,[rsi]   ; получение элемента из массива 1
                    vmovups XMM1,[rdi]   ; получение элемента из массива 2
                    divpd xmm0,xmm1     ; деление 2-х пар элементов

                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; пересылка в регистр EAX из MM0
                    mov arr3,rax            ; запись в результирующий массив
    
                    unpckhpd xmm0,xmm2      ; передача старшей половины числа в младшую
                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 2
                    mov arr3[8],rax         ; запись в результирующий массив
    
                    add rsi,16          ; перемещение указателя на следующий элемент
                    add rdi,16          ; перемещение указателя на следующий элемент
                    vmovups XMM0,[rsi]   ; получение элемента из массива 1
                    vmovups XMM1,[rdi]   ; получение элемента из массива 2
                    divpd xmm0,xmm1     ; деление 2-х пар элементов 

                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 3
                    mov arr3[16],rax        ; запись в результирующий массив
        
                    unpckhpd xmm0,xmm2      ; передача старшей половины числа в младшую
                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 4
                    mov arr3[24],rax        ; запись в результирующий массив
    
                    add rsi,16          ; перемещение указателя на следующий элемент
                    add rdi,16          ; перемещение указателя на следующий элемент
                    vmovups XMM0,[rsi]   ; получение элемента из массива 1
                    vmovups XMM1,[rdi]   ; получение элемента из массива 2
                    divpd xmm0,xmm1     ; деление 2-х пар элементов 

                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 5
                    mov arr3[32],rax        ; запись в результирующий массив

                    unpckhpd xmm0,xmm2      ; передача старшей половины числа в младшую
                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 6
                    mov arr3[40],rax        ; запись в результирующий массив

                    add rsi,16          ; перемещение указателя на следующий элемент
                    add rdi,16          ; перемещение указателя на следующий элемент
                    vmovups XMM0,[rsi]   ; получение элемента из массива 1
                    vmovups XMM1,[rdi]   ; получение элемента из массива 2
                    divpd xmm0,xmm1     ; деление 2-х пар элементов 

                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 7
                    mov arr3[48],rax        ; запись в результирующий массив
                    jmp _endAVX                ; переход в конец программы
    
                MultiplicationAVX:         ; умножение массивов
                    vmovups XMM0,[rsi]   ; получение элемента из массива 1
                    vmovups XMM1,[rdi]   ; получение элемента из массива 2
                    mulpd xmm0,xmm1     ; умножение двух пар элементов

                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 1
                    mov arr3,rax            ; запись в результирующий массив
    
                    unpckhpd xmm0,xmm2      ; передача старшей половины числа в младшую
                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 2
                    mov arr3[8],rax         ; запись в результирующий массив
    
                    add rsi,16          ; перемещение указателя на следующий элемент
                    add rdi,16          ; перемещение указателя на следующий элемент
                    vmovups XMM0,[rsi]   ; получение элемента из массива 1
                    vmovups XMM1,[rdi]   ; получение элемента из массива 2
                    mulpd xmm0,xmm1     ; умножение двух пар элементов

                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 3
                    mov arr3[16],rax        ; запись в результирующий массив
    
                    unpckhpd xmm0,xmm2      ; передача старшей половины числа в младшую
                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 4
                    mov arr3[24],rax        ; запись в результирующий массив
    
                    add rsi,16          ; перемещение указателя на следующий элемент
                    add rdi,16          ; перемещение указателя на следующий элемент
                    vmovups XMM0,[rsi]   ; получение элемента из массива 1
                    vmovups XMM1,[rdi]   ; получение элемента из массива 2
                    mulpd xmm0,xmm1     ; умножение двух пар элементов

                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 5
                    mov arr3[32],rax        ; запись в результирующий массив 

                    unpckhpd xmm0,xmm2      ; передача старшей половины числа в младшую
                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 6
                    mov arr3[40],rax        ; запись в результирующий массив

                    add rsi,16          ; перемещение указателя на следующий элемент
                    add rdi,16          ; перемещение указателя на следующий элемент
                    vmovups XMM0,[rsi]   ; получение элемента из массива 1
                    vmovups XMM1,[rdi]   ; получение элемента из массива 2
                    mulpd xmm0,xmm1     ; умножение двух пар элементов

                    cvtpd2pi mm0,xmm0       ; преобразование в 32-х разрядное число
                    movd dword ptr eax,mm0  ; число 7
                    mov arr3[48],rax        ; запись в результирующий массив

                _endAVX:
                    mov r8,arr3         ; запись в регистр r8
                    mov r9,arr3[8]      ; запись в регистр r9
                    mov r10,arr3[16]    ; запись в регистр r10
                    mov r11,arr3[24]    ; запись в регистр r11
                    mov r12,arr3[32]    ; запись в регистр r12
                    mov r13,arr3[40]    ; запись в регистр r13
                    mov r14,arr3[48]    ; запись в регистр r14
                    invoke wsprintf, ADDR buf, ADDR fmt, r8,r9,r10,r11,r12,r13,r14
                    invoke MsgboxI,hWin,ADDR buf,"Результат вычислений AVX",MB_OK,10

        .endsw
      .case WM_CLOSE ; если есть сообщение о закрытии окна
         invoke EndDialog,hWin,0 ; 
    .endsw
    xor rax, rax
    ret
main endp
end
