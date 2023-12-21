.eqv     BUF_SIZE 100

.macro strncpy(%dest, %src, %len
la a1 %dest
la a2 %src
mv a3 %len
jal strncpy
la a0 %dest
.end_macro

# Вывод строки в консоль.
.macro print_str(%buffer)
	push(a0)
	la a0 %buffer
	li a7 4
	ecall
	pop(a0)
.end_macro

# Длина строки.
.macro strlen(%str)
	push(%str)
    li      t0 0	# Инициализация счётчика.
loop:
    lb      t1 (%str)	# Загрузка символа для сравнения.
    beqz    t1 end
    addi    t0 t0 1	# Увеличение счётчика.
    addi    %str %str 1	# Берём следующий символ.
    b       loop
end:
    pop(%str)
    mv      a0 t0
.end_macro

# Считывание INT.
.macro read_str(%buf)
la      a0 %buf
li a1 BUF_SIZE
li      a7 8
ecall
.end_macro

# Вывод INT.
.macro print_int(%x)
li a7 1
mv a0 %x
ecall
.end_macro

# Сохранение INT в стек.
.macro push(%x)
 addi sp, sp, -4
 sw  %x, (sp)
.end_macro 

# Удаление INT из стека.
.macro pop(%x)
 lw  %x, (sp)
 addi sp, sp, 4
.end_macro 
