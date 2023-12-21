.globl main
.include "macros.asm"
.eqv	BUF_SIZE 100
.data
sep: .asciz "\n"
dest:    .space BUF_SIZE	# Буфер для чтения данных.
src: .space BUF_SIZE
empty_str: .asciz "" 
test_str: .asciz "Hello, world!!!"    
.global dest
.global src
.text

main:
	read_str(dest) # Считывание строк с клавиатуры.
	read_str(src)
li a7 5
ecall
mv a3 a0

# 2 строки с консоли.
strncpy(dest, src, a3)	# Вызов макроса функции strncpy.
print_str(dest)	# Печать результата.

# Пустая строка и строка символов.
li a3 7 
strncpy(empty_str, test_str, a3)
print_str(empty_str)
li a7 4
la a0 sep
ecall

# Строкой символов и src.
li a3 5
strncpy(test_str, src, a3)
print_str(test_str)

# Завершение программы.
li a7 10
ecall


# Подпрограмма Strncpy.
# Параметры:
# a1- dest, a2 - src,  a3 - len.
strncpy:
	push(ra)
	strlen(a2) # Длина строки src.
	mv t2 a0
	li t3 0 # Счетчик цикла.
	for:
		beq t3 a3 end_for # От 0 до len.
		bge t3 t2 fill # Eсли кончилась длина src, обрезаем.
		lb t4 (a2) # Копирование.
		sb t4 (a1)
		j next
		fill:
			sb t0 (a1)
			b end_for
		next:
			addi a1 a1 1 # Следующая итерация
			addi a2 a2 1
			addi t3 t3 1
			b for
		end_for:
	pop(ra)				
	ret
