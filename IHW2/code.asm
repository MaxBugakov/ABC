.data
input_prompt: .asciz "Введите число: "
result_message: .asciz "Квадратный корень: "
error_message: .asciz "Ошибка: корень не определен для отрицательных чисел\n"
double_value: .double 0.0005

.text
# Основная программа
main:
	# Предложение пользователю ввести число
      	la a0, input_prompt
      	li a7, 4
      	ecall
      
      	# Ввод числа
      	li a7, 5
      	ecall
  
  	# Проверка числа на корректность
  	bltz a0, error
  
  	# Поиск 0.05% от введённого числа
      	fld ft0, double_value, t3
      	fcvt.d.w fa1, a0
      	fmul.d ft2, ft0, fa1
      	fmv.d fa2, ft2
      
      	# Запуск подпрограммы
      	# Параметр 1(число) - fa1, парметр 2(точность) - fa2
      	# Результат fa0
      	jal herons_square_root

      	# Вывод результата
      	la a0, result_message
      	li a7, 4
     	ecall
     
     	# Вывод результата fa0
      	li a7, 3
      	ecall

      	j end
      	
error:
    # Вывод сообщения об ошибке
    la a0, error_message
    li a7, 4
    ecall

end:
    # Завершение программы
    li a7, 10
    ecall
    
    

# Подпрограмма для вычисления квадратного корня
# Аргументы: fa1 - входное число, fa2 - точность
# Результат: fa0 - квадратный корень
herons_square_root:
      	# Локальные переменные:
      	# ft0, ft1, ft2, ft3
      
      	# Начальное приближение (половина числа)
      	li t0, 2
      	fcvt.d.w ft0, t0
      	fdiv.d ft1 fa1 ft0 # ft1 - приближенное значение к корню
loop:
  	fmsub.d ft2, ft1, ft1, fa1  # ft1 * ft1 - fa1  
  	fabs.d ft2, ft2
  
  	# Сравнение получившегося корня с заданной точность
  	fle.d t1, ft2, fa2  
  	bnez t1, done  # if ft2 <= fa2, j to done
  
  	# Поиск нового значения корня (более точного)
  	fdiv.d ft2, fa1, ft1
  	fadd.d ft3, ft1, ft2
  	fdiv.d ft1, ft3, ft0 # (приближенное значение к корню/число + приближенное значение к корню)/2
  
  	j loop
done:
  	# Завершение подпрограммы.
      	fmv.d fa0, ft1
      	jr ra
