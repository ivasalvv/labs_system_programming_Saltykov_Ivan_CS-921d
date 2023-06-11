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

array STRUCT   ; начало объявления пользовательской структуры
    el1 dq ?
    el2 dq ?
    el3 dq ?
    el4 dq ?
    el5 dq ?
    el6 dq ?
    el7 dq ?
    el8 dq ?
array ENDS     ; конец объявления пользовательской структуры

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

    mas1 db 'Cheerful and full of energy, enthusiastic, vivacious eagle-eyed. ' ; обрабатываемый текст
    len1 equ ($-mas1)/type mas1     ; определение количества байтов в массиве mas1
    countWord dq 0                  ; счетчик слов
    countE db 0                     ; счетчик нужных символов
    resE array <-1,?,?,?,?,?,?,?>    ; инициализация 1 строки массива А    

    title1 db "Лабораторная работа 5-1. Строковые команды",0
    task db "Задан текст из 8 слов, разделенных пропуском. Определить количество повторений буквы Е в каждом слове.", 0
    buf1 dq 12 dup(0),0
    ifmt1 db "Результат:",10,
    "Слово 1: %d",10,
    "Слово 2: %d",10,
    "Слово 3: %d",10,
    "Слово 4: %d",10,
    "Слово 5: %d",10,
    "Слово 6: %d",10,
    "Слово 7: %d",10,
    "Слово 8: %d",0

    classname db "template_class",0
    BSIZE1 equ 100                              ; кол-во байтов записываемых в файл
    fName BYTE "result.txt",0                   ; название файла для вывода
    fHandle dq ?                                ; дескриптор файла
    cWritten dq ?                               ; ячейки для адреса символов вывода 

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
                    invoke MsgboxI,hWin,ptr$(task),"Информация о задании",MB_OK,10
            .case 102   ; если выбран вывод задания
                .code
                    xor rsi,rsi     ; очистка регистра RSI
                    xor rcx,rcx     ; очистка регистра RCX
                    xor r11,r11     ; очистка регистра R11
                    xor r12,r12     ; очистка регистра R12
                    xor r13,r13     ; очистка регистра R13

                    lea r12,resE    ; установка массива в начало               
                    lea rsi,mas1    ; загрузка адреса массива mas1
                    mov r14, ' '    ; загрузка пробела
                    mov r15, 'e'    ; загрузка символа е        
                    mov rcx, len1   ; установка в счётчик максимальное значение букв
                    cld             ; направление - вверх (признак DF)
                
                cycle:
                    lodsb           ; получаем символ
                    cmp rax,r15     ; сравниваем с Е
                    je foundE       ; переход если найдена Е
                    cmp rax,r14     ; сравниваем с пробелом
                    je foundSpace   ; переход если найден пробел

                    add rdi,1       ; переход на следующий символ
                    loop cycle      ; переход в начало цикла
                    jmp _end        ; если весь текст проверен

                foundE:
                    add r11,1   ; увеличение переменной кол-ва е
                    jmp cycle   ; переход в начало цикла

                foundSpace:
                    mov [r12],r11   ; запись кол-ва Е в массив результатов
                    add r12,8       ; перемещение на следующий элемент массива
                    mov r11,0       ; очистка регистра кол-ва нахождений Е
                    jmp cycle       ; переход в начало цикла
	
                _end:
                    invoke wsprintf,ADDR buf1,ADDR ifmt1,resE.el1,resE.el2,resE.el3,resE.el4,resE.el5,resE.el6,resE.el7,resE.el8
                    invoke MessageBox,0,addr buf1,addr title1,MB_OK     ; вывод данных на экран

            .case 103   ; если выбрано сохранение в файл
                .data
                    msg1 db "Сохранение результата в файл.",0   ; уведомление о выходе
                    const1 dq -1
                .code
                    mov rax,resE.el1
                    cmp rax,const1
                    je NoResult
                    jne HaveResult
                    
                NoResult:
                    invoke MsgboxI,hWin,"Результат вычислений отсутствует. Выполните расчёт в начале.","Ошибка",MB_OK,10
                    jmp _end2
                        
                HaveResult:
                    invoke MsgboxI,hWin,ptr$(msg1),"Сохранение в файл",MB_OK,10 ; вывод окна с уведомлением
                    invoke CreateFile,ADDR fName,GENERIC_WRITE,0,0,CREATE_ALWAYS,FILE_ATTRIBUTE_ARCHIVE,0
                    mov fHandle,rax
                    invoke WriteFile,fHandle,ADDR buf1,BSIZE1,ADDR cWritten,0   ; запись результата в файл

                _end2:
                    xor rax,rax

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