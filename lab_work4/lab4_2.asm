include \masm64\include64\masm64rt.inc

IDI_ICON EQU 1001
MSGBOXPARAMSA STRUCT    ; объявление системной структуры
    cbSize DWORD ?,?
    hwndOwner QWORD ?
    hInstance QWORD ?
    lpszText QWORD ?
    lpszCaption QWORD ?
    dwStyle DWORD ?,?
    lpszIcon QWORD ?
    dwContextHelpId QWORD ?
    lpfnMsgBoxCallback QWORD ?
    dwLanguageId DWORD ?,?
MSGBOXPARAMSA ENDS

mSub macro a, b ;; макрос с именем mSub
    fld a       ;; загрузка a
    fld b       ;; загрузка b
    fsub        ;; a-b
endm            ;; окончание макроса

.data
    params MSGBOXPARAMSA <>     ; инициализация системной структуры
    hInstance dq ?              ; дескриптор програми
    hWnd      dq ?              ; дескриптор окна
    hIcon     dq ?              ; дескриптор иконки
    hCursor   dq ?              ; дескриптор курсора
    sWid      dq ?              ; ширина монитора (колич. пикселей по x)
    sHgt      dq ?              ; высота монитора (колич. пикселей по y) 
    classname db "template_class",0
    caption db "Результат выполнения арифметического выражения",0
	
    title1 db "Лабораторная работа 4-2. Макросы",0
    txt1 db "Написать на ассемблере программу вычисления выражения, в котором одна из переменных изменяется несколько раз.",10,10
    txt2 db "Выражение: 3,5(a – b) – (a – b)/5,1",10,10
    txt3 db "Автор: Ivan Salikov, KN-921d",0

    buf dq 30 dup(?),0      ; буффер для вывода
    buf1 dq 3 dup(?),0      ; буффер для вывода
    buf2 db 80 dup(?),0     ; буффер для вывода
    buf3 dq buf2,0          ; буффер для вывода
    buf4 db 16 dup(?),0     ; буффер для вывода

    const1 real4 3.5        ; переменная константа
    const2 real4 5.1        ; переменная константа
    a1 real4 3.7
    b1 real4 5.2
    res1 real8 0.0          ; переменная результата
    res2 dq 0               ; переменная результата

.code
entry_point proc
    finit           ; инициализация стека
    mSub [a1],[b1]  ; a-b
    fmul const1     ; 3.5(a-b)
    
    mSub [a1],[b1]  ; a-b
    fdiv const2     ; (a-b)/5.1
    fsub            ; 3.5(a-b)-(a-b)/5.1
    fst res1        ; получение результата
    fistp res2      ; получение результата

    mov hInstance,rv(GetModuleHandle,0)         ; получение и сохранение дескрипторa програми
    mov hIcon,  rv(LoadIcon,hInstance,10)       ; загрузка и сохранение дескрипторa иконки
    mov hCursor,rv(LoadCursor,0,IDC_ARROW)      ; загрузка курсора и сохранение
    mov sWid,rv(GetSystemMetrics,SM_CXSCREEN)   ; получение кол. пикселей по х монитора 
    mov sHgt,rv(GetSystemMetrics,SM_CYSCREEN)   ; получение кол. пикселей по y монитора
    call main                                   ; вызов процедуры main
    invoke ExitProcess,0
	ret
entry_point endp

