.eqv    NAME_SIZE 256	# Размер буфера для имени файла, из которого надо считывать данные
.eqv    TEXT_SIZE 512	# Размер буфера для текста
.eqv	NAME_SIZE_WRITE 256 # Размер буфера для имени файла, в который надо записать данные

.data
prompt:	.asciz "Input file path to read: "     # Путь до читаемого файла
er_name_mes:	.asciz "Incorrect file name\n"
er_read_mes:	.asciz "Incorrect read operation\n"
file_name:	.space NAME_SIZE		# Имя читаемого файла
strbuf: .space TEXT_SIZE			# Буфер для читаемого текста

prompt_write:  .asciz "Input file path to write: "     # Путь до записываемого файла
default_name_write: .asciz "testout.txt"      # Имя файла по умолчанию
file_name_write: .space	NAME_SIZE_WRITE		# Имя файла для записи
buffer:     .space 20   # Буфер для хранения ASCII-представления числа
zero_num_ascii: .asciz "0" 

.text
	# Чтение из файла
	jal read_data_from_file
    
    	# Обработка данных
    	# a0 - указатель на строку
   	# a1 - размер строки
   	# Результат: t0 - количество вхождений знаков препинания
    	la a0, strbuf
    	li a1, 2048
    	jal process_data
    	
    	# Перевод числа в строку
    	# a0 - число вхождений знаков препинания
    	# a1 - указатель на буфер
    	# a2 - основание системы счисления (десятичная)
    	# a3 - размер буфера
    	# Результат: хранится в метке buffer
    	mv a0, t0     
    	la a1, buffer    
    	li a2, 10
    	li a3, 20
    	jal int_to_str
    
    	# Получение длины строки
    	# a0 - адрес строки
	# Результат: a1 - длина строки
    	la a0, buffer
    	jal ra, get_string_length
    
    	# Разворот строки
    	# a0 - адрес строки
    	# a1 - длина строки
	# Результат: хранится в метке buffer
    	la a0, buffer
    	jal ra, reverse_string
    	
    	# Запись в файл
    	jal write_to_file
    
    	# Завершение программы
    	li a7 10
    	ecall
   	
	
    	   	
    	   	
    	   	
# Подпрограмма для чтения из файла         
read_data_from_file:
    	# Вывод подсказки
	la a0 prompt
	li a7 4
    	ecall
    	# Ввод имени файла с консоли эмулятора
    	la a0 file_name
    	li a1 NAME_SIZE
    	li a7 8
    	ecall
    	# Убрать перевод строки
    	li t4 '\n'
    	la t5	file_name
	loop_read:
    		lb t6 (t5)
    		beq t4 t6 replace_read
    		addi t5 t5 1
    		b loop_read
	replace_read:
    		sb zero (t5)
    
	li a7 1024     	# Системный вызов открытия файла
    	la a0 file_name   # Имя открываемого файла
    	li a1 0        	# Открыть для чтения (флаг = 0)
    	ecall             		# Дескриптор файла в a0 или -1)
    	li s1 -1			# Проверка на корректное открытие
    	beq a0 s1 er_name	# Ошибка открытия файла
    	mv s0 a0       	# Сохранение дескриптора файла
    
   	# Чтение информации из открытого файла
    	li a7, 63       # Системный вызов для чтения из файла
    	mv a0, s0       # Дескриптор файл
    	la a1, strbuf   # Адрес буфера для читаемого текста
    	li a2, TEXT_SIZE # Размер читаемой порции
    	ecall             # Чтение
    	# Проверка на корректное чтение
    	beq a0 s1 er_read	# Ошибка чтения
    	mv s2 a0       	# Сохранение длины текста
    
    	# Закрытие файла
    	li a7, 57       # Системный вызов закрытия файла
    	mv a0, s0       # Дескриптор файла
    	ecall             # Закрытие файла
    	
     	jr ra 
     	
er_name:
    	# Сообщение об ошибочном имени файла
    	la a0 er_name_mes
    	li a7 4
    	ecall
    	# И завершение программы
    	li a7 10
    	ecall
er_read:
    	# Сообщение об ошибочном чтении
	la a0 er_read_mes
    	li a7 4
    	ecall
    	# И завершение программы
    	li a7 10
    	ecall

 
    


# Подпрограмма для обработки данных из файла
# Аргументы: a0 - указатель на строку, a1 - размер строки
# Результат: t0 - количество вхождений знаков препинания
process_data:
	# Локальные переменные: t1, t2
    	# Инициализация счетчика вхождений знаков препинания
    	li t0, 0
    
    	# Перебор каждого символа в строке
	loop1:
        	lb t1, 0(a0)    # Загрузка текущего символа в t1
        	beq t1, zero, end # Если символ равен нулю, завершаем цикл

	# Проверка, является ли текущий символ одним из знаков препинания
      li t2, 33        # ASCII-код знака препинания (!)
      beq t1, t2, is_punctuation
     	li t2, 34        # ASCII-код знака препинания (")
      beq t1, t2, is_punctuation
      li t2, 39        # ASCII-код знака препинания (')
      beq t1, t2, is_punctuation
      li t2, 44        # ASCII-код знака препинания (,)
      beq t1, t2, is_punctuation
      li t2, 46        # ASCII-код знака препинания (.)
      beq t1, t2, is_punctuation
      li t2, 58        # ASCII-код знака препинания (:)
      beq t1, t2, is_punctuation
      li t2, 59        # ASCII-код знака препинания (;)
      beq t1, t2, is_punctuation
      li t2, 63        # ASCII-код знака препинания (?)
      beq t1, t2, is_punctuation

      # Если символ не является знаком препинания, переходим к следующему символу
      addi a0, a0, 1
      j loop1

      # Обработка знака препинания
	is_punctuation:
        	addi t0, t0, 1
        	addi a0, a0, 1
        	j loop1

	end:
    		# Здесь t0 содержит количество вхождений знаков препинания
    		jr   ra              
    
    
    
    
    
