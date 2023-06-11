include \masm64\include64\masm64rt.inc

IDI_ICON EQU 1001
 
.data?
    hInstance dq ? ; дескриптор програми
    hWnd      dq ? ; дескриптор окна
    hIcon     dq ? ; дескриптор иконки
    hCursor   dq ? ; дескриптор курсора
    sWid      dq ? ; ширина монитора (колич. пикселей по x)
    sHgt      dq ? ; высота монитора (колич. пикселей по y) 
    
.data
    color1 dd 97123
    mas dd 720
    alpha dd 0.0    ; угловая координата 
    delta dd 0.0175 ; один градус
    centerX dq ?    ; середина по X 
    centerY dq ?    ; середина по Y
    tmp dd 0        ; временная переменная
    divK dd 80.0    ; масштабный коэффициент
    xR dd 0.        ; координаты функции
    yR dd 0.0
    temp1 dd 0
    x1 dd 0.0
    x2 dq 2.0
	
    classname db "template_class",0
    caption db "Лабораторна робота 6-2. Графічні фігури",0

PaintCa macro
    ; invoke DestroyWindow,hWnd             ; уничтожение окна
    invoke BeginPaint, hWnd, addr ps        ; вызов функции начала рисования
    mov hdc, rax                            ; сохроанение контекста
    invoke GetClientRect, hWnd, addr rect   ; запись в структуру rect 

    invoke GetSystemMetrics,SM_CXSCREEN     ; получение ширины экрана в пикселях
    shr rax,1                               ; определение середины экрана по X
    mov centerX,320
    invoke GetSystemMetrics,SM_CYSCREEN     ; получение высоты экрана в пикселях
    shr rax,1                               ; определение середины экрана по Y
    mov centerY,260
    mov r10d,mas                            ; сохранение количества циклов
    mov temp1,r10d

    finit                       ; инициализация сопроцессора
    
cycle1:                      
    fld alpha                   ; загрузка a
    fmul x2                     ; 2a
    fcos                        ; cos(2a)
    fld divK                    ; загрузка коэффициента масштаба
    fmul                        ; cos(2a)*divK
    fld alpha                   ; загрузка a
    fcos                        ; cos(a)
    fmul x2                     ; 2cos(a)
    fmul divK                   ; divK*2cos(a)
    fsub
    fild centerY                ; загрузка центра экрана по Y
    fadd                        ; centerY + a*divK*cos(a)
    fistp dword ptr yR          ; сохранение Y для выведения на экран

    fld alpha                   ; загрузка a
    fmul x2                     ; 2a
    fsin                        ; cos(2a)
    fld divK                    ; загрузка коэффициента масштаба
    fmul                        ; cos(2a)*divK
    fld alpha                   ; загрузка a
    fsin                        ; sin(a)
    fmul x2                     ; 2sin(a)
    fmul divK                   ; divK*2cos(a)
    fsub                        ; a*divK*cos(a)

    fild centerX                ; загрузка центра экрана по X
    fadd                        ; centerX + a*divK*sin(a)
    fistp dword ptr xR          ; сохранение X

    invoke Sleep,1              ; задержка при рисовании
    invoke SetPixel, hdc, xR, yR, color1	; изменение цвета пикселя
    movss XMM3,delta
    addss XMM3,alpha
    movss alpha,XMM3

    dec temp1   		; уменьшение счетчика
    jz _end       		; продолжение рисование
    jmp cycle1			; возвращение в начало цикла
    
_end:
    endm

CursorCa macro
    invoke GetSystemMetrics,SM_CXSCREEN ; получение ширины экрана в пикселях
    shr rax,1                           ; определение середины экрана по X
    mov centerX,rax
    invoke GetSystemMetrics,SM_CYSCREEN ; получение высоты экрана в пикселях
    shr rax,1                           ; определение середины экрана по Y
    mov centerY,rax
    mov r10d,mas                        ; сохранение количества циклов
    mov temp1,r10d
	
    finit                               ; инициализация сопроцессора

cycle2:                      
    fld alpha           ; загрузка альфы
    fmul x2             ; 2а
    fcos                ; cos(2a)
    fld divK            ; загрузка коэффициента масштаба
    fmul                ; divK*cos(2a)
    fld alpha           ; загрузка а
    fcos                ; cos(a)
    fmul x2             ; 2cos(a)
    fmul divK           ; divK*2cos(a)
    fsub

    fild centerY        ; загрузка центра экрана по Y
    fadd                ; centerY + a*divK*cos(a) 
    fistp dword ptr yR  ; сохранение Y для выведения на экран

    fld alpha           ; загрузка а
    fmul x2             ; 2a
    fsin                ; sin(2a)
    fld divK            ; загрузка коэффициента масштаба
    fmul
    fld alpha           ; загрузка а
    fsin                ; sin(a)
    fmul x2             ; 2sin(a)
    fmul divK           ; divK*2sin(a) st1 = divk*cos(2a)
    fsub                ; a*divK*cos(a)

    fild centerX      
    fadd                ; xR := centerX + ...
    fistp dword ptr xR  ; сохранение X

    invoke Sleep,1              ; задержка при рисовании
    invoke SetCursorPos,xR,yR   ; установление курсора по xR, yR 
    movss XMM3,delta
    addss XMM3,alpha
    movss alpha,XMM3

dec temp1   ; уменьшение счетчика циклов
dec temp1   ; уменьшение счетчика циклов
jz _end2    ; завершить рисование
jmp cycle2  ; переход в начало цикла

_end2:
    endm

