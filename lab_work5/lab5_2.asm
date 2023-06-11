include \masm64\include64\masm64rt.inc  ; подключение библиотеки
    
MSGBOXPARAMSA STRUCT    ; объявление системной структуры
    cbSize DWORD ?,?
    hwndOwner QWORD ?
    hInstance QWORD ?
    lpszText QWORD ?
    lpsztitle1 QWORD ?
    dwStyle DWORD ?,?
    lpszIcon QWORD ?
    dwContextHelpId QWORD ?
    lpfnMsgBoxCallback QWORD ?
    dwLanguageId DWORD ?,?
MSGBOXPARAMSA ENDS

fpuMacr macro ; макрос операции a-e/b
fld _e
fdiv _b
fld _a
fsubr
endm ;; окончание макроса

.data?
    hInstance dq ? ; дескриптор програми
    hWnd      dq ? ; дескриптор окна
    hIcon     dq ? ; дескриптор иконки
    hCursor   dq ? ; дескриптор курсора
    sWid      dq ? ; ширина монитора (колич. пикселей по x)
    sHgt      dq ? ; высота монитора (колич. пикселей по y)
    hImage    dq ?
    hStatic   dq ?

.data
    params MSGBOXPARAMSA <> ; объявление элемента системной структуры  

    title1 db "Лабораторная работа 5-2. MMX команды",0
    task1 db "Выполнить операции логического сложения целых чисел 2-х массивов. Если второе число больше 55, то выполнить операцию a – e/b – de, где a, b, c, d – вещественные числа; иначе – выполнить операцию a – e/b.", 0
    buf1 dq 12 dup(0),0
    txt1 db "Результат: %I64d",10,0
    _a real4 20.1    ; объявление переменных
    _b real4 5.2
    _c real4 2.8
    _d real4 1.3
    _e real4 6.7
    res1 real4 0.0
    
    arr1 dw 1,15,3,4             ; массив чисел arr1
    len1 equ ($-arr1)/type arr1 ; размер массива arr1
    
    arr2 dw 5,6,7,5             ; массив чисел arr2
    len2 equ ($-arr2)/type arr2 ; количество чисел массива
    
    arr3 dw (len1+len2) dup(0)  ; размер буфера для чисел массивов

    classname db "template_class",0
    
.code
entry_point proc
    GdiPlusBegin                               ; initialise GDIPlus
    mov hInstance,rv(GetModuleHandle,0)        ; получение и сохранение дескрипторa програми
    mov hIcon,  rv(LoadIcon,hInstance,10)      ; загрузка и сохранение дескрипторa иконки
    mov hCursor,rv(LoadCursor,0,IDC_ARROW)     ; загрузка курсора и сохранение
    mov sWid,rv(GetSystemMetrics,SM_CXSCREEN)  ; получение кол. пикселей по х монитора 
    mov sHgt,rv(GetSystemMetrics,SM_CYSCREEN)  ; получение кол. пикселей по y монитора
    mov hImage,rv(ResImageLoad,20)             ; макрос загрузки Bitmap
    call main
    GdiPlusEnd                                 ; GdiPlus cleanup
    invoke ExitProcess,0
    ret
entry_point endp

main proc
    LOCAL wc  :WNDCLASSEX           ; объявление локальных переменных
    LOCAL lft :QWORD                ; лок. переменные содержатся в стеке 
    LOCAL top :QWORD                ; и существуют только во время вып. проц.
    LOCAL wid :QWORD
    LOCAL hgt :QWORD
    mov wc.cbSize,SIZEOF WNDCLASSEX     ; колич. байтов структуры
    mov wc.style,CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW ; стиль окна
    mov wc.lpfnWndProc,ptr$(WndProc)    ; адрес процедуры WndProc
    mov wc.cbClsExtra,0	               ; количество байтов для структуры класса
    mov wc.cbWndExtra,0                 ; количество байтов для структуры окна
    mrm wc.hInstance,hInstance          ; заполнение поля дескриптора в структуре
    mrm wc.hIcon,  hIcon                ; хэндл иконки
    mrm wc.hCursor,hCursor              ; хэндл курсора
    mrm wc.hbrBackground,0              ; hBrush цвет окна
    mov wc.lpszMenuName,0               ; заполнение поля в структуре с именем ресурса меню
    mov wc.lpszClassName,ptr$(classname); имя класса
    mrm wc.hIconSm,hIcon
    invoke RegisterClassEx,ADDR wc      ; регистрация класса окна
    mov wid,960   ; ширина пользовательского окна в пикселях
    mov hgt,540   ; высота пользовательского окна в пикселях
    mov rax,sWid  ; колич. пикселей монитора по x
    sub rax,wid   ; дельта Х = Х(монитора) - х(окна пользователя)
    shr rax,1     ; получение середины Х
    mov lft,rax

    mov rax, sHgt ; колич. пикселей монитора по y
    sub rax, hgt
    shr rax, 1
    mov top, rax
    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES, \
    ADDR classname,ADDR title1, \
    WS_OVERLAPPED or WS_VISIBLE or WS_SYSMENU,\
    lft,top,wid,hgt,0,0,hInstance,0
    mov hWnd,rax ; сохранение дескриптора окна
    call msgloop
    ret