# Подпрограмма для записи в файл
 write_to_file:
	la a0, prompt_write
    	li a7, 4
    	ecall
    	
    	# Ввод имени файла с консоли эмулятора
    	la a0 file_name_write
    	li a1 NAME_SIZE_WRITE
    	li a7 8
    	ecall
    	# Убрать перевод строки
    	li t4 '\n'
    	la t5  file_name_write
    	mv t3 t5	# Сохранение начала буфера для проверки на пустую строку
	loop12:
    		lb t6 (t5)
    		beq t4 t6 replace12
    		addi t5 t5 1
    		b loop12
	replace12:
    		beq t3 t5 default12	# Установка имени введенного файла
    		sb zero (t5)
    		mv a0, t3 	# Имя, введенное пользователем
    		b out
	default12:
    		la a0, default_name_write # Имя файла по умолчани
	out:
    		# Open (for writing) a file that does not exist
    		li a7, 1024     # system call for open file
    		li a1, 1        # Open for writing (flags are 0: read, 1: write)
    		ecall             # open a file (file descriptor returned in a0)
    		mv s6, a0       # save the file descriptor
    		
    		# Write to file just opened
    		li a7, 64       # system call for write to file
    		mv a0, s6       # file descriptor
    		la a1, buffer   # address of buffer from which to write
    		li a2, 20       # hardcoded buffer length
    		ecall             # write to file

    		# Close the file
    		li a7, 57       # system call for close file
    		mv a0, s6       # file descriptor to close
    		ecall             # close file



    

# Подпрограмма для преобразования числа в ASCII
# Аргументы: a0 - число, a1 - указатель на буфер, a2 - основание системы счисления, a3 - размер буфера
# Результат: хранится в метке buffer
int_to_str:
	# Локальные переменные: t0, t2, t3, t4, t5
	
	# Проверка на 0 вхождений
	beqz a0, zero_num_lab
	
	addi sp, sp, -4        # Резервирование места для временного регистра на стеке
    	sw ra, 0(sp)         # Сохранение ra на стеке

    	li t0, 0             # Индекс текущего символа в буфере

    	bnez a0, loop          # Если число не равно нулю, начинаем цикл

    	# Обработка случая, когда число равно нулю
    	sb zero, 0(a1)       # Сохранение символа '0' в буфере
    	addi a1, a1, 1         # Переход к следующему символу в буфере
    	j end_int_to_str    # Завершение работы подпрограммы

    	loop:
        	rem t2, a0, a2     # Остаток от деления числа на основание
        	addi t2, t2, 48     # Преобразование остатка в ASCII-символ
        	sb t2, 0(a1)      # Сохранение символа в буфере
        	addi a1, a1, 1      # Переход к следующему символу в буфере
        	div a0, a0, a2     # Деление числа на основание
        	bnez a0, loop       # Повторяем цикл, если число не равно нулю

    	end_int_to_str:
    		sb zero, 0(a1)       # Добавление нулевого символа в конец строки
   		lw ra, 0(sp)          # Восстановление ra из стека
    		addi sp, sp, 4          # Освобождение места на стеке
    		
    		jr ra                # Возвращение из подпрограммы
    	zero_num_lab:
    		# Загрузка адреса строки "0" в регистр a1
    		la t3, zero_num_ascii

    		# Загрузка адреса буфера в регистр a0
    		la t4, buffer

    		# Копирование строки "0" в буфер
    		copy_loop:
        		lb t5, 0(t3)      # Загрузка текущего символа из zero_num_ascii
        		beqz t5, end_copy # Если символ нулевой, завершаем цикл
        		sb t5, 0(t4)      # Сохранение символа в буфере
        		addi t4, t4, 1    # Переход к следующему символу в буфере
        		addi t3, t4, 1    # Переход к следующему символу в zero_num_ascii
        		j copy_loop       # Повторяем цикл

    		end_copy:
    			jr ra   
    
    




# Переворот строки.
# Аргументы: a0 - адрес строки, a1 - длина строки
# Результат: хранится в метке buffer
reverse_string:
	# Локальные переменные: a2, a3 ,a4
	
    	# Проверка на нулевую длину строки
	beqz a1, end_reverse

    	# Индексы для начала и конца строки
    	add a2, a0, a1       # a2 = a0 + a1 (конец строки)
    	addi a2, a2, -1       # a2 = a2 - 1 (последний символ строки)

	reverse_loop:
    		# Загрузка текущих символов
    		lb a3, 0(a0)         # a3 = текущий символ из начала строки
    		lb a4, 0(a2)         # a4 = текущий символ с конца строки

    		# Обмен символов местами
    		sb a4, 0(a0)
    		sb a3, 0(a2)

    		# Обновление индексов
    		addi a0, a0, 1        # увеличение индекса начала строки
    		addi a2, a2, -1       # уменьшение индекса конца строки

    		# Проверка на завершение разворота
    		blt a0, a2, reverse_loop

	end_reverse:
    		ret
    
    
# Длина строки
# Аргументы: a0 - адрес строки
# Результат: a1 - длина строки
get_string_length:
	# Локальные переменные: a2

    	# Инициализация счетчика длины строки
    	li a1, 0

    	loop_count:
        	lb a2, 0(a0)      # Загрузка текущего символа
        	beqz a2, end_count  # Если символ нулевой, завершаем цикл
        	addi a1, a1, 1     # Увеличиваем счетчик длины строки
        	addi a0, a0, 1     # Переходим к следующему символу
        	j loop_count       # Повторяем цикл

    	end_count:
    		ret
