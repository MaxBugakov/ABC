.data
ex: .asciz "out of int \n"	# Сообщение о выходе за пределы целых чисел
s: .asciz "sum: "              
ev: .asciz "even: "          
od: .asciz "odd: "           
endl: .asciz "\n"               
.align 2
array: .space 40	# Выделение места под 10 целых чисел
arrend:
.text

# Функция для ввода массива и подсчета четных и нечетных чисел
fill_array_and_count_even_odd:
    la t0, array                  # В t0 хранится адрес начала массива
    la s1, arrend                # Указатель на конец массива (на всякий случай)
    li a7, 5
    ecall
    mv t1, a0                    # В t1 хранится количество чисел в массиве
    li t2, 10

    # Устанавливаем предел - 10 чисел
    if_greater_10:
        ble t1, t2, fill
        li t1, 10

    # Заполняем массив числами
    fill:
        bge t3, t1, end_fill        # t3 хранит счетчик для цикла
        li a7, 5
        ecall
        mv t2, a0
        sw t2, (t0)                # Записываем число в массив
        addi t3, t3, 1
        addi t0, t0, 4             # Расстояние между соседними элементами - 4 байта
        j fill
    end_fill:

    li t3, 0
    la t0, array                  # Возвращаем указатель на начало массива
    li t2, 2                       # Для определения четности

    # Цикл для подсчета четных и нечетных чисел в регистрах s2 и s3
    ev_odd:
        bge t3, t1, end_ev_odd
        lw t5, (t0)
        rem t6, t5, t2             # Остаток от деления числа в массиве на 2
        even:
            bnez t6, odd
            addi s2, s2, 1
        odd:
            beqz t6, end_if
            addi s3, s3, 1
        end_if:
            addi t0, t0, 4
            addi t3, t3, 1
            j ev_odd
    end_ev_odd:

    # Вывод количества четных и нечетных чисел
    li a7, 4
    la a0, ev
    ecall
    li a7, 1
    mv a0, s2
    ecall
    la a0, endl
    li a7, 4
    ecall
    la a0, od
    ecall
    li a7, 1
    mv a0, s3
    ecall
    la a0, endl
    li a7, 4
    ecall

    # Обнуляем счетчики и указатель перед началом нового цикла по массиву
    li t3, 0
    li t6, 0
    la t0, array

    # Цикл для вычисления суммы чисел в массиве
    sum:
        bge t3, t1, end_sum
        lw t5, (t0)                  # Распаковка текущего числа из массива
        li s5, 0                      # Здесь хранятся результаты XOR
        li s4, 0                      # Здесь хранится знак новой суммы после добавления нового числа
        li s6, 0                      # Здесь хранится знак текущей суммы перед добавлением нового числа
        li s7, 0                      # Здесь хранится знак текущего элемента массива
        sum_gr_0:
            bltz t4, num_gr_0
            li s6, 1
        num_gr_0:
            bltz t5, xor_check
            li s7, 1
        xor_check:
            xor s5, s6, s7
            beqz s5, final_check
            j ok
        final_check:
            add t6, t4, t5
        new_sum_gr_0:
            bltz t6, xor_check_2
            li s4, 1
        xor_check_2:
            xor s5, s4, s6
            bnez s5, break
        ok:
            add t4, t4, t5            # Прибавляем к старой сумме новое число
            addi t0, t0, 4            # Сдвигаем указатель
            addi t3, t3, 1
            j sum
    break:                            # Случай переполнения
        la a0, ex                      # Сообщаем о переполнении
        li a7, 4
        ecall
        j print_sum                    # Печатаем последнюю корректную сумму
    end_sum:

# Вывод суммы.
print_sum:
    la a0, s
    li a7, 4
    ecall
    li a7, 1
    mv a0, t4
    ecall

    li a7, 10                         # Завершение программы
    ecall

main:
    call fill_array_and_count_even_odd