main endp

msgloop proc
    LOCAL msg    :MSG
    LOCAL pmsg   :QWORD
    mov pmsg, ptr$(msg) ; получение адреса структуры сообщения
    jmp gmsg            ; перейти в GetMessage()
    mloop:
    invoke TranslateMessage,pmsg
    invoke DispatchMessage,pmsg
    gmsg:
    test rax, rv(GetMessage,pmsg,0,0,0) ; пока GetMessage не вернет ноль
    jnz mloop
    ret
    msgloop endp

WndProc proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
.switch uMsg
    .case WM_COMMAND    ; если выбрано меню
        .switch wParam
            .case 101   ; если выбран вывод информации о задании
                .code
                    invoke MsgboxI,hWin,ptr$(task1),"Информация о задании",MB_OK,10
            .case 102   ; если выбран вывод задания
                .code
                    movq MM0,QWORD PTR arr1     ; загрузка массива чисел arr1
                    movq MM1,QWORD PTR arr2     ; загрузка массива чисел arr2
                    paddw MM0,MM1               ; параллельное циклическое сложение
                    movq QWORD PTR arr3,MM0     ; сохранение результата

                    pextrw rax,mm0,1            ; копирование первого слова в EAX
                    emms                        ; последняя MMX-команда
                    cmp eax,55      ; проверка больше ли 55
                    jg MoreThan55   ; если число больше 55
                    jmp LessThan55  ; если число меньше

                MoreThan55: 
                    fpuMacr  ; a-e/b
                    fld _d                  ; загрузка d
                    fmul _e                 ; d*e
                    fsub                    ; a-e/b-de
                    fisttp res1 ; сохранение результата
                    jmp _end    ; переход в конец

                LessThan55: 
                    fpuMacr  ; a-e/b
                    fisttp res1             ; сохранение результата

                _end:
                    invoke wsprintf,ADDR buf1,ADDR txt1,res1
                    invoke MsgboxI,hWin,ADDR buf1,"Результат",MB_OK,10

            .case 104   ; если выбран вывод информации об авторе
                .data
                    msgtxt db "Автор: Saltikov Ivan",10,10,"Группа: KN-921d",0 ; вывод данных об авторе
                .code
                    invoke MsgboxI,hWin,ptr$(msgtxt),"Информация об авторе",MB_OK,10

            .case 105   ; если выбран выход из программы
                .data
                    msg db "Выход из программы.",0                  ; вывод уведомления о выходе
                .code
                    invoke MsgboxI,hWin,ptr$(msg),"Выход",MB_OK,10
                    rcall SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,0 ; уничтожение окна
                    .endsw
            
            .case WM_CREATE
                invoke CreateWindowEx,WS_EX_LEFT,"STATIC",0,WS_CHILD or WS_VISIBLE or SS_BITMAP,\
                0,0,0,0,hWin,hInstance,0,0    
                mov hStatic,rax
                invoke SendMessage,hStatic,STM_SETIMAGE,IMAGE_BITMAP,hImage ; сообщение окну

                invoke LoadMenu,hInstance,100   ; загружает меню из exe-файла
                invoke SetMenu,hWin,rax         ; связывает меню с окном
                .return 0
            .case WM_CLOSE
                invoke SendMessage,hWin,WM_DESTROY,0,0
            .case WM_DESTROY 
                invoke PostQuitMessage,NULL
            .endsw

    invoke DefWindowProc,hWin,uMsg,wParam,lParam
    ret
WndProc endp
end