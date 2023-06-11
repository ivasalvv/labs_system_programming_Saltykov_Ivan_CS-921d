include \masm64\include64\masm64rt.inc
.data?
    hInstance dq ?
    hIcon     dq ?
    hBmp      dq ?
    hStatic   dq ?

.data
    arr1 dq -1.3, 2.1, 3.8, 1.0, 5.4, 6.12, 7.54    ; ������ 1
    arr2 dq -1., -5.0, -3.54, 1.5, -5.8, -6.53, 7.5 ; ������ 2
    len1 dq 7           ; ���������� ����� � ��������   
    arr3 dq 7 dup(0)    ; �������������� ������
    countFirst dq 0
    countSecond dq 0
    
    fmt db "����� 1:",10,"-1.3     2.1     3.8     1.0     5.4     6.12     7.54",10,10,
    "������ 2:",10,"-1     -5.0     -3.54     1.5     -5.8     -6.53     7.5",10,10,
    "���������:",10,"%d     %d     %d     %d     %d     %d     %d",10,0
    buf dq 12 dup(0),0

.code
entry_point proc
    GdiPlusBegin        ; ������������� GDIPlus
        mov hInstance, rv(GetModuleHandle,0)
        mov hIcon,rv(LoadImage,hInstance,10,IMAGE_ICON,32,32,LR_DEFAULTCOLOR)
        mov hBmp,rv(ResImageLoad,20)
        invoke DialogBoxParam,hInstance,100,0,ADDR main,hIcon
    GdiPlusEnd          ; GdiPlus �������
        invoke ExitProcess,0
    ret
entry_point endp

main proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
    .switch uMsg
        .case WM_INITDIALOG ; ��������� � �������� ����. ����
            invoke SendMessage,hWin,WM_SETICON,1,lParam
            mov hStatic, rv(GetDlgItem,hWin,102)
            invoke SendMessage,hStatic,STM_SETIMAGE,IMAGE_BITMAP,hBmp
        .return TRUE
        .case WM_COMMAND    ; ��������� �� ���� ��� ������
            .switch wParam
                .case 101   ; ���� ������ ����� ���������� � �������
                    .data
                        txt2 db "��������� ������������ ��������� �������� �� 7-�� 64-��������� ������������ �����. ���� ������ ������ ������ �������, �� ��������� �������� ������� ��� ��������� �����, ����� � ���������.",0
                        titl2 db "���������� � �������",0
                    .code
                        invoke MsgboxI,hWin,ADDR txt2,ADDR titl2,MB_OK,10
                
                .case 102   ; ���� ������ ����� ���������� �� ������
                    .data
                        txt1 db "�����: Saltikov Ivan",10,"������: KN-921d",0
                    .code
                        invoke MsgboxI,hWin,ADDR txt1,"���������� �� ������",MB_OK,10
                .case 103
                    .data
                        msg db "����� �� ���������.",0                  ; ����� ����������� � ������
                    .code
                        invoke MsgboxI,hWin,ptr$(msg),"�����",MB_OK,10
                        rcall SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,0 ; ����������� ����

                .case 1001  ; ���������� �� � SSE
                 .code
                    mov countFirst,0    ; ��������� ���������� ����� ������������
                    mov countSecond,0   ; ��������� ���������� ����� ������������
                    mov rcx,len1        ; ���-�� ������
                    lea rsi,arr1    ; ��������� ��������� �� ������ 1
                    lea rdi,arr2    ; ��������� ��������� �� ������ 2
                    lea rbx,arr3    ; ��������� ��������� �� ������ 3
                    jmp cycleSSE    ; ������� � ���� �������� �������

                FirstOrEqualSSE:        ; ���� ������� ������� ������� >=
                    add countFirst,1    ; ���������� ���������� �� 1
                    jmp cycleSSE           ; ������� � ����

                SecondSSE:                 ; ���� ������� ������� ������� <
                    add countSecond,1   ; ���������� ���������� �� 1 

                cycleSSE:                  ; ���� ��������� ��������� ���������
                    cmp rcx,0           ; �������� �� ���������� �����
                    je nextSSE             ; ������� �� �������� ����� ������ ������
                    movsd XMM0,qword ptr[rsi]   ; ��������� �������� �� ������� 1
                    movsd XMM1,qword ptr[rdi]   ; ��������� �������� �� ������� 2

                    add rsi,8           ; ������� �� ��������� ������� ������� 1
                    add rdi,8           ; ������� �� ��������� ������� ������� 1
                    dec rcx             ; ���������� �������� ������

                    comisd XMM0,XMM1    ; ��������� ���������

                    jnb FirstOrEqualSSE    ; ���� ������� ������� ������� ������
                    jb SecondSSE           ;
                loop cycleSSE

                nextSSE:
                    lea rsi,arr1    ; ��������� ��������� �� ������ 1
                    lea rdi,arr2    ; ��������� ��������� �� ������ 2
                    lea rbx,arr3    ; ��������� ��������� �� ������ 3
                    mov rax,countFirst  
                    mov rbx,countSecond
                    cmp rax,rbx     ; ������� ����� ������ ������
                    ja MultiplicationSSE
        
                DivisionSSE:               ; ������� ��������
                    movups XMM0,[rsi]   ; ��������� �������� �� ������� 1
                    movups XMM1,[rdi]   ; ��������� �������� �� ������� 2
                    divpd xmm0,xmm1     ; ������� 2-� ��� ���������

                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ��������� � ������� EAX �� MM0
                    mov arr3,rax            ; ������ � �������������� ������
    
                    unpckhpd xmm0,xmm2      ; �������� ������� �������� ����� � �������
                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 2
                    mov arr3[8],rax         ; ������ � �������������� ������
    
                    add rsi,16          ; ����������� ��������� �� ��������� �������
                    add rdi,16          ; ����������� ��������� �� ��������� �������
                    movups XMM0,[rsi]   ; ��������� �������� �� ������� 1
                    movups XMM1,[rdi]   ; ��������� �������� �� ������� 2
                    divpd xmm0,xmm1     ; ������� 2-� ��� ��������� 

                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 3
                    mov arr3[16],rax        ; ������ � �������������� ������
        
                    unpckhpd xmm0,xmm2      ; �������� ������� �������� ����� � �������
                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 4
                    mov arr3[24],rax        ; ������ � �������������� ������
    
                    add rsi,16          ; ����������� ��������� �� ��������� �������
                    add rdi,16          ; ����������� ��������� �� ��������� �������
                    movups XMM0,[rsi]   ; ��������� �������� �� ������� 1
                    movups XMM1,[rdi]   ; ��������� �������� �� ������� 2
                    divpd xmm0,xmm1     ; ������� 2-� ��� ��������� 

                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 5
                    mov arr3[32],rax        ; ������ � �������������� ������

                    unpckhpd xmm0,xmm2      ; �������� ������� �������� ����� � �������
                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 6
                    mov arr3[40],rax        ; ������ � �������������� ������

                    add rsi,16          ; ����������� ��������� �� ��������� �������
                    add rdi,16          ; ����������� ��������� �� ��������� �������
                    movups XMM0,[rsi]   ; ��������� �������� �� ������� 1
                    movups XMM1,[rdi]   ; ��������� �������� �� ������� 2
                    divpd xmm0,xmm1     ; ������� 2-� ��� ��������� 

                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 7
                    mov arr3[48],rax        ; ������ � �������������� ������
                    jmp _endSSE                ; ������� � ����� ���������
    
                MultiplicationSSE:         ; ��������� ��������
                    movups XMM0,[rsi]   ; ��������� �������� �� ������� 1
                    movups XMM1,[rdi]   ; ��������� �������� �� ������� 2
                    mulpd xmm0,xmm1     ; ��������� ���� ��� ���������

                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 1
                    mov arr3,rax            ; ������ � �������������� ������
    
                    unpckhpd xmm0,xmm2      ; �������� ������� �������� ����� � �������
                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 2
                    mov arr3[8],rax         ; ������ � �������������� ������
    
                    add rsi,16          ; ����������� ��������� �� ��������� �������
                    add rdi,16          ; ����������� ��������� �� ��������� �������
                    movups XMM0,[rsi]   ; ��������� �������� �� ������� 1
                    movups XMM1,[rdi]   ; ��������� �������� �� ������� 2
                    mulpd xmm0,xmm1     ; ��������� ���� ��� ���������

                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 3
                    mov arr3[16],rax        ; ������ � �������������� ������
    
                    unpckhpd xmm0,xmm2      ; �������� ������� �������� ����� � �������
                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 4
                    mov arr3[24],rax        ; ������ � �������������� ������
    
                    add rsi,16          ; ����������� ��������� �� ��������� �������
                    add rdi,16          ; ����������� ��������� �� ��������� �������
                    movups XMM0,[rsi]   ; ��������� �������� �� ������� 1
                    movups XMM1,[rdi]   ; ��������� �������� �� ������� 2
                    mulpd xmm0,xmm1     ; ��������� ���� ��� ���������

                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 5
                    mov arr3[32],rax        ; ������ � �������������� ������ 

                    unpckhpd xmm0,xmm2      ; �������� ������� �������� ����� � �������
                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 6
                    mov arr3[40],rax        ; ������ � �������������� ������

                    add rsi,16          ; ����������� ��������� �� ��������� �������
                    add rdi,16          ; ����������� ��������� �� ��������� �������
                    movups XMM0,[rsi]   ; ��������� �������� �� ������� 1
                    movups XMM1,[rdi]   ; ��������� �������� �� ������� 2
                    mulpd xmm0,xmm1     ; ��������� ���� ��� ���������

                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 7
                    mov arr3[48],rax        ; ������ � �������������� ������

                _endSSE:
                    mov r8,arr3         ; ������ � ������� r8
                    mov r9,arr3[8]      ; ������ � ������� r9
                    mov r10,arr3[16]    ; ������ � ������� r10
                    mov r11,arr3[24]    ; ������ � ������� r11
                    mov r12,arr3[32]    ; ������ � ������� r12
                    mov r13,arr3[40]    ; ������ � ������� r13
                    mov r14,arr3[48]    ; ������ � ������� r14

                    invoke wsprintf, ADDR buf, ADDR fmt, r8,r9,r10,r11,r12,r13,r14
                    invoke MsgboxI,hWin,ADDR buf,"��������� ���������� SSE",MB_OK,10

                .case 1003  ; ���� ������� ���������� �� � AVX
                    mov countFirst,0    ; ��������� ���������� ����� ������������
                    mov countSecond,0   ; ��������� ���������� ����� ������������
                    mov rcx,len1    ; ���-�� ������
                    lea rsi,arr1    ; ��������� ��������� �� ������ 1
                    lea rdi,arr2    ; ��������� ��������� �� ������ 2
                    lea rbx,arr3    ; ��������� ��������� �� ������ 3
                    jmp cycleAVX       ; ������� � ���� �������� �������

                FirstOrEqualAVX:           ; ���� ������� ������� ������� >=
                    add countFirst,1    ; ���������� ���������� �� 1
                    jmp cycleAVX           ; ������� � ����

                SecondAVX:                 ; ���� ������� ������� ������� <
                    add countSecond,1   ; ���������� ���������� �� 1 

                cycleAVX:                  ; ���� ��������� ��������� ���������
                    cmp rcx,0           ; �������� �� ���������� �����
                    je nextAVX             ; ������� �� �������� ����� ������ ������
                    vmovsd XMM0,qword ptr[rsi]   ; ��������� �������� �� ������� 1
                    vmovsd XMM1,qword ptr[rdi]   ; ��������� �������� �� ������� 2

                    add rsi,8           ; ������� �� ��������� ������� ������� 1
                    add rdi,8           ; ������� �� ��������� ������� ������� 1
                    dec rcx             ; ���������� �������� ������

                    vcomisd XMM0,XMM1    ; ��������� ���������

                    jnb FirstOrEqualAVX    ; ���� ������� ������� ������� ������
                    jb SecondAVX           ;
                loop cycleAVX

                nextAVX:
                    lea rsi,arr1    ; ��������� ��������� �� ������ 1
                    lea rdi,arr2    ; ��������� ��������� �� ������ 2
                    lea rbx,arr3    ; ��������� ��������� �� ������ 3
                    mov rax,countFirst  
                    mov rbx,countSecond
                    cmp rax,rbx     ; ������� ����� ������ ������
                    ja MultiplicationAVX
        
                DivisionAVX:               ; ������� ��������
                    vmovups XMM0,[rsi]   ; ��������� �������� �� ������� 1
                    vmovups XMM1,[rdi]   ; ��������� �������� �� ������� 2
                    divpd xmm0,xmm1     ; ������� 2-� ��� ���������

                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ��������� � ������� EAX �� MM0
                    mov arr3,rax            ; ������ � �������������� ������
    
                    unpckhpd xmm0,xmm2      ; �������� ������� �������� ����� � �������
                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 2
                    mov arr3[8],rax         ; ������ � �������������� ������
    
                    add rsi,16          ; ����������� ��������� �� ��������� �������
                    add rdi,16          ; ����������� ��������� �� ��������� �������
                    vmovups XMM0,[rsi]   ; ��������� �������� �� ������� 1
                    vmovups XMM1,[rdi]   ; ��������� �������� �� ������� 2
                    divpd xmm0,xmm1     ; ������� 2-� ��� ��������� 

                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 3
                    mov arr3[16],rax        ; ������ � �������������� ������
        
                    unpckhpd xmm0,xmm2      ; �������� ������� �������� ����� � �������
                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 4
                    mov arr3[24],rax        ; ������ � �������������� ������
    
                    add rsi,16          ; ����������� ��������� �� ��������� �������
                    add rdi,16          ; ����������� ��������� �� ��������� �������
                    vmovups XMM0,[rsi]   ; ��������� �������� �� ������� 1
                    vmovups XMM1,[rdi]   ; ��������� �������� �� ������� 2
                    divpd xmm0,xmm1     ; ������� 2-� ��� ��������� 

                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 5
                    mov arr3[32],rax        ; ������ � �������������� ������

                    unpckhpd xmm0,xmm2      ; �������� ������� �������� ����� � �������
                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 6
                    mov arr3[40],rax        ; ������ � �������������� ������

                    add rsi,16          ; ����������� ��������� �� ��������� �������
                    add rdi,16          ; ����������� ��������� �� ��������� �������
                    vmovups XMM0,[rsi]   ; ��������� �������� �� ������� 1
                    vmovups XMM1,[rdi]   ; ��������� �������� �� ������� 2
                    divpd xmm0,xmm1     ; ������� 2-� ��� ��������� 

                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 7
                    mov arr3[48],rax        ; ������ � �������������� ������
                    jmp _endAVX                ; ������� � ����� ���������
    
                MultiplicationAVX:         ; ��������� ��������
                    vmovups XMM0,[rsi]   ; ��������� �������� �� ������� 1
                    vmovups XMM1,[rdi]   ; ��������� �������� �� ������� 2
                    mulpd xmm0,xmm1     ; ��������� ���� ��� ���������

                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 1
                    mov arr3,rax            ; ������ � �������������� ������
    
                    unpckhpd xmm0,xmm2      ; �������� ������� �������� ����� � �������
                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 2
                    mov arr3[8],rax         ; ������ � �������������� ������
    
                    add rsi,16          ; ����������� ��������� �� ��������� �������
                    add rdi,16          ; ����������� ��������� �� ��������� �������
                    vmovups XMM0,[rsi]   ; ��������� �������� �� ������� 1
                    vmovups XMM1,[rdi]   ; ��������� �������� �� ������� 2
                    mulpd xmm0,xmm1     ; ��������� ���� ��� ���������

                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 3
                    mov arr3[16],rax        ; ������ � �������������� ������
    
                    unpckhpd xmm0,xmm2      ; �������� ������� �������� ����� � �������
                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 4
                    mov arr3[24],rax        ; ������ � �������������� ������
    
                    add rsi,16          ; ����������� ��������� �� ��������� �������
                    add rdi,16          ; ����������� ��������� �� ��������� �������
                    vmovups XMM0,[rsi]   ; ��������� �������� �� ������� 1
                    vmovups XMM1,[rdi]   ; ��������� �������� �� ������� 2
                    mulpd xmm0,xmm1     ; ��������� ���� ��� ���������

                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 5
                    mov arr3[32],rax        ; ������ � �������������� ������ 

                    unpckhpd xmm0,xmm2      ; �������� ������� �������� ����� � �������
                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 6
                    mov arr3[40],rax        ; ������ � �������������� ������

                    add rsi,16          ; ����������� ��������� �� ��������� �������
                    add rdi,16          ; ����������� ��������� �� ��������� �������
                    vmovups XMM0,[rsi]   ; ��������� �������� �� ������� 1
                    vmovups XMM1,[rdi]   ; ��������� �������� �� ������� 2
                    mulpd xmm0,xmm1     ; ��������� ���� ��� ���������

                    cvtpd2pi mm0,xmm0       ; �������������� � 32-� ��������� �����
                    movd dword ptr eax,mm0  ; ����� 7
                    mov arr3[48],rax        ; ������ � �������������� ������

                _endAVX:
                    mov r8,arr3         ; ������ � ������� r8
                    mov r9,arr3[8]      ; ������ � ������� r9
                    mov r10,arr3[16]    ; ������ � ������� r10
                    mov r11,arr3[24]    ; ������ � ������� r11
                    mov r12,arr3[32]    ; ������ � ������� r12
                    mov r13,arr3[40]    ; ������ � ������� r13
                    mov r14,arr3[48]    ; ������ � ������� r14
                    invoke wsprintf, ADDR buf, ADDR fmt, r8,r9,r10,r11,r12,r13,r14
                    invoke MsgboxI,hWin,ADDR buf,"��������� ���������� AVX",MB_OK,10

        .endsw
      .case WM_CLOSE ; ���� ���� ��������� � �������� ����
         invoke EndDialog,hWin,0 ; 
    .endsw
    xor rax, rax
    ret
main endp
end
