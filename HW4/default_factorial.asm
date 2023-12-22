.data 
rep: .asciz "\n"
out: .asciz "\nМаксимальный факториал для int32: "
.text
	li s2, 2147483647 # Максимальное значение INT32

	# Инициализация переменной n = 1
	li t1, 1         

# Цикл для вычисления факториалов
while:
	mv a0, t1       
	jal fact         # Вызываем функцию fact для вычисления факториала n

	# Выводим результат факториала n
	li a7, 1        
	ecall            

	# Увеличиваем n
	addi t1, t1, 1  

	# Проверка на переполнение
	div t2, s2, t1   # Вычисляем (MaxInt / n)
	bgt a0, t2, end_while # Если n! > (MaxInt / n), выходим из цикла

	# Вывод разделителя
	la a0, rep       
	li a7, 4         
	ecall            

	j while      

# Конец цикла
end_while:
	addi t1, t1, -1  # Уменьшаем n, так как последнее увеличение было лишним

	li a7, 4        
	la a0, out       
	ecall           

	# Вывод результата
	li a7, 1         
	mv a0, t1        
	ecall         

	# Завершение программы
	li a7, 10      
	ecall            

# Функция вычисления факториала
fact:
	li t3, 1       
	mv t0, t3    

# Цикл вычисления факториала
while_f:
	bgt t3, a0, end  # Если счетчик > n, выходим из цикла
	mul t0, t0, t3 
	addi t3, t3, 1   # Увеличиваем счетчик
	j while_f    

# Конец цикла
end: 	
	mv a0, t0        # Возвращаем результат в a0
	ret         
