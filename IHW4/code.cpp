#include <iostream>
#include <vector>
#include <pthread.h>
#include <random>
#include <unistd.h>

pthread_mutex_t mtx; // Мьютекс для синхронизации потоков.

// Структура, представляющая поклонника.
struct Admirer {
    int id; // Идентификатор поклонника.
    std::string romanticEveningPlan; // План романтического вечера.
    std::string response; // Ответ студентки.

    // Конструктор для инициализации поклонника.
    Admirer(int id) : id(id), response("Не известно") {
        // Формирование уникального варианта романтического вечера для каждого поклонника.
        romanticEveningPlan = "Вариант романтического вечера №" + std::to_string(id);
    }
};

// Функция, выполняемая каждым потоком поклонника.
void* makeProposal(void* arg) {
    Admirer* admirer = (Admirer*)arg;

    // Генерация случайной задержки для имитации разного времени на подготовку предложения.
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> dis(100, 500);
    usleep(dis(gen) * 1000);

    // Блокировка мьютекса для безопасного вывода информации в консоль.
    pthread_mutex_lock(&mtx);
    std::cout << "Поклонник " << admirer->id << " делает предложение: " << admirer->romanticEveningPlan << std::endl;
    pthread_mutex_unlock(&mtx);

    return nullptr;
}

// Функция для выбора поклонника студенткой.
void chooseAdmirer(std::vector<Admirer>& admirers) {
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> dis(0, admirers.size() - 1);

    // Выбор случайного поклонника.
    int chosenIndex = dis(gen);
    for (size_t i = 0; i < admirers.size(); ++i) {
        // Установка ответа студентки для каждого поклонника.
        admirers[i].response = (i == chosenIndex) ? "Пошли на свидание" : "Отказ";
    }
}

int main() {
    // Корректное отображение рускких букв в консоли.
    system("chcp 65001");

    // Ввод количества пользователей.
    int n;
    std::cout << "Введите количество поклонников: ";
    std::cin >> n;

    // Проверка на корректность введенного количества поклонников.
    if (n <= 0) {
        std::cerr << "Ошибка: количество поклонников должно быть положительным числом." << std::endl;
        return 1; // Завершение программы с кодом ошибки.
    }

    pthread_mutex_init(&mtx, nullptr);

    // Создание списка поклонников.
    std::vector<Admirer> admirers;
    for (int i = 1; i <= n; ++i) {
        admirers.emplace_back(i);
    }

    // Создание потоков для каждого поклонника.
    std::vector<pthread_t> threads(n);
    for (int i = 0; i < n; ++i) {
        pthread_create(&threads[i], nullptr, makeProposal, &admirers[i]);
    }

    // Ожидание завершения всех потоков поклонников.
    for (auto& th : threads) {
        pthread_join(th, nullptr);
    }

    // Выбор поклонника для свидания.
    chooseAdmirer(admirers);

    // Вывод результатов.
    std::cout << "----------Вывод результатов----------" << std::endl;
    for (auto& admirer : admirers) {
        std::cout << "Поклонник " << admirer.id << ": " << admirer.response << std::endl;
    }

    pthread_mutex_destroy(&mtx);

    return 0;
}
