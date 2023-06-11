include \masm64\include64\masm64rt.inc ; подключение своей библиотеки

IDI_ICON EQU 1001
MSGBOXPARAMSA STRUCT    ; объ€вление системной структуры
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

.data               ; секци€ переменных
    params MSGBOXPARAMSA <>     ; инициализаци€ системной структуры
    title1 db "Ћабораторна€ работа 7-1",0     ; заголовок окна вывода
    txt1 db "The new languge is added.",0    ; текст дл€ вывода
    buf1 dq 1 dup(0),0              ; буфер дл€ вывода текста
    value db "00000442"             ; индекс €зыка
    szFileName db "vizitka7-1.exe",0   ; название файла дл€ вызова информации

.code               ; директива сегмента кода
entry_point proc
    invoke LoadKeyboardLayout,ADDR value,KLF_ACTIVATE ; установка раскладки
    invoke WinExec,addr szFileName,SW_SHOW  ; вызов подпрограммы с выводом информации
    

    invoke wsprintf,ADDR buf1,ADDR txt1
    invoke WinExec,addr szFileName,SW_SHOW  ; вызов подпрограммы с выводом информации
    mov params.cbSize,SIZEOF MSGBOXPARAMSA  ; размер структуры
    mov params.hwndOwner,0                  ; дескриптор окна владельца
    invoke GetModuleHandle,0                ; получение дескриптора программы
    mov params.hInstance,rax                ; сохранение дескриптора программы
    lea rax, buf1                           ; адрес сообщени€
    mov params.lpszText,rax
    lea rax,title1                          ; адрес заглави€ окна
    mov params.lpszCaption,rax
    mov params.dwStyle,MB_USERICON          ; стиль окна
    mov params.lpszIcon,IDI_ICON            ; ресурс значка
    mov params.dwContextHelpId,0            ; контекст справки
    mov params.lpfnMsgBoxCallback,0
    mov params.dwLanguageId,LANG_NEUTRAL    ; €зык сообщени€
    lea rcx,params
    invoke MessageBoxIndirect   ; вызов окна с результатом работы и иконкой
    invoke ExitProcess,0

entry_point endp
end