main proc
    LOCAL wc  :WNDCLASSEX               ; объявление локальных переменных
    LOCAL lft :QWORD                    ; лок. переменные содержатся в стеке 
    LOCAL top :QWORD                    ; и существуют только во время вып. проц.
    LOCAL wid :QWORD
    LOCAL hgt :QWORD
    mov wc.cbSize,SIZEOF WNDCLASSEX     ; колич. байтов структуры
    mov wc.style,CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW ; стиль окна
    mov wc.lpfnWndProc,ptr$(WndProc)    ; адрес процедуры WndProc
    mov wc.cbClsExtra,0                 ; количество байтов для структуры класса
    mov wc.cbWndExtra,0                 ; количество байтов для структуры окна
    mrm wc.hInstance,hInstance          ; заполнение поля дескриптора в структуре
    mrm wc.hIcon,  hIcon                ; хэндл иконки
    mrm wc.hCursor,hCursor              ; хэндл курсора
    mrm wc.hbrBackground,0              ; цвет окна
    mov wc.lpszMenuName,0               ; заполнение поля в структуре с именем ресурса меню
    mov wc.lpszClassName,ptr$(classname); имя класса
    mrm wc.hIconSm,hIcon
    invoke RegisterClassEx,ADDR wc      ; регистрация класса окна
    mov wid, 900                        ; ширина пользовательского окна в пикселях
    mov hgt, 300                        ; высота пользовательского окна в пикселях
    mov rax,sWid                        ; колич. пикселей монитора по x
    sub rax,wid                         ; дельта Х = Х(монитора) - х(окна пользователя)
    shr rax,1                           ; получение середины Х
    mov lft,rax                         ;

    mov rax, sHgt       ; колич. пикселей монитора по y
    sub rax, hgt        ;
    shr rax, 1          ;
    mov top, rax        ;
    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES, \
    ADDR classname,ADDR caption, \
    WS_OVERLAPPED or WS_VISIBLE or WS_SYSMENU,\
    lft,top,wid,hgt,0,0,hInstance,0
    mov hWnd,rax        ; сохранение дескриптора окна
    call msgloop
    ret
main endp

msgloop proc
    LOCAL msg    :MSG
    LOCAL pmsg   :QWORD
    mov pmsg, ptr$(msg) ; получение адреса структуры сообщения
    jmp gmsg            ; jump directly to GetMessage()
    mloop:
        invoke TranslateMessage,pmsg
        invoke DispatchMessage,pmsg
    
    gmsg:
        test rax, rv(GetMessage,pmsg,0,0,0) ; пока GetMessage не вернет ноль
        jnz mloop
        ret
msgloop endp

    WndProc proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
    LOCAL hdc:HDC                   ; резервирование стека для дескриптора окна
    LOCAL ps:PAINTSTRUCT            ; для структуры PAINTSTRUCT
    LOCAL rect:RECT                 ; для структуры координат RECT
    LOCAL leng:QWORD
    .switch uMsg
    .case WM_DESTROY
        invoke PostQuitMessage,NULL
    .case WM_PAINT                      ; если есть смс о перерисовании
        invoke BeginPaint,hWnd, ADDR ps ; вызов подготовительной процедуры
        mov hdc,rax                     ; сохранение контекста
	
    invoke fptoa,res1,buf3
    invoke TextOut,hdc,40,35,buf3,10

    ;invoke wsprintf,ADDR buf1,ADDR txt1        ; преобразование данных в текст
    ;invoke wsprintf,ADDR buf2,ADDR txt2        ; преобразование данных в текст
    ;invoke wsprintf,ADDR buf,ADDR txt3,res1   	; преобразование данных в текст

    ;invoke TextOut,hdc,20,0,addr buf1,109      ; вывод текста в окно
    ;invoke TextOut,hdc,20,20,addr buf2,35      ; вывод текста в окно
    ;invoke TextOut,hdc,20,60,addr buf,30       ; вывод текста в окно
 
    invoke wsprintf,ADDR buf1,ADDR txt1,ADDR txt2, ADDR txt3
    mov params.cbSize,SIZEOF MSGBOXPARAMSA  ; размер структуры
    mov params.hwndOwner,0                  ; дескриптор окна владельца
    invoke GetModuleHandle,0                ; получение дескриптора программы
    mov params.hInstance,rax                ; сохранение дескриптора программы
    lea rax, buf1                           ; адрес сообщения
    mov params.lpszText,rax
    lea rax,title1                          ; адрес заглавия окна
    mov params.lpszCaption,rax
    mov params.dwStyle,MB_USERICON          ; стиль окна
    mov params.lpszIcon,IDI_ICON            ; ресурс значка
    mov params.dwContextHelpId,0            ; контекст справки
    mov params.lpfnMsgBoxCallback,0
    mov params.dwLanguageId,LANG_NEUTRAL    ; язык сообщения
    lea rcx,params
    invoke MessageBoxIndirect   ; вызов окна с результатом работы и иконкой
    invoke ExitProcess,0

    invoke EndPaint, hWnd, ADDR ps
    .endsw                                  ; иначе обработка по умолчанию
        invoke DefWindowProc,hWin,uMsg,wParam,lParam

ret
WndProc endp
end