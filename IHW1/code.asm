.data
fill_a_num_str: .asciz "Введите количество элементов в массиве A (0-10): \n"
fill_a_values_str: .asciz "Введите элементы массива A через ENTER: \n"
fill_a_ex_str: .asciz "Некорректный размер массива"
arr_b_str: .asciz "Массив B: "
int_overflow_ex_str: .asciz  "Значение int было переполнено во время копирования массивов"
.align  2  
array_A: .space 40 # Выделяем на 10 целых чисел.
arrend_A:
.align  2  
array_B: .space 40 # Выделяем на 10 целых чисел.
arrend_B:

.text
# Основаная программа.
_start:
	jal array_fill		# Вызываем подпрограмму для ввода массива.
    	jal copy_array_A_to_B	# Вызываем подпрограмму для копирования массива A в B.
    	jal print_array		# Вызываем подпрограмму для ввода массива.

    	li a7, 10  # Системный вызов для завершения программы.
    	ecall



# Подпрограмма для заполнения массива.
array_fill:
	la t0  array_A		# В t0 - адресс начала массива.
	la s1 arrend_A		# В s1 - указатель на конец массива.
	
	la a0, fill_a_num_str	# Выводим текст.
    	li a7 4
    	ecall
    	
	li a7 5	# Вводим число.
	ecall
	mv s2,a0 # В s2 находится размер массива.
	li t2, 10
	
	is_len_correct: # Проверка на корректность размера массива.
		bgez s2, positive
		j exit
	positive:
	 	li t1, 11
    		blt s2, t1, fill_print
    		j exit
    	exit:
		la a0, fill_a_ex_str	# Вывод строки.
		li a7, 4
		ecall
    		li a7, 10	# Завершение программы.
   		ecall
   	fill_print:
   		la a0, fill_a_values_str	# Вывод текста.
   		li a7, 4
   		ecall
	fill:	 # Заполнение массива числами.
		bge t3 s2 end_fill # В t3 - счетчик для цикла.
		li a7 5
		ecall
		mv t2, a0
		sw t2 (t0) 	# Добавляем число в массив.
		addi t3 t3 1
		addi t0 t0 4 	# Увеличиваем указатель на следующий элемент массива.
		j fill
   	end_fill:
	ret



# Подпрограмма для копирования массива A в массив B по особым правилам.
copy_array_A_to_B:
	la a1, array_A   # Указатель на начало массива A.
    	la a2, arrend_A  # Указатель на конец массива A.
    	la a3, array_B   # Указатель на начало массива B.
    	li t4, 0         # Флаг для отслеживания нахождения первого положительного числа.

	copy_loop:
   		bge a1, a2, copy_exit  # Если достигнут конец массива A, выходим из цикла.
    		lw a0, 0(a1)           # Загружаем значение из массива A в a0.

    		# Если нашли первое положительное число, копируем оставшиеся числа в массив B без изменений.
    		bnez t4, else_block
    		bgez a0, found_positive
    		addi a0, a0, -5	# Уменьшаем значение на 5.
    		if_a0_positive:	# Проверка на переполнение a0-5.
    			bgez a0, int_overflow_ex
    			j else_a0_positive
    		int_overflow_ex:
    			la a0, int_overflow_ex_str	# Вывод строки.
			li a7, 4
			ecall
    			li a7, 10	# Завершение программы.
   			ecall
    		else_a0_positive:
    			sw a0, 0(a3)  # Сохраняем значение в массиве B.
    			j next_iteration

    		found_positive:
    			li t4, 1  # Устанавливаем флаг нахождения первого положительного числа.
    			sw a0, 0(a3)  # Сохраняем значение в массиве B.
    			j next_iteration

    		else_block:
    			sw a0, 0(a3)  # Сохраняем значение в массиве B.
    			j next_iteration

   		next_iteration:
			addi a1, a1, 4  # Увеличиваем указатель на следующий элемент массива A.
    			addi a3, a3, 4  # Увеличиваем указатель на следующий элемент массива B.
	j copy_loop

	copy_exit:
    		ret
    		
    			
    					
# Подпрограмма для вывода массива.
print_array:
    	la a0, arr_b_str	# Вывод строки.
    	li a7, 4
    	ecall
    
    	la a1, array_B    # Загружаем адрес массива array в a1.
    	la a2, arrend_B   # Загружаем адрес конца массива в a2.
    	mv t3, s2       # Копируем значение n из s2 в t3.

	print_loop:
    		bge a1, a2, print_exit  # Если достигнут конец массива, выходим из цикла.
    		bnez t3, continue_print  # Если t3 не равно нулю, продолжаем вывод.
    		j print_exit
	continue_print:
    		lw a0, 0(a1)  # Загружаем значение из массива в a0.
    		li a7, 1  # Системный вызов для вывода целого числа.
    		ecall
    		li a0, 32  # ASCII-код пробела.
    		li a7, 11  # Системный вызов для вывода символа.
    		ecall
    		addi a1, a1, 4  # Увеличиваем указатель на следующий элемент.
    		addi t3, t3, -1  # Уменьшаем t3.
    		j print_loop
	print_exit:
    		ret

