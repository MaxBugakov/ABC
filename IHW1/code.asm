.data
fill_a_num: .asciz "Введите количество элементов в массиве A: \n"
fill_a_ex: .asciz "Некорректный размер массива"
arr_b_str: .asciz "Массив B: "
.align  2  
array_A: .space 40 #выделяем на 10 целых чисел
arrend_A:
.align  2  
array_B: .space 40 #выделяем на 10 целых чисел
arrend_B:

.text
_start:
    # Вызываем подпрограмму для вывода массива
    jal array_fill
    jal copy_array_A_to_B
    jal print_first_n

    # Завершаем программу
    li a7, 10  # Системный вызов для завершения программы
    ecall
    


# Под программа копирования массива A -> B по особым правилам.
copy_array_A_to_B:
    la a1, array_A   # Указатель на начало массива A
    la a2, arrend_A  # Указатель на конец массива A
    la a3, array_B   # Указатель на начало массива B
    li t4, 0         # Флаг для отслеживания нахождения первого положительного числа

copy_loop:
    bge a1, a2, copy_exit  # Если достигнут конец массива A, выходим из цикла
    lw a0, 0(a1)           # Загружаем значение из массива A в a0

    # Если нашли первое положительное число, копируем оставшиеся числа в массив B без изменений
    bnez t4, else_block
    bgez a0, found_positive
    addi a0, a0, -5  # Уменьшаем значение на 5
    sw a0, 0(a3)  # Сохраняем значение в массиве B
    j next_iteration

    found_positive:
    li t4, 1  # Устанавливаем флаг нахождения первого положительного числа
    sw a0, 0(a3)  # Сохраняем значение в массиве B
    j next_iteration

    else_block:
    sw a0, 0(a3)  # Сохраняем значение в массиве B
    j next_iteration

    next_iteration:
    addi a1, a1, 4  # Увеличиваем указатель на следующий элемент массива A
    addi a3, a3, 4  # Увеличиваем указатель на следующий элемент массива B
    j copy_loop

copy_exit:
    ret
    
    



# Подпрограмма для вывода первых n чисел из массива
print_first_n:
    la a0, arr_b_str
    li a7, 5
    ecall
    
    la a1, array_B    # Загружаем адрес массива array в a1
    la a2, arrend_B   # Загружаем адрес конца массива в a2
    mv t3, s2       # Копируем значение n из t1 в t3

print_loop:
    bge a1, a2, print_exit  # Если достигнут конец массива, выходим из цикла
    bnez t3, continue_print  # Если t3 не равно нулю, продолжаем вывод
    j print_exit
continue_print:
    lw a0, 0(a1)  # Загружаем значение из массива в a0
    li a7, 1  # Системный вызов для вывода целого числа
    ecall
    li a0, 32  # ASCII-код пробела
    li a7, 11  # Системный вызов для вывода символа
    ecall
    addi a1, a1, 4  # Увеличиваем указатель на следующий элемент
    addi t3, t3, -1  # Уменьшаем t3
    j print_loop

print_exit:
    ret






    
# Подпрограмма для заполнения массива.
array_fill:
	la t0  array_A # в t0 хранится адресс начала массива
	la s1 arrend_A #указатель на конец массива, на всякий случай
	
	la a0, fill_a_num # выводим текст
    	li a7 4
    	ecall
    	
	li a7 5  # вводим число
	ecall
	mv s2,a0 # в s2 - размер массива
	li t2, 10
	if_less_then_10: 
		
	
	if__10: # проверка на количество элементов в массиве.
		bgez s2, positive
		j exit
	positive:
	 	li t1, 11
    		blt s2, t1, fill
    		j exit
	fill: #заполняем массив числами 
		bge t3 s2 end_fill # в t3 будет храниться счетчик для цикла
		li a7 5
		ecall
		mv t2, a0
		sw t2 (t0) #запаковка числа в массив
		addi t3 t3 1
		addi t0 t0 4 # между соседними ячейками расстояние 4 байта
		j fill
		
	exit:
		la a0, fill_a_ex
		li a7, 4
		ecall
    		# Завершаем программу
    		li a7, 10  # Системный вызов для завершения программы
   		ecall
   	end_fill:
	ret


	
	

