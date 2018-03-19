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
                printf("%d ���� �������� �� ���� #%d\n", seats, id);
            }
        }
    }
    if (!any) {
        printf("��� ������ �� %s � %s �� ���������� �������\n", dest, t.toString().c_str());
    }
}

void findLongestFlight() {
    Item best = flights[0];
    for(auto item: flights) {
        if (best.arr - best.dep < item.arr - item.dep) {
            best = item;
        }
    }
    printf("���� #%d �� %s ����� ����� ������� ������������ (%d �����)\n", best.id, best.dest, best.duration());
}

void modifyFlight(int id, Time dep, Time arr) {
    for(auto &item: flights) {
        if (item.id == id) {
            item.arr = arr;
            item.dep = dep;
            printf("����� ����������� ����� #%d ���� �������� �� %s, ����� �������� - �� %s\n", id, dep.toString().c_str(), arr.toString().c_str());
            return;
        }
    }
    printf("������! ���� #%d �����������\n", id);
}

void printData() {
    int sz = (int)flights.size();
    printf("����� %d %s:\n", sz, (sz == 1 ? "����" : "������"));
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
    printf("����� �� %s ���� �������\n", dest);
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
        printf("������! ������ ���� ������ �� %s!\n", dest);
        return;
    }
    swap(flights[idx1], flights[idx2]);
    printf("����� #%d � #%d ���� �������� �������\n", flights[idx1].id, flights[idx2].id);
}

void sortData() {
    sort(flights.begin(), flights.end());
    printf("����� ����������� �� �����������");
}

void testQueries() {
    findSeats("�������", Time(14, 05));
    findLongestFlight();
    modifyFlight(240, Time(13, 15), Time(17, 20));
    removeFlights("�������");
    removeFlights("������");
    swapFlights("������");
//    printData();
    sortData();
}

void processQueries() {
    printf("������� ����� ��������, ������� ������ ���������:\n");
    printf("0: ��������� ������ ���������.\n");
    printf("1: ��������� ������� ������ � �������� ������������ � �������� �����������.\n");
    printf("2: ����� ����� � ����� ���������� ����� � ���������� �������� ������.\n");
    printf("3: �������� ��� ���������� ����� ����� ������ � ����� ��������.\n");
    printf("4: ������� �� ������ ����� �� ��������� �����������.\n");
    printf("5: �������� ������� � ������ ����� �� ��������� �����������.\n");
    printf("6: ����������� ������ �� ������ ����������.\n");
    int type;
    cin >> type;
    if (type == 0) {
        return;
    }
    if (type == 1) {
        char dest[200]; Time t;
        printf("������� ����������� � ����� �����������: ");
        cin >> dest >> t;
        findSeats(dest, t);
    }
    if (type == 2) {
        findLongestFlight();
    }
    if (type == 3) {
        int id; Time dep, arr;
        printf("������� ����� �����, ����� ����������� � ����� ��������:");
        cin >> id >> dep >> arr;
        modifyFlight(id, dep, arr);
    }
    if (type == 4) {
        char dest[200];
        printf("������� ����������� �����:");
        cin >> dest;
        removeFlights(dest);
    }
    if (type == 5) {
        char dest[200];
        printf("������� ����������� �����:");
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
