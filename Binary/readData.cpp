#include <bits/stdc++.h>
#include "flights.h"

void readData() {
    ifstream fin("input.txt");
    ofstream finb("input.bf", ios::binary);
    while(!fin.eof()) {
        Item item;
        fin >> item;
        finb.write(reinterpret_cast<char*>(&item), sizeof item);
    }
    fin.close();
}
