#include <bits/stdc++.h>
#include "flights.h"
using namespace std;


vector <Item> flights;

ifstream finb("input.bf", ios::binary);
ofstream foutb("output.bf", ios::binary);

void findSeats(char dest[200], Time t) {
    bool any = false;
    for(size_t i = 0; i < flights.size(); ++i) {
        if (strcmp(flights[i].dest, dest) == 0 && flights[i].dep == t) {
            int seats = flights[i].free;
            int id = flights[i].id;
            if (seats > 0) {
                any = true;
                printf("%d мест свободно на рейс #%d\n", seats, id);
            }
        }
    }
    if (!any) {
        printf("Нет рейсов до %s в %s со свободными местами\n", dest, t.toString().c_str());
    }
}

void findLongestFlight() {
    Item best = flights[0];
    for(auto item: flights) {
        if (best.arr - best.dep < item.arr - item.dep) {
            best = item;
        }
    }
    printf("Рейс #%d до %s имеет самую большую длительность (%d минут)\n", best.id, best.dest, best.duration());
}

void modifyFlight(int id, Time dep, Time arr) {
    for(auto &item: flights) {
        if (item.id == id) {
            item.arr = arr;
            item.dep = dep;
            printf("Время отправления рейса #%d было изменено на %s, время прибытия - на %s\n", id, dep.toString().c_str(), arr.toString().c_str());
            return;
        }
    }
    printf("Ошибка! Рейс #%d отсутствует\n", id);
}

void printData() {
    int sz = (int)flights.size();
    printf("Всего %d %s:\n", sz, (sz == 1 ? "рейс" : "рейсов"));
    for(int i = 0; i < flights.size(); ++i) {
        Item item = flights[i];
        cout << item << endl;
        foutb.write(reinterpret_cast<char*>(&item), sizeof item);
    }

}

void removeFlights(char dest[200]) {
    flights.resize( remove_if(flights.begin(), flights.end(), [&](const Item &rhs) {
        return strcmp(dest, rhs.dest) == 0;
    }) - flights.begin());
    printf("Рейсы до %s были удалены\n", dest);
}

void swapFlights(char dest[200]) {
    int idx1 = -1, idx2 = -1;
    for(int i = 0; i < (int)flights.size(); ++i) {
        if (strcmp(flights[i].dest, dest) == 0) {
            if (idx1 == -1) idx1 = i;
            else if (idx2 == -1) idx2 = i;
        }
    }
    if (idx2 == -1) {
        printf("Ошибка! Меньше двух рейсов до %s!\n", dest);
        return;
    }
    swap(flights[idx1], flights[idx2]);
    printf("Рейсы #%d и #%d были изменены местами\n", flights[idx1].id, flights[idx2].id);
}

void sortData() {
    sort(flights.begin(), flights.end());
    printf("Рейсы упорядочены по направлению");
}

void testQueries() {
    findSeats("Варшава", Time(14, 05));
    findLongestFlight();
    modifyFlight(240, Time(13, 15), Time(17, 20));
    removeFlights("Варшава");
    removeFlights("Берлин");
    swapFlights("Москва");
//    printData();
    sortData();
}

void processQueries() {
    printf("Введите номер операции, которую хотите выполнить:\n");
    printf("0: Завершить работу программы.\n");
    printf("1: Проверить наличие рейсов с заданным направлением и временем отправления.\n");
    printf("2: Найти номер и пункт назначения рейса с наибольшим временем полета.\n");
    printf("3: Обновить для указанного рейса время вылета и время прибытия.\n");
    printf("4: Удалить из списка рейсы по заданному направлению.\n");
    printf("5: Поменять местами в списке рейсы по заданному направлению.\n");
    printf("6: Упорядочить список по пункту назначения.\n");
    int type;
    cin >> type;
    if (type == 0) {
        return;
    }
    if (type == 1) {
        char dest[200]; Time t;
        printf("Введите направление и время отправления: ");
        cin >> dest >> t;
        findSeats(dest, t);
    }
    if (type == 2) {
        findLongestFlight();
    }
    if (type == 3) {
        int id; Time dep, arr;
        printf("Введите номер рейса, время отправления и время прибытия:");
        cin >> id >> dep >> arr;
        modifyFlight(id, dep, arr);
    }
    if (type == 4) {
        char dest[200];
        printf("Введите направление рейса:");
        cin >> dest;
        removeFlights(dest);
    }
    if (type == 5) {
        char dest[200];
        printf("Введите направление рейса:");
        cin >> dest;
        swapFlights(dest);
    }
    if (type == 6) {
        sortData();
    }
    cout << endl;
    processData();
}

void processData() {
    while(!finb.eof()) {
        Item item;
        finb.read(reinterpret_cast<char*>(&item), sizeof item);
        flights.push_back(item);
    }
    finb.close();
    flights.pop_back();
    testQueries();
//    processQueries();
    printData();
    foutb.close();
}