.code
entry_point proc
    mov hInstance,rv(GetModuleHandle,0)         ; получение и сохранение дескрипторa програми
    mov hIcon,  rv(LoadIcon,hInstance,10)       ; загрузка и сохранение дескрипторa иконки
    mov hCursor,rv(LoadCursor,0,IDC_ARROW)      ; загрузка курсора и сохранение
    mov sWid,rv(GetSystemMetrics,SM_CXSCREEN)   ; получение кол. пикселей по х монитора 
    mov sHgt,rv(GetSystemMetrics,SM_CYSCREEN)   ; получение кол. пикселей по y монитора
    ; mov hBrush,rvcall(CreateSolidBrush,00C4C4C4h)
    call main                                   ; вызов процедуры main
    rcall ExitProcess,0
    ret
entry_point endp

msgloop proc
    LOCAL msg  :MSG
    LOCAL pmsg :QWORD
    mov pmsg, ptr$(msg)      ; получение адреса структуры сообщения
    jmp gmsg                 ; jump directly to GetMessage()
    
mloop:
    rcall TranslateMessage,pmsg
    rcall DispatchMessage,pmsg
    
gmsg:
    test rax, rvcall(GetMessage,pmsg,0,0,0) ; пока GetMessage не вернет ноль
    jnz mloop
    ret
msgloop endp

main proc
    LOCAL wc  :WNDCLASSEX               ; объявление локальных переменных
    LOCAL lft :QWORD                    ; лок. переменные содержатся в стеке 
    LOCAL top :QWORD                    ; и существуют только во время вып. проц.
    LOCAL wid :QWORD
    LOCAL hgt :QWORD
    LOCAL rect:RECT                     ; резервирование стека под структуру
    LOCAL ps:PAINTSTRUCT                ; резервирование стека под структуру
    LOCAL hdc:HDC                       ; резервирование стека под хендл окна
    mov wc.cbSize,SIZEOF WNDCLASSEX     ; количество байтов структуры
    mov wc.style,CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW ; стиль окна
    mov wc.lpfnWndProc,ptr$(WndProc)    ; адрес процедуры WndProc
    mov wc.cbClsExtra,0                 ; количество байтов для структуры класса
    mov wc.cbWndExtra,0                 ; количество байтов для структуры окна
    mrm wc.hInstance,hInstance          ; заполнение пол¤ дескриптора в структуре
    mrm wc.hIcon,  hIcon                ; хэндл иконки
    mrm wc.hCursor,hCursor              ; хэндл курсора
    mrm wc.hbrBackground,0              ; hBrush цвет окна
    mov wc.lpszMenuName,0               ; заполнение пол¤ в структуре с именем ресурса меню
    mov wc.lpszClassName,ptr$(classname); имя класса
    mrm wc.hIconSm,hIcon
    invoke RegisterClassEx,ADDR wc      ; регистраци¤ класса окна
    mov wid, 640                        ; ширина пользовательского окна в пикселях
    mov hgt, 640                        ; высота пользовательского окна в пикселях
    mov rax,sWid                        ; количество пикселей монитора по x
    sub rax,wid                         ; дельта Х = Х(монитора) - х(окна пользователя)
    shr rax,1                           ; получение середины Х
    mov lft,rax
    mov rax, sHgt                       ; количество пикселей монитора по y
    sub rax, hgt 						;
    shr rax, 1 							;
    mov top, rax 						;
    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES, \
        ADDR classname,ADDR caption, \
        WS_OVERLAPPED or WS_VISIBLE or WS_SYSMENU,\
        lft,top,wid,hgt,0,0,hInstance,0
    mov hWnd,rax ; сохранение дескриптора окна
    PaintCa
    call msgloop
    ret
main endp

WndProc proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
LOCAL dfbuff[260]:BYTE
LOCAL pbuff :QWORD
LOCAL rect:RECT             ; резервування стека під структуру RECT
LOCAL ps:PAINTSTRUCT        ; резервування стека під структуру 
LOCAL hdc:HDC               ; резервування стека під хендл вікна
    
.switch uMsg
    .case WM_COMMAND
        .switch wParam
            .case 10003
                rcall SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL
					
            .case 10002
                invoke MsgboxI,hWin,"Малюємо кардіоіду","Малювання кардіоіди",MB_OK,10
                PaintCa
					
            .case 10004
                invoke MsgboxI,hWin,"Переміщення курсору","У просессі...",MB_OK,10
                CursorCa
					
            .case 10005
                .data
                    Task db "Намалювати кардіоіду відповідно до формул. Координати вершин в параметричних координатах задаются за формулам:",10,"X = 2Rcost(1+cost);",10,"Y = 2Rsint(1+cost);",10,"де R – рідиус окружности.",0
                .code
                    invoke MsgboxI,hWin,ptr$(Task),"Завдання",MB_OK,10
					
            .case 10001
                .data
                    msgtxt db "Автор: Іван Салтиков",10,"Группа: КН-921д",0
                .code
                    invoke MsgboxI,hWin,ptr$(msgtxt),"Автор",MB_OK,10
        .endsw

    .case WM_CREATE
        rcall LoadMenu,hInstance,10000
        rcall SetMenu,hWin,rax
        .return 0

    .case WM_CLOSE
        rcall SendMessage,hWin,WM_DESTROY,0,0
			
    .case WM_DESTROY
        rcall PostQuitMessage,NULL
.endsw

rcall DefWindowProc,hWin,uMsg,wParam,lParam
ret
WndProc endp
end

