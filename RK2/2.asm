;файл с комментариями к изменениям к листику
;все регистры были изменены на 64-разрядные
%include "io64.asm"
section .data
    InputMsg dq "Input string: ",10  ; #10 добавила для переноса 
    lenInput equ $-InputMsg

section .bss
    InBuf   resb    10           ; #добавлена переменная буферная 
    lenIn   equ     $-InBuf
    StrInp resb 20
    lenStr equ $-StrInp
    ; StrNew times 10 db '' ; #вместо этой переменной используем следующие две
    Stroka2 db "rrrrrrrrrrr",10 ;  #запоминаем первый множитель
lenStroka2 equ $-Stroka2
    Stroka3 db "rrrrrrrrrrr",10 ; #запоминаем второй множитель
lenStroka3 equ $-Stroka3
lena resw 10 ; #длина строки здесь будет лежать


section .text
global  _start
_start:

    mov rax, 1
    mov rdi, 1
    mov rsi, InputMsg
    mov rdx, lenInput
    syscall

    ; read
    mov rax, 0  
    mov rdi, 0      
    mov rsi, StrInp  
    mov rdx, lenStr  
    syscall        


;основная часть


;подсчет длины введенной строки до кода Enter добавлено и добавлен подсчет количества чисел
lea rdi,[StrInp] ;загрузили строку 
mov rcx,lenStr ;сюда длину введенной строки
mov al,0Ah ;ищем код Enter
repne scasb ;сканируем до него
mov rax,20 ;сюда длину выделенную загрузили
sub rax,rcx ;находим разницу
mov rcx,rax ;поменяли регистры местами
mov byte[rcx+StrInp-1],' ' ;добавила в конец пробел, потому что считать количество чисел по ним буду
dec rcx ; #уменьшила длину строки на 1, чтобы положить в переменную длину строки 
mov [lena],rcx ; #запомнила переменную
inc rcx ; #увеличила обратно, чтобы посчитать количество чисел


    mov edx,0
    mov ebx,0

cycl:
    lea rsi, [StrInp + rdx]
    ; mov al,' ' ; #оптимизировала сравнение в одну строку
    ; cmp [StrInp + edx], al ; #оптимизировала сравнение в одну строку
    cmp byte[StrInp + rdx], ' '  ; #вот строка 
    je probel
    jmp next

probel: 
    inc rbx ;в rbx количество слов теперь
    jmp next
next: 
    inc rdx
    loop cycl


 
;стараемся посчитать произведение

    mov r9, rbx ; #заменила на r9 rcx, rax на rbx
    ; mov ebx, lenStr ; #вместо этой переменной используется [lena]
    mov rdx,0 ; #очистила регистры перед началом работы цикла
    mov rbx,0 ; #очистила регистры

cycl1:
    ;mov al, ' ' ; #оптимизировала сравнение в одну строку
    lea rsi,[StrInp+edx]
    ;cmp [StrInp+edx], al ; #оптимизировала сравнение в одну строку
    cmp byte[StrInp + edx], 0x21 ; сравнила с пробелом и меньше, так как в начале исходной строки и в конце нет пробелов

    jle probel1 ; #переход если меньше, а не просто эквивалентно пробелу
    inc rdx

    mov rcx, 1 ; #добавила, так как нужно указать сколько символов копирую в строку
    lea rdi, [Stroka2 + rbx] ; #заменила регистр смещения и имя переменной, в которую записываю
    repe movsb

    inc rbx ; #увеличила регистр смещения в строке, куда копировать
    jmp cycl1

probel1:

    inc rdx
    ; mov esi, [StrNew+edx] ; #не нужно, было перенесено выше в коде и изменено имя переменной, регистр смещения и на rdi rsi
    mov byte[Stroka2+rbx],10 ; #нужно добавить \n для работы подпрограммы io64

    push rdx ; #поместила в стэк, так как после выполнения подпрограммы регистр изменяется, для корректной работы подпрограммы, а также он будет использоваться далее в программе
    mov rsi, Stroka2 ; #нужно поместить в rsi для корректной работы подпрограммы
    call StrToInt64

    mov r8, rax ; #было ниже в коде, сейчас сохранила сразу в этот регистр, так как rax будет использован
    ; jmp cycl2 ; #не нужен переход, так как выполняем последовательно

    mov rdx,0 ; #очищаю регистр, будет использован для подсчета цифр в числе
    mov rbx, [lena] ; #поместила в регистр смещение, раньше вместо этого было mov ebx, lenStr 

cycl2:

    dec rbx ; #перенесла строку вверх, так как при переходе по метке probel2 не происходило увеличение смещения
    ; mov eax, ' ' ; #оптимизировала сравнение в одну строку
    lea rsi, [StrInp+rbx] ;добавила смещение в конец исходной строки сразу rbx
    ; add edi, ebx ; #не нужно, так как сразу добавила смещение
    ; cmp edi, eax ; #оптимизировала сравнение в одну строку
    mov [lena], rbx ; #пересохранила в переменную длину смещения, чтобы при выполнении повторном смещение было не в конец исходной строки, а на число, которое еще не считали
    cmp byte[rsi], 0x21 ; #сравнила с пробелом и меньше, так как в начале исходной строки и в конце нет пробелов 
    jle probel2 ; #переход если меньше, а не просто эквивалентно пробелу

    inc rdx ; #здесь теперь лежит количество цифр в числе

    ; jmp cycl2 ;убрано, так как повтор был
    ; lea edi, [StrNew+ebx] ; #копировать числа буду теперь после того как найду пробел
    ; repe movsb ; #копирую ниже 
    jmp cycl2


probel2:
 
    ; mov r8,rax ; #эта строчка переехала выше
    mov rcx, rdx ; #поместила в счетчик количество цифр в числе
    mov rax,0 ; #обнулила начало смещения для Stroka3
    inc rsi ; #инкрементировала, чтобы не указывало на пробел
    lea rdi, [Stroka3+eax] ; #поменяла имя и регистр теперь eax, и загрузка в rdi вместо rsi
    repe movsb
    mov byte[Stroka3+edx],10 ; #нужно добавить \n для работы подпрограммы io64

    mov rsi, Stroka3 ; #нужно было не адрес переносить, скобки не нужны, также поменяла имя переменной
    call StrToInt64
    imul r8
    ; dec ebx ;убрано, так как этот регистр был нужен для смещения по строке, но теперь иначе идет смещение
    mov rsi, InBuf ; #для перевода числа в строку в rsi нужно поместить переменную, нужно для корректной работы подпрограммы
    call IntToStr64
    ; push rdx ; #не нужно, так как в стэке лежит уже необходимое значение
    mov rdx, rax
    mov rax, 1    ; системная функция 1 (write)
    mov rdi, 1    ; дескриптор файла stdout=1
    syscall
    pop rdx
    mov rbx,0 ; #очистила регистр, чтобы при втором и дальнейших выполнениях цикла смещение в новой строке было с 0

    dec r9 ; #заменила этими строками loop
    cmp r9, 0 ; #заменила этими строками loop
    ; loop cycl1 ; #слишком далеко уходим для loop
    jg cycl1 ; #если больше нуля, то не по всем числам прошли в строке, значит повторяем


exit:
    xor rdi, rdi
    mov rax, 60
    syscall